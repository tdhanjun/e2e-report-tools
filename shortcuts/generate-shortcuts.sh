#!/bin/bash

# ==============================================
# macOS Shortcuts Helper
# ==============================================
# This script generates ready-to-copy shortcut scripts
# and provides an easy copy-paste workflow
# ==============================================

set -e

# color map
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

# check .env
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    echo ""
    print_info "Please run 'npm run setup' first."
    exit 1
fi

# load env
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
print_info "1. In Shortcuts app, click '+' to create a new Quick Actions"
print_info "2. Name it: ${BOLD}Generate Allure Report${NC}"
print_info "3. Search for 'Run Shell Script' action and add it"
print_info "4. We'll copy the script to clipboard - just paste it!"
echo ""
echo "Press any key to copy the script to clipboard..."
read -n 1 -s

SCRIPT1="# Execute the report generator
chmod +x \"${SCRIPT_PATH}\"
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" run \"\$@\" >> \"${PROJECT_PATH}/logs/allure-cli.log\" 2>&1"

printf "%s" "$SCRIPT1" | /usr/bin/pbcopy

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

SCRIPT2="# Open the report
chmod +x \"${SCRIPT_PATH}\"
\"${NODE_BIN}\" \"${SCRIPT_PATH}\" open \"\$@\" >> \"${PROJECT_PATH}/logs/allure-cli.log\" 2>&1"

printf "%s" "$SCRIPT2" | /usr/bin/pbcopy

print_success "Script copied to clipboard! Now:"
echo ""
echo "  4. Paste (Cmd+V) into the 'Run Shell Script' action"
echo "  5. Set Shell: bash"
echo "  6. Set Input: Shortcut Input"
echo "  7. Set Pass input: as arguments"
echo "  8. Click (i) Details → Enable 'Use as Quick Action'"
echo "  9. Check 'Finder' and 'Services Menu'"
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

SCRIPT3="# Set PATH to include Node.js binaries (needed for npx)
export PATH=\"\$(dirname ${NODE_BIN}):/usr/local/bin:/usr/bin:/bin:\$PATH\"

# Open Playwright trace
chmod +x \"${SCRIPT_PATH}\"
echo \"=== START TRACE ===\" >> \"${PROJECT_PATH}/logs/allure-cli.log\"

tracePath=\"\$1\"
echo \"[Shortcut] tracePath: \$tracePath\" >> \"${PROJECT_PATH}/logs/allure-cli.log\"

\"${NODE_BIN}\" \"${SCRIPT_PATH}\" trace \"\$tracePath\" >> \"${PROJECT_PATH}/logs/allure-cli.log\" 2>&1"

printf "%s" "$SCRIPT3" | /usr/bin/pbcopy

print_success "Script copied to clipboard! Now:"
echo ""
echo "  4. Paste (Cmd+V) into the 'Run Shell Script' action"
echo "  5. Set Shell: bash"
echo "  6. Set Input: Shortcut Input"
echo "  7. Set Pass input: as arguments"
echo "  8. Click (i) Details → Enable 'Use as Quick Action'"
echo "  9. Check 'Finder' and 'Services Menu'"
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
