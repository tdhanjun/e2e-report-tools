# E2E Report Tools

> Quick view Allure reports and Playwright trace files on macOS with Shortcuts integration

[中文文档](./README.zh-CN.md) | English

![Demo](docs/images/demo.gif)
<!-- TODO: Add demo GIF showing the Quick Actions in Finder -->

## 📋 Overview

E2E Report Tools is a macOS utility that integrates with Finder's Quick Actions to provide instant access to:

- **Allure Test Reports** - Generate and view HTML reports from test results
- **Playwright Trace Files** - Open and analyze Playwright execution traces

Simply right-click on a file in Finder and select the appropriate Quick Action - no need to open terminals or remember commands!

## ✨ Features

- 🚀 **One-Click Access** - Right-click files in Finder to generate/view reports
- 📦 **Smart Extraction** - Automatically handles `.zip`, `.tar.gz`, and nested archives
- 🔍 **Intelligent Search** - Recursively finds `allure-results` folders
- 🌐 **Auto Browser Launch** - Opens reports in your default browser automatically
- 🎯 **Port Management** - Automatically finds available ports (8000-8010)
- 🔄 **No Cache** - Always displays the latest report content
- 🛠️ **Easy Setup** - Automated environment detection and configuration

## 📦 Prerequisites

Before installation, ensure you have:

- **macOS** 12.0 or later
- **Node.js** 18.0 or later
- **Java** 11 or later (for Allure)
- **Allure** 2.0 or later

### Quick Install Dependencies

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Java
brew install openjdk@21

# Install Allure
brew install allure

# Install Node.js (if not using nvm)
brew install node
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/tdhanjun/e2e-report-tools.git
cd e2e-report-tools
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Run Setup

```bash
npm run setup
```

This command will:
- ✅ Detect your Node.js, Java, and Allure installations
- ✅ Generate a `.env` configuration file
- ✅ Set executable permissions on the script
- ✅ Display paths needed for Shortcuts configuration

Example output:

```
==================================================
E2E Report Tools Setup
==================================================

🔍 Detecting environment...

✅ Node.js: v22.14.0 (/Users/you/.nvm/versions/node/v22.14.0/bin/node)
✅ Java: openjdk version "21.0.1"
ℹ️  JAVA_HOME: /Users/you/.asdf/installs/java/openjdk-21
✅ Allure: 2.33.0 (/opt/homebrew/bin/allure)

ℹ️  Generating .env file...
✅ .env file created!
✅ Set executable permission for allure-cli.js

==================================================
Shortcuts Configuration
==================================================

📋 Use these values in your macOS Shortcuts:

NODE_BIN:
  /Users/you/.nvm/versions/node/v22.14.0/bin/node

SCRIPT_PATH:
  /Users/you/Github/e2e-report-tools/allure-tool/allure-cli.js

PROJECT_PATH:
  /Users/you/Github/e2e-report-tools

ℹ️  See shortcuts/README.md for detailed setup instructions
```

### 4. Configure macOS Shortcuts

#### Interactive Guided Setup (Recommended) 🚀

Run the interactive installer that guides you through creating shortcuts:

```bash
npm run generate-shortcuts
```

This script will:
- ✅ Guide you through opening the Shortcuts app
- ✅ Walk you through creating each shortcut step-by-step
- ✅ **Automatically copy scripts to your clipboard** - just paste!
- ✅ Show exactly what to configure for each shortcut

It takes about **2 minutes** to complete all 3 shortcuts.

> **Why not fully automatic?** macOS security prevents command-line creation of shortcuts. This guided approach is the fastest possible method!

#### Manual Configuration

If you prefer to do it yourself, follow the detailed guide in [`shortcuts/README.md`](shortcuts/README.md).

## 🎯 Usage

Once configured, using the tools is simple:

### Generate Allure Report

1. Locate your test results `.zip` file in Finder
2. **Right-click** the file
3. Select **Quick Actions** → **Generate Allure Report**
4. The report will automatically open in your browser

![Generate Report](docs/images/generate-report.png)
<!-- TODO: Add screenshot -->

### Open Existing Report

1. Locate the `report` folder in Finder
2. **Right-click** the folder
3. Select **Quick Actions** → **Open Allure Report**
4. The report will open in your browser

![Open Report](docs/images/open-report.png)
<!-- TODO: Add screenshot -->

### View Playwright Trace

1. Locate your trace `.zip` file in Finder
2. **Right-click** the file
3. Select **Quick Actions** → **Open Trace**
4. Playwright Trace Viewer will launch automatically

![Open Trace](docs/images/open-trace.png)
<!-- TODO: Add screenshot -->

## 🛠️ Command Line Usage

You can also use the tool directly from the command line:

```bash
# Generate Allure report from zip file
node allure-tool/allure-cli.js run /path/to/allure-results.zip

# Open existing report folder
node allure-tool/allure-cli.js open /path/to/report

# Open Playwright trace file
node allure-tool/allure-cli.js trace /path/to/trace.zip
```

## 📁 Project Structure

```
e2e-report-tools/
├── .env.example              # Configuration template
├── .gitignore                # Git ignore rules
├── package.json              # Project dependencies
├── setup.js                  # Environment setup script
├── README.md                 # This file (English)
├── README.zh-CN.md          # Chinese documentation
├── allure-tool/
│   └── allure-cli.js        # Main CLI tool
└── shortcuts/
    ├── README.md            # Shortcuts setup guide
    ├── install-shortcuts.sh # Installation helper
    ├── templates/           # Shortcut templates
    │   ├── generateAllureReport.template
    │   ├── openAllureReport.template
    │   └── openTrace.template
    ├── generateAllureReport  # Your original files
    ├── openAllureReport      # (for reference)
    └── openTrace
```

## 🔧 Configuration

The `.env` file contains all configuration:

```bash
# Java Configuration
JAVA_HOME=/path/to/java

# Allure Configuration
ALLURE_BIN=/path/to/allure

# Node Configuration (for Shortcuts)
NODE_BIN=/path/to/node

# Project Paths (for Shortcuts)
PROJECT_PATH=/path/to/e2e-report-tools
SCRIPT_PATH=/path/to/e2e-report-tools/allure-tool/allure-cli.js
```

These values are automatically detected and configured by `npm run setup`.

## 🐛 Troubleshooting

### Setup Issues

**Problem**: `npm run setup` reports missing dependencies

**Solution**: Install the missing software:

```bash
# For Java
brew install openjdk@21

# For Allure
brew install allure
```

---

**Problem**: Wrong Java version detected

**Solution**: Set `JAVA_HOME` manually:

```bash
# Find Java installations
/usr/libexec/java_home -V

# Set JAVA_HOME to desired version
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
```

### Shortcuts Issues

**Problem**: Shortcuts not appearing in Quick Actions

**Solution**: 
1. Open **System Settings** → **Extensions** → **Finder**
2. Enable your shortcuts under **Quick Actions**

---

**Problem**: Permission denied errors

**Solution**:
1. Go to **System Settings** → **Privacy & Security** → **Automation**
2. Enable **Shortcuts** to control **Finder**
3. Go to **Privacy & Security** → **Files and Folders**
4. Grant **Shortcuts** access to necessary folders

---

**Problem**: Script execution fails

**Solution**: Check the log file:

```bash
tail -f /tmp/allure-cli.log
```

### Runtime Issues

**Problem**: "Configuration missing" error

**Solution**: Run the setup again:

```bash
npm run setup
```

---

**Problem**: Port already in use

**Solution**: The tool automatically finds available ports (8000-8010). If all ports are busy, close other services or change the port range in `allure-tool/allure-cli.js`.

---

**Problem**: Report shows old data

**Solution**: The server is configured with no-cache headers. Try:
1. Hard refresh your browser (Cmd+Shift+R)
2. Clear browser cache
3. Restart the script

## 📝 Advanced Usage

### Viewing Configuration

Display current configuration values:

```bash
npm run shortcuts-info
```

### Manual Path Configuration

If automatic detection fails, manually edit `.env`:

```bash
cp .env.example .env
# Edit .env with your preferred text editor
nano .env
```

### Customizing Port Range

Edit `allure-tool/allure-cli.js`:

```javascript
const BASE_PORT = 8000;  // Change start port
const MAX_PORT = 8010;   // Change end port
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Allure Framework](https://docs.qameta.io/allure/) - Beautiful test reporting
- [Playwright](https://playwright.dev/) - Modern web testing framework
- macOS Shortcuts - Automation on macOS

## 📮 Contact

- GitHub: [@tdhanjun](https://github.com/tdhanjun)
- Issues: [Report a bug](https://github.com/tdhanjun/e2e-report-tools/issues)

---

**Happy Testing!** 🎉
