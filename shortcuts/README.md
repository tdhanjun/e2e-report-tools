# macOS Shortcuts Configuration Guide

This folder contains templates and instructions for setting up macOS Shortcuts to quickly view Allure reports and Playwright trace files.

## 📋 Available Shortcuts

1. **Generate Allure Report** - Extract zip file and generate Allure HTML report
2. **Open Allure Report** - Open an existing Allure report folder
3. **Open Trace** - View Playwright trace files

## 🚀 Quick Setup

### ⭐ Option 1: Fully Automated (Recommended)

The easiest way to install shortcuts:

```bash
npm run generate-shortcuts
```

This creates three `.shortcut` files in this folder:
- `Generate Allure Report.shortcut`
- `Open Allure Report.shortcut`
- `Open Trace.shortcut`

**To install**: Simply **double-click each file** in Finder!

macOS will open the Shortcuts app and ask if you want to add the shortcut. Click "Add Shortcut" (or "添加快捷指令" in Chinese).

**That's it!** The shortcuts are now installed and will appear in Finder's Quick Actions menu.

> **Note**: The first time you run a shortcut, macOS may ask for permissions to:
> - Run shell scripts
> - Access files in Finder
> 
> Click "Allow" or "Always Allow" when prompted.

---

### Option 2: Semi-Automated Setup

Run the installation script:

```bash
npm run install-shortcuts
```

This will generate configured shortcut files in the `shortcuts/` folder with your paths already filled in.

### Option 2: Manual Setup

If automatic setup doesn't work, follow these steps:

#### Step 1: Get Configuration Values

Run this command to display the paths you'll need:

```bash
npm run shortcuts-info
```

You'll see output like:
```
NODE_BIN: /Users/yourname/.nvm/versions/node/v22.14.0/bin/node
SCRIPT_PATH: /Users/yourname/path/to/e2e-report-tools/allure-tool/allure-cli.js
PROJECT_PATH: /Users/yourname/path/to/e2e-report-tools
```

**Copy these values** - you'll need them in the next steps.

---

#### Step 2: Create Shortcuts

For each shortcut, follow these steps:

##### 1️⃣ Generate Allure Report

1. Open **Shortcuts** app on your Mac
2. Click **"+"** to create a new shortcut
3. Name it: `Generate Allure Report`
4. Add action: Search for **"Receive input from"** → Select **"Shortcuts"**
   - Change input type to: **Files**
5. Add action: Search for **"Run Shell Script"**
   - Configure as follows:

```bash
# Give script execute permission
chmod +x "/path/to/e2e-report-tools/allure-tool/allure-cli.js"

# Run the script with the file path
"/path/to/node" "/path/to/e2e-report-tools/allure-tool/allure-cli.js" run "$1" >> /tmp/allure-cli.log 2>&1
```

**Replace the paths** with your values from Step 1:
- `/path/to/node` → Your `NODE_BIN` value
- `/path/to/e2e-report-tools/allure-tool/allure-cli.js` → Your `SCRIPT_PATH` value

**Shell Script Settings:**
- Shell: `bash`
- Input: `Shortcut Input`
- Pass input: `as arguments`

6. Click **ⓘ (Details)** in the top right:
   - ✅ Enable **"Use as Quick Action"**
   - ✅ Check **"Finder"**
   - ✅ Check **"Services Menu"**
   - ✅ Enable **"Show in Spotlight"**

7. Click **Privacy** (if shown):
   - ✅ Allow this shortcut to access: **Shell**
   - When prompted: Allow **Run Shell Script** to use **Finder** (Always Allow)

8. Done! ✅

---

##### 2️⃣ Open Allure Report

Follow the same steps as above, but:
- Name it: `Open Allure Report`
- Input type: **Folders** (not Files)
- Shell script:

```bash
chmod +x "/path/to/e2e-report-tools/allure-tool/allure-cli.js"

"/path/to/node" "/path/to/e2e-report-tools/allure-tool/allure-cli.js" open "$1" >> /tmp/allure-cli.log 2>&1
```

---

##### 3️⃣ Open Trace

Follow the same steps as Generate Allure Report, but:
- Name it: `Open Trace`
- Input type: **Files**
- Shell script:

```bash
chmod +x "/path/to/e2e-report-tools/allure-tool/allure-cli.js"

echo "=== START SHORTCUT TRACE ===" >> /tmp/allure-cli.log
echo "[Shortcut] raw args: $@" >> /tmp/allure-cli.log
echo "[Shortcut] arg count: $#" >> /tmp/allure-cli.log

export PATH="$(dirname /path/to/node):/usr/local/bin:/usr/bin:/bin:$PATH"
tracePath="$1"
echo "[Shortcut] tracePath received: $tracePath" >> /tmp/allure-cli.log

"/path/to/node" "/path/to/e2e-report-tools/allure-tool/allure-cli.js" trace "$tracePath" >> /tmp/allure-cli.log 2>&1
```

---

## 📸 Screenshots

<!-- TODO: Add screenshots of the Shortcuts app configuration -->

### Creating a Shortcut
![Create Shortcut](images/create-shortcut.png)

### Configuring Shell Script
![Configure Shell Script](images/configure-shell.png)

### Quick Action Settings
![Quick Action Settings](images/quick-action.png)

---

## 🎯 Usage

Once configured, you can use the shortcuts in Finder:

1. **Right-click** on a file or folder
2. Select **Quick Actions**
3. Choose the appropriate shortcut:
   - `Generate Allure Report` - for `.zip` files containing test results
   - `Open Allure Report` - for existing `report` folders
   - `Open Trace` - for `.zip` files containing Playwright traces

![Usage Example](images/usage-example.png)

---

## 🔧 Troubleshooting

### Shortcuts not appearing in Quick Actions

1. Go to **System Settings** → **Extensions** → **Finder**
2. Make sure your shortcuts are enabled in the **Quick Actions** section

### Permission errors

If you get permission errors:
1. Go to **System Settings** → **Privacy & Security** → **Automation**
2. Find **Shortcuts** and ensure it has permission to control **Finder**
3. Go to **Privacy & Security** → **Files and Folders**
4. Ensure **Shortcuts** has access to the necessary folders

### Script not running

Check the log file for errors:
```bash
tail -f /tmp/allure-cli.log
```

### Node.js not found

Make sure the `NODE_BIN` path is correct:
```bash
which node
```

If the path is different, update your shortcuts with the correct path.

---

## 📝 Notes

- These shortcuts only work on **macOS**
- Requires the **Shortcuts** app (built-in on macOS 12+)
- Shortcuts need to be manually created - macOS doesn't support programmatic shortcut installation
- The paths are **absolute** and specific to your machine

---

## 🆘 Need Help?

If you encounter issues:
1. Check the [main README](../README.md) for general setup instructions
2. Verify your environment with `npm run setup`
3. Check the logs at `/tmp/allure-cli.log`
4. Create an issue on [GitHub](https://github.com/tdhanjun/e2e-report-tools/issues)
