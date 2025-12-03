# 🎯 交互式快捷指令安装

## ✨ 最佳实践方案

经过测试，我们发现 macOS 有以下限制：
- ❌ 不支持命令行直接创建快捷指令
- ❌ 不支持导入未签名的 .shortcut 文件
- ✅ **但我们可以让过程尽可能简单！**

## 🚀 解决方案：交互式向导

`npm run generate-shortcuts` 提供了一个**交互式向导**：

### 工作流程

1. **打开 Shortcuts 应用** - 脚本会等待你打开
2. **逐个创建快捷指令** - 脚本引导你创建 3 个快捷指令
3. **自动复制脚本** - 每个快捷指令的脚本会自动复制到剪贴板
4. **你只需粘贴** - Cmd+V 粘贴到 Shortcuts 应用中
5. **完成！** - 约 2 分钟完成全部设置

### 使用示例

```bash
npm run generate-shortcuts
```

**输出：**
```
==================================================
macOS Shortcuts Installation Helper
==================================================

⚠️  macOS does not support automatic shortcut creation via command line.
ℹ️  However, this script makes the process as easy as possible!

📋 Step 1: Open the Shortcuts app

Press any key when Shortcuts app is open...

📋 Step 2: Create shortcuts one by one

ℹ️  We'll guide you through creating 3 shortcuts.
ℹ️  For each shortcut, we'll copy the script to your clipboard.
ℹ️  You just need to paste it in the Shortcuts app!

==================================================
Shortcut 1: Generate Allure Report
==================================================

ℹ️  1. In Shortcuts app, click '+' to create a new shortcut
ℹ️  2. Name it: Generate Allure Report
ℹ️  3. Search for 'Run Shell Script' action and add it
ℹ️  4. We'll copy the script to clipboard - just paste it!

Press any key to copy the script to clipboard...
✅ Script copied to clipboard! Now:

  5. Paste (Cmd+V) into the 'Run Shell Script' action
  6. Set Shell: bash
  7. Set Input: Shortcut Input
  8. Set Pass input: as arguments
  9. Click (i) Details → Enable 'Use as Quick Action'
  10. Check 'Finder' and 'Services Menu'

Press any key when done...
✅ Shortcut 1 created!

[... 继续处理 Shortcut 2 和 3 ...]

==================================================
🎉 All Done!
==================================================

✅ You've successfully created all 3 shortcuts!

ℹ️  Now you can right-click files in Finder and use Quick Actions:

  • Generate Allure Report - for .zip test results
  • Open Allure Report - for report folders
  • Open Trace - for Playwright trace files

✅ Enjoy! 🚀
```

## 📊 对比其他方案

| 方案 | 自动化程度 | 用户操作 |
|------|-----------|---------|
| 方案 A (generate-shortcuts) | ⭐⭐⭐⭐⭐ | 双击 3 个文件 |
| 方案 B (install-shortcuts) | ⭐⭐⭐ | 复制粘贴脚本到 Shortcuts 应用 |
| 方案 C (手动) | ⭐ | 完全手动配置 |

**推荐使用方案 A！**
