#!/usr/bin/env bash
# ============================================================
# 配置脚本: @saifulapm/layoutlint（跨平台）
# 网页布局检测 CLI 工具
# 注意：该工具为 CLI 工具，非 MCP 服务，无需 mcpServers 配置
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

info "============================================"
info " 🔧 配置 @saifulapm/layoutlint"
info "============================================"
echo

# ---------- 1. 检测 / 安装 ----------
warn "[1/1] 检测 @saifulapm/layoutlint 安装状态..."

if cmd_exists layoutlint; then
  success "   ✅ @saifulapm/layoutlint 已安装"
elif npm_pkg_installed "@saifulapm/layoutlint"; then
  success "   ✅ @saifulapm/layoutlint 已安装（npm global）"
else
  warn "   ⏳ 未安装，执行安装..."
  if npm install -g @saifulapm/layoutlint 2>&1; then
    success "   ✅ @saifulapm/layoutlint 安装成功"
  else
    error "   ❌ 安装失败，请手动执行: npm install -g @saifulapm/layoutlint"
    exit 1
  fi
fi
echo

info "📌  使用方法:"
echo "   npx @saifulapm/layoutlint <html-file>"
echo
success "============================================"
success " ✅ @saifulapm/layoutlint 配置完成"
success "============================================"
