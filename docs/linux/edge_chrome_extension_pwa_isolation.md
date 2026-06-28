# Knowledge Base: Isolating Chromium Extension Apps on Linux (Wayland/X11)

This document provides a guide on how to configure Chromium-based browsers (such as Microsoft Edge or Google Chrome) to run extension-based apps (like the **LINE messenger extension**) as separate, standalone windows that do not stack with the main browser or other web apps in the taskbar/dock, while maintaining custom application launcher icons.

---

## 1. The Core Issues

### A. Singleton/Single-Instance Process Sharing
Chromium uses a single-process multi-window architecture. When launching a PWA or extension shortcut, the browser checks if a process using the same profile is already running. If it is, the launch is delegated to the running process. As a result:
* The window inherits the `app_id` or `WM_CLASS` of the first process started (e.g., grouping LINE under Gemini or the main browser).
* Window grouping overrides are discarded, making taskbar separation impossible.

### B. Wayland vs. X11 Window Class Matching
* **Wayland Native**: Compositors group windows and match icons based on the `app_id` (which must match the `.desktop` filename). In Chromium, the `app_id` cannot easily be overridden via CLI flags.
* **XWayland (X11)**: Window managers match windows to launchers using the `StartupWMClass` key. Under X11, Chromium allows overriding this using the `--class` command-line flag.

---

## 2. The Comprehensive Solution

To guarantee complete taskbar separation and correct icon mapping, the application must be isolated in its own **user data directory** and forced to run under **XWayland** with a custom class identifier.

### Step 1: Install the Icon in the System Theme
Taskbars and dock extensions often fail to render icons specified by absolute file paths. Installing the icon to the standard `hicolor` user icon theme resolves this.

1. Create the application icon directory:
   ```bash
   mkdir -p ~/.local/share/icons/hicolor/128x128/apps
   ```
2. Copy the high-resolution PNG icon (for example, extracted from the Edge extension folder) to this directory, renaming it to match the application ID:
   ```bash
   cp /path/to/extracted/icon.png ~/.local/share/icons/hicolor/128x128/apps/msedge-ophjlpahpchlmihnnnihgmmeilfjmjjc-Default.png
   ```
3. Update the system icon cache:
   ```bash
   gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor
   ```

### Step 2: Create a Launch Wrapper Script
Since we are isolating the application in a new profile folder (`~/.config/microsoft-edge-line`), the extension will not be present on the very first launch. A wrapper script automatically handles first-run installation and launches the standalone app on subsequent runs.

Create a script at `~/.local/share/applications/launch-line.sh`:
```bash
#!/bin/bash
USER_DATA_DIR="$HOME/.config/microsoft-edge-line"
EXTENSION_ID="ophjlpahpchlmihnnnihgmmeilfjmjjc"

# Check if the extension is installed in the profile
if [ ! -d "$USER_DATA_DIR/Default/Extensions/$EXTENSION_ID" ]; then
    # First run: open the extension install page on the Chrome Web Store
    /opt/microsoft/msedge/microsoft-edge --user-data-dir="$USER_DATA_DIR" --no-first-run "https://chromewebstore.google.com/detail/line/ophjlpahpchlmihnnnihgmmeilfjmjjc"
else
    # Subsequent runs: launch standalone in XWayland mode with custom class
    /opt/microsoft/msedge/microsoft-edge --user-data-dir="$USER_DATA_DIR" --ozone-platform=x11 --class=msedge-line --app="chrome-extension://$EXTENSION_ID/index.html"
fi
```
Make the script executable:
```bash
chmod +x ~/.local/share/applications/launch-line.sh
```

### Step 3: Create/Update the `.desktop` File
Create the launcher at `~/.local/share/applications/msedge-ophjlpahpchlmihnnnihgmmeilfjmjjc-Default.desktop` with the following configuration:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=LINE (Edge)
Comment=LINE Messenger standalone instance via Microsoft Edge
Icon=msedge-ophjlpahpchlmihnnnihgmmeilfjmjjc-Default
Exec=/home/devildogtg/.local/share/applications/launch-line.sh
Categories=Network;InstantMessaging;
StartupWMClass=msedge-line
MimeType=x-scheme-handler/line;
```

* **`Icon`**: Points to the themed icon name `msedge-ophjlpahpchlmihnnnihgmmeilfjmjjc-Default` from **Step 1**.
* **`Exec`**: Calls the wrapper script from **Step 2**.
* **`StartupWMClass`**: Matches the `--class=msedge-line` argument passed to Microsoft Edge, ensuring the window and launcher map correctly.

### Step 4: Refresh the Launcher Database
Index the new `.desktop` file:
```bash
update-desktop-database ~/.local/share/applications
```

### Step 5: Reload GNOME Shell Cache
Because GNOME Shell caches the launcher menu in memory, **log out of the Linux user session and log back in** (or restart the computer) to apply the changes to the application grid view.
