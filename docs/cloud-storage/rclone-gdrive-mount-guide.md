# Guide: Mounting Google Drive with Rclone

This guide explains how to mount your Google Drive remote (`gdrive:`) to a local directory (`~/google-drive`) and ensure it mounts automatically on system startup.

## 1. Preparation

First, ensure the mount point exists:

```bash
mkdir -p ~/google-drive
```

Ensure `fuse3` is installed (required for mounting):

```bash
sudo apt update && sudo apt install -y fuse3
```

## 2. Manual Mount (Testing)

Before setting up auto-mount, test the connection manually:

```bash
rclone mount gdrive: ~/google-drive --vfs-cache-mode writes
```

*   **Note:** This command will "hang" the terminal while the drive is mounted.
*   **Verification:** Open a new terminal tab and run `ls ~/google-drive` to see your files.
*   **Stop:** Press `Ctrl+C` in the first terminal to unmount.

## 3. Persistent Auto-Mount (Systemd)

To make the mount survive reboots, we will create a user-level Systemd service.

### Step A: Create the Service File

Create the directory for user services:
```bash
mkdir -p ~/.config/systemd/user/
```

Create the file `~/.config/systemd/user/rclone-mount.service` with the following content:

```ini
[Unit]
Description=RClone Mount Google Drive
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
# Ensure the path to rclone is correct (usually /usr/bin/rclone)
ExecStart=/usr/bin/rclone mount gdrive: %h/google-drive \
    --config %h/.config/rclone/rclone.conf \
    --vfs-cache-mode full \
    --vfs-cache-max-age 24h \
    --vfs-cache-max-size 10G \
    --allow-other
ExecStop=/bin/fusermount -u %h/google-drive
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

### Step B: Enable and Start

Run these commands to register and start the service:

```bash
# Reload systemd configuration
systemctl --user daemon-reload

# Enable the service to start on login
systemctl --user enable rclone-mount.service

# Start the service now
systemctl --user start rclone-mount.service
```

### Step C: Optional - Start on Boot (Without Login)

By default, user services start only when you log in. If you want the drive to mount as soon as the server boots (even if you haven't logged in via SSH/GUI yet), run:

```bash
sudo loginctl enable-linger $USER
```

## 4. Useful Commands

*   **Check status:** `systemctl --user status rclone-mount.service`
*   **Stop mount:** `systemctl --user stop rclone-mount.service`
*   **Restart mount:** `systemctl --user restart rclone-mount.service`
*   **View logs:** `journalctl --user -u rclone-mount.service -f`

## 5. Troubleshooting

If the mount fails:
1.  **Mount folder not empty:** Ensure `~/google-drive` is empty before starting the service.
2.  **FUSE error:** If you see `fusermount: command not found`, install `fuse3`.
3.  **Permissions:** If you can't access files, ensure `--allow-other` is in the service file and `/etc/fuse.conf` has `user_allow_other` uncommented.
