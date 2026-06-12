#!/usr/bin/env bash
# ============================================================
# 配置脚本: application-use（macOS 桌面控制 CLI）
# 注意：该工具为 CLI 工具，非 MCP 服务，无需 mcpServers 配置
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

info "============================================"
info " 🔧 配置 application-use（macOS 桌面控制）"
info "============================================"
echo

# ---------- 平台检测 ----------
if [ "$PLATFORM" != "macOS" ]; then
  warn "⚠️  application-use 仅支持 macOS（当前: $PLATFORM）"
  warn "   跳过安装。"
  exit 0
fi

# ---------- 1. 检测 / 安装 ----------
warn "[1/2] 检测 application-use 安装状态..."

if cmd_exists application-use; then
  success "   ✅ application-use 已安装"
else
  warn "   ⏳ 未安装，执行安装..."
  if npm install -g application-use 2>&1; then
    success "   ✅ application-use 安装成功"
  else
    error "   ❌ 安装失败，请手动执行: npm install -g application-use"
    exit 1
  fi
fi
echo

# ---------- 2. 授予辅助功能权限 ----------
warn "[2/2] 检查 macOS 辅助功能权限..."

MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "0")
info "   当前 macOS 版本: $MACOS_VERSION"

echo
info "📌  如需使用 application-use 控制桌面，请确保以下权限已授予:"
echo
echo "   ⚙️  System Settings → Privacy & Security → Accessibility"
echo "      → 添加 Terminal / iTerm2 / VS Code"
echo "   ⚙️  System Settings → Privacy & Security → Screen Recording"
echo "      → 添加 Terminal / iTerm2 / VS Code"
echo
info "   更多信息: https://github.com/nicholasgriffintn/application-use"
echo
success "============================================"
success " ✅ application-use 配置完成"
success "============================================"
