# Google Drive Mount Investigation & Optimization Guide

This report covers the investigation of the lag and unresponsiveness you are experiencing with your Google Drive mount on Ubuntu 26.

---

## 🔍 Root Cause Analysis

Based on the system logs and configuration checks, we identified three major bottlenecks causing your mount to freeze:

### 1. Google Drive API Quota Exceeded (Primary Issue)
Your `rclone` systemd service logs show frequent instances of the following error:
```
ERROR : /: Dir.Stat error: couldn't list directory: googleapi: Error 403: Quota exceeded for quota metric 'Queries' and limit 'Queries per minute'...
```
*   **Why this happens:** By default, rclone uses a shared, built-in Google Client ID and Secret that is shared globally among thousands of rclone users. As a result, the shared API quota is constantly exhausted. When this happens, Google throttles your requests, causing the mount to hang and become unresponsive.

### 2. Ubuntu Indexing Service (`localsearch-3`)
The system indexer `localsearch-3.service` (formerly known as Tracker / Tracker Miner FS) is active and indexing your `$HOME` directory.
*   **Why this happens:** Because your Google Drive is mounted at `~/google-drive` (inside your home directory), `localsearch-3` crawls the entire mount recursively to index its contents. This sends hundreds of metadata queries and file read requests to the Google Drive API, instantly triggering the `rateLimitExceeded` blocks and freezing the file manager.

### 3. Sub-optimal Cache Configurations
The current service configuration does not define explicit values for directory caching (`--dir-cache-time`) or attribute caching (`--attr-timeout`).
*   **Why this happens:** Without these settings, rclone frequently queries Google Drive's API to verify if file metadata (size, mod-time) has changed. Every time you open Nautilus or standard open-file dialogs, a flood of API requests is dispatched.

---

## 🛠️ Step-by-Step Optimization Plan

Follow these steps to eliminate the lag and restore seamless performance.

### Step 1: Prevent Ubuntu indexer from scanning the Mount
Exclude the mount directory from both the GNOME indexing service and future system crawls.

1. Run this command to tell `localsearch-3` to ignore the `google-drive` folder:
   ```bash
   gsettings set org.freedesktop.Tracker3.Miner.Files ignored-directories "['po', 'CVS', 'core-dumps', 'lost+found', 'google-drive']"
   ```
2. Create a `.trackerignore` and a `.nomedia` file inside the root of your Google Drive directory. This acts as a secondary block for any other indexers:
   ```bash
   touch ~/google-drive/.trackerignore
   touch ~/google-drive/.nomedia
   ```

---

### Step 2: Optimize the Systemd Service Configuration
Update your rclone user service to enable long-term memory caching of directories and attributes. Because rclone uses change notifications (`--poll-interval`), it will automatically receive updates from Google if a file is modified externally, meaning a long cache time is completely safe.

1. Open your service file:
   ```bash
   nano ~/.config/systemd/user/rclone-mount.service
   ```
2. Replace its content with the optimized configuration below:

```ini
[Unit]
Description=RClone Mount Google Drive
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount gdrive: %h/google-drive \
    --config %h/.config/rclone/rclone.conf \
    --vfs-cache-mode full \
    --vfs-cache-max-age 24h \
    --vfs-cache-max-size 10G \
    --dir-cache-time 1000h \
    --attr-timeout 1000h \
    --poll-interval 1m \
    --vfs-fast-fingerprint \
    --buffer-size 32M \
    --vfs-read-ahead 128M \
    --allow-other
ExecStop=/usr/bin/fusermount3 -u %h/google-drive
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

3. Reload and restart the systemd service:
   ```bash
   systemctl --user daemon-reload
   systemctl --user restart rclone-mount.service
   ```

#### Summary of Added Flags:
*   `--dir-cache-time 1000h` & `--attr-timeout 1000h`: Caches folder structures and file metadata in memory for quick retrieval.
*   `--poll-interval 1m`: Asks Google Drive for changes every minute and updates the cached memory structure accordingly.
*   `--vfs-fast-fingerprint`: Optimizes file modification checks to speed up read/write caching.
*   `--vfs-read-ahead 128M` & `--buffer-size 32M`: Smooths out reading and buffering when opening documents or media.

---

### Step 3: Create and Use your Own Google API Client ID
To completely solve the `Quota exceeded` problem, you should generate your own Google Cloud Console credentials. This is free and guarantees you a private, dedicated API quota.

#### A. Generate Credentials on Google Cloud
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project (e.g., "MyRcloneDrive").
3. Search for the **Google Drive API** in the search bar and click **Enable**.
4. Go to **OAuth Consent Screen** (sidebar):
   * Choose **User Type**: **External**.
   * Fill out the required App Name and User Support Email.
   * Save and continue to the end.
   * Under the **Publishing status**, click **Publish App** (or leave it in Testing, but make sure to add your Google account email as a **Test User**).
5. Go to **Credentials** (sidebar):
   * Click **Create Credentials** > **OAuth client ID**.
   * Select **Application type**: **Desktop app**.
   * Click **Create**.
   * Copy the **Client ID** and **Client Secret**.

#### B. Inject Credentials into Rclone Config
You can append these credentials directly to your config file instead of going through the full setup wizard.

1. Open the config file:
   ```bash
   nano ~/.config/rclone/rclone.conf
   ```
2. Edit your `[gdrive]` block to include `client_id` and `client_secret` as shown:
   ```ini
   [gdrive]
   type = drive
   scope = drive
   client_id = YOUR_COPIED_CLIENT_ID
   client_secret = YOUR_COPIED_CLIENT_SECRET
   token = ... (leave existing token)
   ```
3. Re-authenticate rclone with your new Client ID:
   ```bash
   rclone config reconnect gdrive:
   ```
   *Follow the URL to authorize the app with your Google account. (You might see a warning screen saying the app isn't verified; click "Advanced" -> "Go to MyRcloneDrive (unsafe)" to proceed).*

4. Restart your service to apply the new client:
   ```bash
   systemctl --user restart rclone-mount.service
   ```

---

### Step 4: Adjust Nautilus Settings (Optional)
Nautilus attempts to generate thumbnails for images and videos by reading the files. Since these files are in the cloud, Nautilus must download parts of every file to generate thumbnails.

To disable this behaviour for network mounts:
1. Open **Nautilus (Files)**.
2. Go to **Preferences** (three lines menu in the top right -> Preferences).
3. Under **Search & Preview** (or **Performance**), find **Show thumbnails**.
4. Change it from "All files" to **Local files only**.
