# Troubleshooting RDP Connection Issues on Ubuntu (gnome-remote-desktop)

This document details the diagnostic steps, root cause, and resolution for the Remote Desktop (RDP) connection issue from a Windows client to an Ubuntu machine.

---

## 1. Symptoms
* The Windows RDP client is able to successfully `ping` the Ubuntu host's IP address.
* The Windows client fails to establish a Remote Desktop connection to port `3389`.
* On the Ubuntu host, the "Remote Login" option under **Settings > System > Remote Desktop** is toggled **ON**, but connection attempts still fail.

---

## 2. Diagnostics & Findings

### A. Port Verification
Initially, checking active TCP listeners on port `3389` returned no results:
```bash
ss -tulpn | grep -E '3389|rdp'
```
* **Result:** Empty. The remote desktop service was not actively listening for incoming connections on the standard RDP port.

### B. System Service Status
Checking the status of the `gnome-remote-desktop` system service:
```bash
systemctl status gnome-remote-desktop.service
```
* **Result:** The service was marked as `active (running)`. However, looking at the logs:
  ```
  gnome-remote-desktop-daemon[6058]: [DaemonSystem] Error connecting to display manager: GDBus.Error:org.freedesktop.DBus.Error.UnknownMethod: Object does not exist at path “/org/gnome/DisplayManager/Displays”
  ```
* **Implication:** The daemon successfully ran, but failed to register the RDP session broker/handover mechanism because it could not communicate with GNOME Display Manager (GDM).

---

## 3. Root Cause
During the system boot sequence, a race condition occurred between `gnome-remote-desktop.service` and `gdm.service`. Because the remote desktop service lacked explicit startup ordering dependencies in its default package configuration, it attempted to launch and connect to DBus endpoints before GDM was fully initialized. As a result, the RDP listener failed to start.

---

## 4. Resolution

### Step 1: Add systemd Ordering Dependency
To ensure `gnome-remote-desktop` always starts after `gdm.service` is ready, create a systemd configuration override:

1. Create the override directory (if it doesn't exist):
   ```bash
   sudo mkdir -p /etc/systemd/system/gnome-remote-desktop.service.d
   ```
2. Create or edit `/etc/systemd/system/gnome-remote-desktop.service.d/override.conf` with the following contents:
   ```ini
   [Unit]
   After=gdm.service
   ```
3. Reload systemd daemon configuration to apply changes:
   ```bash
   sudo systemctl daemon-reload
   ```

### Step 2: Restart the Service
Restart the service to verify the RDP daemon initializes correctly:
```bash
sudo systemctl restart gnome-remote-desktop.service
```

### Step 3: Verify listener
Verify that the service is now listening on the network:
```bash
ss -tulpn | grep -E '3389|rdp'
```
* **Expected Output:**
  ```text
  tcp   LISTEN 0      5                                       *:3389             *:*
  ```

---

## 5. Connection Reference
* **Ubuntu Host IP:** `192.168.10.75`
* **Default Port:** `3389`
* **Username:** `devildogtg`
* **Authentication Method:** Password set via Ubuntu System Settings.
