#!/usr/bin/env bash
# ============================================================
# 配置脚本: mcp-android-emulator（Android Emulator / 真机自动化）
# 基于 MCP 的 Android 移动端测试工具，通过 ADB 控制 Android 设备。
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

# 默认 settings 文件（若未由 install-tools.sh 传入，则默认全局）
SETTINGS_FILE="${SETTINGS_FILE:-$HOME/.claude/settings.json}"

info "============================================"
info " 🔧 配置 mcp-android-emulator（Android 设备自动化）"
info "============================================"
echo

# ---------- 1. 检测 ADB ----------
warn "[1/4] 检测 ADB (Android Debug Bridge)..."

if cmd_exists adb; then
  success "   ✅ ADB 已安装: $(adb --version 2>&1 | head -1)"
else
  warn "   ⏳ 未找到 ADB，尝试通过 Android SDK 路径检测..."

  # 常见 ADB 路径
  ADB_CANDIDATES=(
    "$HOME/Library/Android/sdk/platform-tools/adb"
    "$HOME/Android/Sdk/platform-tools/adb"
    "/usr/local/android-sdk/platform-tools/adb"
    "/opt/android-sdk/platform-tools/adb"
  )

  ADB_FOUND=""
  for candidate in "${ADB_CANDIDATES[@]}"; do
    if [ -x "$candidate" ]; then
      ADB_FOUND="$candidate"
      break
    fi
  done

  if [ -n "$ADB_FOUND" ]; then
    export PATH="$(dirname "$ADB_FOUND"):$PATH"
    success "   ✅ 找到 ADB: $ADB_FOUND"
  else
    warn "   ⚠️  未自动找到 ADB。请确保已安装 Android SDK:"
    warn "       macOS: brew install --cask android-platform-tools"
    warn "       Linux: apt install android-sdk-platform-tools"
    warn "       Windows: 通过 Android Studio SDK Manager 安装"
    warn "   安装脚本将继续，但请确保运行前 ADB 可用。"
  fi
fi
echo

# ---------- 2. 检测 Java (JRE, Android SDK 所需) ----------
warn "[2/4] 检测 Java 环境..."

if command -v java >/dev/null 2>&1; then
  success "   ✅ Java 可用: $(java -version 2>&1 | head -1)"
else
  warn "   ⚠️  未检测到 Java。Android Emulator 可能需要 JRE。"
  warn "      如需启动模拟器请先安装: brew install --cask zulu17"
fi
echo

# ---------- 3. 安装 mcp-android-emulator ----------
warn "[3/4] 安装 mcp-android-emulator..."

if cmd_exists mcp-android-emulator; then
  success "   ✅ mcp-android-emulator 已全局安装"
else
  warn "   ⏳ 正在通过 npm 全局安装 mcp-android-emulator..."
  if npm install -g mcp-android-emulator 2>&1; then
    success "   ✅ mcp-android-emulator 安装成功"
  else
    warn "   ⚠️  全局安装失败，将配置 npx 方式使用"
  fi
fi
echo

# ---------- 4. 写入 MCP 配置 ----------
warn "[4/4] 写入 MCP 配置..."

info "   📝 添加 android-emulator 到 mcpServers..."

# 优先使用全局安装的 mcp-android-emulator，否则用 npx
if cmd_exists mcp-android-emulator; then
  write_mcp_entry "$SETTINGS_FILE" "android-emulator" "mcp-android-emulator" "[]"
  success "   ✅ android-emulator MCP 配置完成（直接调用）"
else
  write_mcp_entry "$SETTINGS_FILE" "android-emulator" "npx" '["-y","mcp-android-emulator"]'
  success "   ✅ android-emulator MCP 配置完成（npx 方式）"
fi
echo

success "============================================"
success " ✅ mcp-android-emulator 配置完成"
success "============================================"
success ""
success "  使用方式：启动 Android Emulator 后在 Claude Code 中调用"
success "  mcp-android-emulator 工具（tap/swipe/type/launch_app 等）"
success ""
success "  确保 ADB 可连接设备: adb devices"
success "============================================"
