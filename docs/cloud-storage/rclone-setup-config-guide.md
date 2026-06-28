# Guide: Installing and Configuring Rclone on Ubuntu

This guide covers the initial installation of rclone using the official Ubuntu repositories and the step-by-step configuration for Google Drive.

## 1. Installation

Using the official Ubuntu repository ensures that `rclone` is managed by your system's package manager (`apt`).

```bash
# Update your package list
sudo apt update

# Install rclone
sudo apt install -y rclone
```

*Note: The version in the Ubuntu repository may be older than the version on rclone.org, but it is stable and well-integrated with the system.*

## 2. Configuration for Google Drive

Rclone uses an interactive setup process called `rclone config`.

1.  **Start the configuration:**
    ```bash
    rclone config
    ```

2.  **Create a New Remote:**
    *   Type **`n`** for "New remote".
    *   **name>**: Type `gdrive` (or your preferred name).

3.  **Select Storage Type:**
    *   Look for "Google Drive" in the list.
    *   **Storage>**: Type `drive` (or the number corresponding to Google Drive).

4.  **Client ID & Secret:**
    *   **client_id>**: Leave blank (Press `Enter`).
    *   **client_secret>**: Leave blank (Press `Enter`).
    *   *Note: For better performance/reliability, you can later create your own Google Cloud Console credentials, but defaults work for starters.*

5.  **Select Scope:**
    *   Choose option **`1`** (`drive`) for full access to all files.

6.  **Service Account File:**
    *   **service_account_file>**: Leave blank (Press `Enter`).

7.  **Advanced Config:**
    *   **Edit advanced config?**: Type **`n`** (No).

8.  **Authentication (OAuth):**
    *   **Use auto config?**:
        *   Type **`y`** if you are on a computer with a web browser. It will open a browser window for you to log in.
        *   Type **`n`** if you are on a remote server (SSH). It will give you a link to copy into your local browser, then you must paste the resulting code back into the terminal.

9.  **Configure as Shared Drive? (Optional):**
    *   **Configure this as a Shared Drive (Team Drive)?**: Type **`n`** unless you are specifically connecting to a Google Workspace Shared Drive.

10. **Finalize:**
    *   Verify the details and type **`y`** (Yes this is OK).
    *   Type **`q`** to quit the config menu.

## 3. Verifying the Connection

Test that rclone can see your drive:

```bash
# List all top-level directories in your Google Drive
rclone lsd gdrive:
```

If you see your Google Drive folders listed, the configuration was successful!

## 4. Basic Management

*   **List files:** `rclone ls gdrive:`
*   **Check config file location:** `rclone config file` (Usually `~/.config/rclone/rclone.conf`)
*   **Update rclone (via apt):** `sudo apt update && sudo apt upgrade rclone`
