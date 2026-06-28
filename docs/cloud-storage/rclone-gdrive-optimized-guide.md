# Optimized Google Drive Mount Guide (Ubuntu 26)

This guide documents the optimized setup for mounting Google Drive via `rclone` and how to manage and maintain it.

---

## 🚀 Optimization Overview

We resolved the lag, freeze, and rate-limiting issues by implementing three key solutions:

1.  **Custom API Credentials**: Replaced rclone's shared Client ID with your own Google Developer credentials. You now have a private API quota of 10,000 queries per 100 seconds.
2.  **Long-term Metadata Caching**: Programmed rclone to cache directory structures and file attributes for **1000 hours** (`--dir-cache-time 1000h --attr-timeout 1000h`). Since rclone polls Google Drive for changes every 1 minute (`--poll-interval 1m`), your local cache stays perfectly in sync without constantly querying Google's API.
3.  **Indexing Prevention**: Blocked Ubuntu's file indexer (`localsearch-3`) from scanning the mount point by adding the directory to the GNOME ignored-directories schema and placing `.trackerignore` / `.nomedia` files in the root folder.

---

## ⚙️ Active Configuration

Your systemd user service file is located at:
📁 `~/.config/systemd/user/rclone-mount.service`

### Service Content
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

---

## 🛠️ Management Commands

Run these commands in your terminal (no `sudo` required as this is a user service):

### Start the Mount
```bash
systemctl --user start rclone-mount.service
```

### Stop the Mount
```bash
systemctl --user stop rclone-mount.service
```

### Restart the Mount
```bash
systemctl --user restart rclone-mount.service
```

### Check Service Status
```bash
systemctl --user status rclone-mount.service
```

### Check Live Mount Logs
```bash
journalctl --user -u rclone-mount.service -f
```

---

## 🩺 Troubleshooting & Maintenance

### 1. Error: `Fatal error: directory already mounted`
If rclone fails to start with this error, it means a previous mount process terminated uncleanly and left the directory locked.

**Solution:** Force-unmount the mount point and restart the service:
```bash
# Unmount the mount point
fusermount3 -u ~/google-drive

# Restart the service
systemctl --user restart rclone-mount.service
```

---

### 2. Token Expired or Re-authentication Needed
If rclone loses access to your Drive or you need to refresh your credentials:

1. Stop the mount:
   ```bash
   systemctl --user stop rclone-mount.service
   ```
2. Re-authenticate:
   ```bash
   rclone config reconnect gdrive:
   ```
3. Follow the browser prompt (click **Advanced** -> **Go to <project> (unsafe)** -> **Allow**).
4. Restart the mount:
   ```bash
   systemctl --user start rclone-mount.service
   ```

*Note: If the authentication page displays "Access blocked" without the "Advanced" option, go to the [Google Cloud Console](https://console.cloud.google.com/) -> **OAuth consent screen** and make sure either the app is set to **Publish App** (Production) or your email is added under the **Test users** section.*

---

### 3. Disabling File manager Thumbnails (Recommended)
If you browse folders containing large images or videos, Nautilus may try to download parts of each file to create thumbnails, causing delays.

To turn this off for cloud mounts:
1. Open **Files (Nautilus)**.
2. Open **Preferences** (menu on the top-right).
3. Under **Search & Preview** (or **Performance**), change **Show thumbnails** to **Local files only**.
