# Setting Up Chipsailing CS9711 USB Fingerprint Scanner on Ubuntu

This document details the compatibility check, installation, and configuration steps required to use the Chipsailing CS9711 USB Fingerprint reader (`2541:0236`) on Ubuntu (specifically tested on Ubuntu 26.04 LTS).

---

## 1. Diagnostics & Hardware Status

### A. Device Identification
Running `lsusb` shows the following connected device:
```text
Bus 001 Device 005: ID 2541:0236 Chipsailing CS9711Fingprint
```
* **Vendor ID:** `2541`
* **Product ID:** `0236`

### B. Out-of-the-Box Check
Checking for recognized fingerprint devices natively:
```bash
fprintd-list "$USER"
```
* **Result:** `No devices available`
* **Implication:** The device is recognized at the USB level but lacks driver support in the mainline `libfprint` library shipped with Ubuntu.

---

## 2. Compatibility Analysis
The **Chipsailing CS9711** is not supported in the upstream/mainline `libfprint` project. To enable compatibility, you must compile and install a community-maintained, patched fork of `libfprint` that supports this specific chipset.

---

## 3. Installation & Setup

### Step 1: Install Build Dependencies
Install the required packages to build the patched driver:
```bash
sudo apt update
sudo apt install -y git build-essential cmake libglib2.0-dev libnss3-dev libpixman-1-dev libusb-1.0-0-dev meson ninja-build fprintd
```

### Step 2: Build and Install the Patched Driver
We use the automated community installer by **mmhfarooque** which compiles the driver fork and handles pinning the packages to prevent system updates from overwriting them:

```bash
# Clone the repository
git clone https://github.com/mmhfarooque/chipsailing-cs9711-fingerprint-linux.git
cd chipsailing-cs9711-fingerprint-linux

# Run the installer script
./install.sh
```

### Step 3: Verify Device Detection
Restart the fingerprint service to apply changes:
```bash
sudo systemctl restart fprintd
```
Verify that the device is now detected:
```bash
fprintd-list "$USER"
```
* **Expected Output:** You should see the Chipsailing device listed (instead of "No devices available").

### Step 4: Enroll Fingerprint
To enroll a finger for the current user:
```bash
fprintd-enroll "$USER"
```
*Press your finger repeatedly (usually 10 to 15 times) against the scanner until the process completes successfully.*

---

## 4. Enable Authentication (PAM Configuration)

Once your fingerprint is registered, you need to configure Ubuntu to accept it for authentication (e.g., login screen, lock screen, and `sudo`).

1. Open the PAM configuration menu:
   ```bash
   sudo pam-auth-update
   ```
2. Use the arrow keys to scroll to **Fingerprint authentication**.
3. Press **Spacebar** to ensure it is selected (marked with `[*]`).
4. Press **Tab** to select `<Ok>` and hit **Enter**.

Now, when prompted for a password (e.g., in a terminal for `sudo` or on your lock screen), you can use your fingerprint instead.
