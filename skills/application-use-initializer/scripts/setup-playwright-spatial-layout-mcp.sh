#!/usr/bin/env bash
# ============================================================
# MCP 配置脚本: playwright-spatial-layout-mcp（跨平台）
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

info "=========================================================="
info " 🔧 配置 playwright-spatial-layout-mcp MCP 服务"
info "=========================================================="
echo

# ---------- 1. 检测 / 安装 ----------
warn "[1/3] 检测 playwright-spatial-layout-mcp 安装状态..."

if cmd_exists playwright-spatial-layout-mcp; then
  success "   ✅ 已全局安装"
elif npm_pkg_installed playwright-spatial-layout-mcp; then
  success "   ✅ 已安装（npm global）"
else
  warn "   ⏳ 未安装，尝试全局安装..."
  if npm install -g playwright-spatial-layout-mcp 2>&1; then
    success "   ✅ 全局安装成功"
  else
    warn "   ⚠️  npm install -g 失败，将使用 npx 方式（无需安装）"
  fi
fi

# ---------- 2. Chromium ----------
warn "[2/3] 检测 Playwright Chromium..."
if npx playwright install chromium 2>&1; then
  success "   ✅ Chromium 已就绪"
else
  warn "   ⚠️  请手动执行: npx playwright install chromium"
fi
echo

# ---------- 3. 写入 MCP 配置 ----------
warn "[3/3] 写入 mcpServers 配置..."

echo "请选择配置目标:"
echo "  1) 全局 (~/.claude/settings.json)"
echo "  2) 当前项目 (.claude/settings.local.json)"
echo "  3) 当前项目 (.claude/settings.json)"
prompt "请输入编号 [1-3] (默认 1): " TARGET

TARGET="${TARGET:-1}"
SETTINGS_FILE="$(detect_settings_path "$TARGET")"
echo "   目标文件: $SETTINGS_FILE"
echo

write_mcp_entry "$SETTINGS_FILE" "playwright-spatial-layout" "npx" '["-y","playwright-spatial-layout-mcp"]'

echo
success "=========================================================="
success " ✅ playwright-spatial-layout MCP 配置完成"
success "    重启 Claude Code 后生效"
success "=========================================================="
