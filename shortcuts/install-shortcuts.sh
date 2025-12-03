#!/bin/bash

# ==============================================
# macOS Shortcuts Auto-Installer
# ==============================================
# This script attempts to automatically configure
# macOS Shortcuts for E2E Report Tools
# ==============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
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
check_env_file() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        echo ""
        print_info "Please run 'npm run setup' first."
        exit 1
    fi
}

# 加载环境变量
load_env() {
    export $(grep -v '^#' .env | xargs)
    print_success "Loaded configuration from .env"
}

# 生成 Shortcuts
generate_shortcuts() {
    local shortcuts_dir="shortcuts"
    local templates_dir="$shortcuts_dir/templates"
    
    print_info "Generating shortcuts from templates..."
    
    # 替换模板中的占位符
    for template in "$templates_dir"/*.template; do
        if [ -f "$template" ]; then
            local shortcut_name=$(basename "$template" .template)
            local output_file="$shortcuts_dir/$shortcut_name"
            
            # 使用 sed 替换占位符
            sed -e "s|{{NODE_BIN}}|$NODE_BIN|g" \
                -e "s|{{SCRIPT_PATH}}|$SCRIPT_PATH|g" \
                -e "s|{{PROJECT_PATH}}|$PROJECT_PATH|g" \
                "$template" > "$output_file"
            
            print_success "Generated: $shortcut_name"
        fi
    done
}

# 主函数
main() {
    print_header "macOS Shortcuts Auto-Installer"
    
    echo ""
    print_info "Checking prerequisites..."
    check_env_file
    
    echo ""
    load_env
    
    echo ""
    generate_shortcuts
    
    echo ""
    print_header "Installation Instructions"
    
    echo ""
    print_warning "Automatic shortcut installation is not fully supported by macOS."
    print_info "Please follow these manual steps:"
    echo ""
    
    echo "1. Open the Shortcuts app on your Mac"
    echo ""
    
    echo "2. For each shortcut file in the 'shortcuts/' folder:"
    echo "   - generateAllureReport"
    echo "   - openAllureReport"
    echo "   - openTrace"
    echo ""
    
    echo "3. Create a new shortcut and configure it according to shortcuts/README.md"
    echo ""
    
    print_info "The configuration values have been prepared in the shortcut files."
    print_info "You can copy-paste them directly!"
    echo ""
    
    print_success "Setup complete! See shortcuts/README.md for detailed instructions."
    echo ""
}

# 运行
main
