#!/usr/bin/env bash
# ============================================================
# MCP 配置脚本: @cocaxcode/api-testing-mcp（跨平台）
# 写入 mcpServers 到 settings 文件
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

info "============================================"
info " 🔧 配置 @cocaxcode/api-testing-mcp MCP 服务"
info "============================================"
echo

# ---------- 1. 提示说明 ----------
warn "[1/2] 工具说明..."
echo
info "   @cocaxcode/api-testing-mcp 是一个 API 测试 MCP 服务，提供 42 个工具"
info "   支持 HTTP 请求、断言、多步骤流程、OpenAPI 导入、负载测试等"
echo

# ---------- 2. 写入 MCP 配置 ----------
warn "[2/2] 写入 mcpServers 配置..."

echo "请选择配置目标:"
echo "  1) 全局 (~/.claude/settings.json)"
echo "  2) 当前项目 (.claude/settings.local.json)"
echo "  3) 当前项目 (.claude/settings.json)"
prompt "请输入编号 [1-3] (默认 1): " TARGET

TARGET="${TARGET:-1}"
SETTINGS_FILE="$(detect_settings_path "$TARGET")"
echo "   目标文件: $SETTINGS_FILE"
echo
echo "   📌 推荐使用 npx 方式运行，无需全局安装"
prompt "是否以 npx 方式配置（无需安装）? [Y/n]: " USE_NPX

USE_NPX="${USE_NPX:-y}"
if [ "$USE_NPX" = "y" ] || [ "$USE_NPX" = "Y" ]; then
  write_mcp_entry "$SETTINGS_FILE" "api-testing" "npx" '["-y","@cocaxcode/api-testing-mcp@latest"]'
  success "   ✅ 已配置 npx 方式"
else
  warn "   ⏳ 尝试全局安装..."
  if npm install -g @cocaxcode/api-testing-mcp 2>&1; then
    success "   ✅ 全局安装成功"
    write_mcp_entry "$SETTINGS_FILE" "api-testing" "@cocaxcode/api-testing-mcp" "[]"
    success "   ✅ 已配置全局安装方式"
  else
    error "   ❌ 全局安装失败，请手动执行: npm install -g @cocaxcode/api-testing-mcp"
    exit 1
  fi
fi

echo
success "============================================"
success " ✅ @cocaxcode/api-testing-mcp 配置完成"
success "    重启 Claude Code 后生效"
success "============================================"
