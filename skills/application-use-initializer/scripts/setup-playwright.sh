#!/usr/bin/env bash
# ============================================================
# 配置脚本: Playwright（跨平台）
# 浏览器自动化 CLI，为 auto-feedback / spatial-layout 提供依赖
# 注意：该工具为 CLI 工具，非 MCP 服务，无需 mcpServers 配置
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

info "============================================"
info " 🔧 配置 Playwright（浏览器自动化）"
info "============================================"
echo

# ---------- 1. 检测 Playwright 安装 ----------
warn "[1/3] 检测 Playwright 安装状态..."

if npx playwright --version 2>/dev/null; then
  success "   ✅ Playwright 可用"
else
  warn "   ⏳ 未安装，执行安装..."
  if npm install -g playwright 2>&1; then
    success "   ✅ Playwright 安装成功"
  else
    error "   ❌ 安装失败，请手动执行: npm install -g playwright"
    exit 1
  fi
fi
echo

# ---------- 2. 安装 Chromium 浏览器 ----------
warn "[2/3] 安装 Chromium 浏览器..."

if npx playwright install chromium 2>&1; then
  success "   ✅ Chromium 安装成功"
else
  warn "   ⚠️  Chromium 安装未完成，请手动执行: npx playwright install chromium"
fi
echo

# ---------- 3. 安装其他浏览器（可选） ----------
warn "[3/3] 可选: 安装其他浏览器..."

echo "   Playwright 支持以下浏览器:"
echo "   1) 仅 Chromium（默认，约 300MB）"
echo "   2) Chromium + Firefox（约 600MB）"
echo "   3) Chromium + Firefox + WebKit（约 900MB）"
prompt "请输入编号 [1-3] (默认 1): " BROWSER_CHOICE

BROWSER_CHOICE="${BROWSER_CHOICE:-1}"
case "$BROWSER_CHOICE" in
  2)
    info "安装 Chromium + Firefox..."
    npx playwright install chromium firefox 2>&1 || warn "Firefox 安装未完成"
    ;;
  3)
    info "安装全部浏览器..."
    npx playwright install 2>&1 || warn "浏览器安装未完成"
    ;;
  *)
    info "仅 Chromium 已就绪"
    ;;
esac

echo
success "============================================"
success " ✅ Playwright 配置完成"
success "============================================"
