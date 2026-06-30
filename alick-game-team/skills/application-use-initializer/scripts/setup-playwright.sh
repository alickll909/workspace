#!/usr/bin/env bash
# ============================================================
# 配置脚本: Playwright（跨平台）
# 浏览器自动化 CLI + MCP 服务（默认开启 Vision 模式），
# 为 auto-feedback / spatial-layout 提供依赖。
# Vision 模式启用截图和视觉交互能力。
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
info " 🔧 配置 Playwright（浏览器自动化 + Vision 模式）"
info "============================================"
echo

# ---------- 1. 检测/安装 Playwright 核心库 ----------
warn "[1/4] 检测 Playwright 安装状态..."

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
warn "[2/4] 安装 Chromium 浏览器..."

if npx playwright install chromium 2>&1; then
  success "   ✅ Chromium 安装成功"
else
  warn "   ⚠️  Chromium 安装未完成，请手动执行: npx playwright install chromium"
fi
echo

# ---------- 3. 安装其他浏览器（可选） ----------
warn "[3/4] 可选: 安装其他浏览器..."

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

# ---------- 4. 安装 @playwright/mcp 并配置 Vision 模式 ----------
# Vision 模式让 AI 可通过截图视觉方式与浏览器交互
warn "[4/4] 安装 Playwright MCP（默认开启 Vision 模式）..."

# 安装 @playwright/mcp（若尚未安装）
if npx @playwright/mcp --version 2>/dev/null; then
  success "   ✅ @playwright/mcp 已安装"
else
  warn "   ⏳ 安装 @playwright/mcp..."
  if npm install -g @playwright/mcp 2>&1; then
    success "   ✅ @playwright/mcp 安装成功"
  else
    warn "   ⚠️  @playwright/mcp 全局安装失败，将使用 npx 方式"
  fi
fi

# 写入 MCP 配置（默认开启 Vision 模式）
info "   📝 写入 MCP 配置（Vision 模式）..."
write_mcp_entry "$SETTINGS_FILE" "playwright" "npx" '["-y","@playwright/mcp","--vision"]'
success "   ✅ Playwright MCP（Vision 模式）配置完成"
echo

success "============================================"
success " ✅ Playwright 配置完成（Vision 模式已开启）"
success "============================================"
