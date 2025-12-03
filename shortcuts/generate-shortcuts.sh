#!/bin/bash

# ==============================================
# macOS Shortcuts Helper
# ==============================================
# This script generates ready-to-copy shortcut scripts
# and provides an easy copy-paste workflow
# ==============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}${BOLD}=================================================="
    echo -e "$1"
    echo -e "==================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${BOLD}$1${NC}"
}

# 检查 .env 文件
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    echo ""
    print_info "Please run 'npm run setup' first."
    exit 1
fi

# 加载环境变量
export $(grep -v '^#' .env | xargs)

print_header "macOS Shortcuts Installation Helper"
echo ""

print_warning "macOS does not support automatic shortcut creation via command line."
print_info "However, this script makes the process as easy as possible!"
echo ""

print_step "📋 Step 1: Open the Shortcuts app"
echo ""
echo "Press any key when Shortcuts app is open..."
read -n 1 -s
echo ""

print_step "📋 Step 2: Create shortcuts one by one"
echo ""
print_info "We'll guide you through creating 3 shortcuts."
print_info "For each shortcut, we'll copy the script to your clipboard."
print_info "You just need to paste it in the Shortcuts app!"
echo ""

# Shortcut 1: Generate Allure Report
print_header "Shortcut 1: Generate Allure Report"
echo ""
print_info "1. In Shortcuts app, click '+' to create a new shortcut"
print_info "2. Name it: ${BOLD}Generate Allure Report${NC}"
print_info "3. Search for 'Run Shell Script' action and add it"
print_info "4. We'll copy the script to clipboard - just paste it!"
echo ""
echo "Press any key to copy the script to clipboard..."
read -n 1 -s

SCRIPT1="chmod +x \"${SCRIPT_PATH}\"
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" run \"\$@\" >> /tmp/allure-cli.log 2>&1"

echo "$SCRIPT1" | pbcopy

print_success "Script copied to clipboard! Now:"
echo ""
echo "  5. Paste (Cmd+V) into the 'Run Shell Script' action"
echo "  6. Set Shell: bash"
echo "  7. Set Input: Shortcut Input"  
echo "  8. Set Pass input: as arguments"
echo "  9. Click (i) Details → Enable 'Use as Quick Action'"
echo "  10. Check 'Finder' and 'Services Menu'"
echo ""
echo "Press any key when done..."
read -n 1 -s
echo ""
print_success "Shortcut 1 created!"
echo ""

# Shortcut 2: Open Allure Report
print_header "Shortcut 2: Open Allure Report"
echo ""
print_info "Creating second shortcut..."
echo ""
print_info "1. Click '+' again to create a new shortcut"
print_info "2. Name it: ${BOLD}Open Allure Report${NC}"
print_info "3. Add 'Run Shell Script' action"
echo ""
echo "Press any key to copy the script..."
read -n 1 -s

SCRIPT2="chmod +x \"${SCRIPT_PATH}\"
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" open \"\$@\" >> /tmp/allure-cli.log 2>&1"

echo "$SCRIPT2" | pbcopy

print_success "Script copied! Paste and configure the same way."
echo ""
echo "Press any key when done..."
read -n 1 -s
echo ""
print_success "Shortcut 2 created!"
echo ""

# Shortcut 3: Open Trace
print_header "Shortcut 3: Open Trace"
echo ""
print_info "Last one!"
echo ""
print_info "1. Click '+' to create the final shortcut"
print_info "2. Name it: ${BOLD}Open Trace${NC}"
print_info "3. Add 'Run Shell Script' action"
echo ""
echo "Press any key to copy the script..."
read -n 1 -s

SCRIPT3="chmod +x \"${SCRIPT_PATH}\"
echo \"=== START TRACE ===\" >> /tmp/allure-cli.log
export PATH=\"\$(dirname ${NODE_BIN}):/usr/local/bin:/usr/bin:/bin:\$PATH\"
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" trace \"\$@\" >> /tmp/allure-cli.log 2>&1"

echo "$SCRIPT3" | pbcopy

print_success "Script copied! Paste and configure the same way."
echo ""
echo "Press any key when done..."
read -n 1 -s
echo ""
print_success "Shortcut 3 created!"
echo ""

print_header "🎉 All Done!"
echo ""
print_success "You've successfully created all 3 shortcuts!"
echo ""
print_info "Now you can right-click files in Finder and use Quick Actions:"
echo ""
echo "  • Generate Allure Report - for .zip test results"
echo "  • Open Allure Report - for report folders"
echo "  • Open Trace - for Playwright trace files"
echo ""
print_success "Enjoy! 🚀"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}=================================================="
    echo -e "$1"
    echo -e "==================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 检查 .env 文件
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    echo ""
    print_info "Please run 'npm run setup' first."
    exit 1
fi

# 加载环境变量
export $(grep -v '^#' .env | xargs)

print_header "macOS Shortcuts Generator"
echo ""

# 生成 .shortcut 文件的函数
generate_shortcut_plist() {
    local name="$1"
    local description="$2"
    local shell_script="$3"
    local input_type="$4"  # "Files" or "Folders"
    
    cat > "/tmp/${name}.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>WFWorkflowActions</key>
    <array>
        <dict>
            <key>WFWorkflowActionIdentifier</key>
            <string>is.workflow.actions.runshellscript</string>
            <key>WFWorkflowActionParameters</key>
            <dict>
                <key>WFInputMethod</key>
                <string>Input</string>
                <key>WFShellScriptActionRunAsAdministrator</key>
                <false/>
                <key>WFShellScriptActionScript</key>
                <string>${shell_script}</string>
                <key>WFShellScriptActionSource</key>
                <string>Inline</string>
            </dict>
        </dict>
    </array>
    <key>WFWorkflowClientRelease</key>
    <string>900</string>
    <key>WFWorkflowClientVersion</key>
    <string>2601</string>
    <key>WFWorkflowIcon</key>
    <dict>
        <key>WFWorkflowIconGlyphNumber</key>
        <integer>59511</integer>
        <key>WFWorkflowIconStartColor</key>
        <integer>431817727</integer>
    </dict>
    <key>WFWorkflowImportQuestions</key>
    <array/>
    <key>WFWorkflowInputContentItemClasses</key>
    <array>
        <string>WFGenericFileContentItem</string>
    </array>
    <key>WFWorkflowMinimumClientRelease</key>
    <integer>900</integer>
    <key>WFWorkflowMinimumClientVersion</key>
    <string>900</string>
    <key>WFWorkflowName</key>
    <string>${name}</string>
    <key>WFWorkflowTypes</key>
    <array>
        <string>ActionExtension</string>
    </array>
</dict>
</plist>
EOF
}

print_info "Generating .shortcut files..."
echo ""

# 1. Generate Allure Report
SCRIPT1="chmod +x \"${SCRIPT_PATH}\"
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" run \"\$1\" >> /tmp/allure-cli.log 2>&1"

print_info "Creating: Generate Allure Report.shortcut"
generate_shortcut_plist "Generate Allure Report" \
    "Generate Allure HTML report from test results" \
    "$SCRIPT1" \
    "Files"

# 使用 shortcuts sign 来创建可导入的文件
shortcuts sign --mode anyone \
    --input "/tmp/Generate Allure Report.plist" \
    --output "shortcuts/Generate Allure Report.shortcut" 2>/dev/null || {
    print_warning "Could not sign shortcut. Will create unsigned version."
    cp "/tmp/Generate Allure Report.plist" "shortcuts/Generate Allure Report.shortcut"
}

print_success "Generated: Generate Allure Report.shortcut"

# 2. Open Allure Report
SCRIPT2="chmod +x \"${SCRIPT_PATH}\"
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" open \"\$1\" >> /tmp/allure-cli.log 2>&1"

print_info "Creating: Open Allure Report.shortcut"
generate_shortcut_plist "Open Allure Report" \
    "Open an existing Allure report folder" \
    "$SCRIPT2" \
    "Folders"

shortcuts sign --mode anyone \
    --input "/tmp/Open Allure Report.plist" \
    --output "shortcuts/Open Allure Report.shortcut" 2>/dev/null || {
    cp "/tmp/Open Allure Report.plist" "shortcuts/Open Allure Report.shortcut"
}

print_success "Generated: Open Allure Report.shortcut"

# 3. Open Trace
SCRIPT3="chmod +x \"${SCRIPT_PATH}\"
echo \"=== START SHORTCUT TRACE ===\" >> /tmp/allure-cli.log
echo \"[Shortcut] raw args: \$@\" >> /tmp/allure-cli.log
export PATH=\"\$(dirname ${NODE_BIN}):/usr/local/bin:/usr/bin:/bin:\$PATH\"
tracePath=\"\$1\"
echo \"[Shortcut] tracePath received: \$tracePath\" >> /tmp/allure-cli.log
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" trace \"\$tracePath\" >> /tmp/allure-cli.log 2>&1"

print_info "Creating: Open Trace.shortcut"
generate_shortcut_plist "Open Trace" \
    "View Playwright trace files" \
    "$SCRIPT3" \
    "Files"

shortcuts sign --mode anyone \
    --input "/tmp/Open Trace.plist" \
    --output "shortcuts/Open Trace.shortcut" 2>/dev/null || {
    cp "/tmp/Open Trace.plist" "shortcuts/Open Trace.shortcut"
}

print_success "Generated: Open Trace.shortcut"

# 清理临时文件
rm -f /tmp/*.plist

echo ""
print_header "Installation Instructions"
echo ""
print_success "Three .shortcut files have been created in the shortcuts/ folder:"
echo ""
echo "  1. Generate Allure Report.shortcut"
echo "  2. Open Allure Report.shortcut"
echo "  3. Open Trace.shortcut"
echo ""
print_info "To install, simply double-click each .shortcut file!"
echo ""
print_info "macOS will open the Shortcuts app and prompt you to add the shortcut."
print_info "Click 'Add Shortcut' for each one."
echo ""
print_warning "Note: You may need to grant permissions for the shortcuts to:"
echo "  - Run shell scripts"
echo "  - Access files in Finder"
echo ""
print_success "Setup complete! 🎉"
echo ""
