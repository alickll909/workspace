#!/usr/bin/env bash
# ============================================================
# 配置脚本: simdrive（iOS Simulator / 真机自动化）
# 基于 MCP 的 iOS 移动端测试工具，提供视觉优先的 Simulator + 真机操控能力。
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
info " 🔧 配置 simdrive（iOS Simulator + 真机自动化）"
info "============================================"
echo

# ---------- 检查平台 ----------
if [ "$PLATFORM" != "macOS" ]; then
  error "   ❌ simdrive 仅支持 macOS（需要 Xcode + iOS Simulator）"
  exit 1
fi
echo

# ---------- 1. 检测 Xcode ----------
warn "[1/4] 检测 Xcode 环境..."

if command -v xcode-select >/dev/null 2>&1 && xcode-select -p >/dev/null 2>&1; then
  success "   ✅ Xcode 已安装: $(xcode-select -p)"
else
  error "   ❌ 未找到 Xcode。请先安装 Xcode: xcode-select --install"
  exit 1
fi
echo

# ---------- 2. 检测 Python ----------
warn "[2/4] 检测 Python 环境..."

PYTHON="$(detect_python)"

if "$PYTHON" --version 2>&1 | grep -qE "^Python 3\."; then
  success "   ✅ Python 可用: $($PYTHON --version 2>&1)"
else
  error "   ❌ 需要 Python 3.x"
  exit 1
fi
echo

# ---------- 3. 安装 simdrive ----------
warn "[3/4] 安装 simdrive..."

if cmd_exists simdrive; then
  success "   ✅ simdrive 已安装 ($(simdrive --version 2>/dev/null || echo '版本未知'))"
else
  warn "   ⏳ 正在通过 pip 安装 simdrive..."
  if $PYTHON -m pip install --pre simdrive 2>&1; then
    success "   ✅ simdrive 安装成功"
  else
    error "   ❌ pip 安装失败，请手动执行: pip install --pre simdrive"
    exit 1
  fi
fi
echo

# ---------- 4. 写入 MCP 配置 ----------
warn "[4/4] 写入 MCP 配置..."

info "   📝 添加 simdrive 到 mcpServers..."
write_mcp_entry "$SETTINGS_FILE" "simdrive" "simdrive" "[]"
success "   ✅ simdrive MCP 配置完成"
echo

success "============================================"
success " ✅ simdrive 配置完成"
success "============================================"
success ""
success "  使用方式：启动 iOS Simulator 后在 Claude Code 中调用"
success "  simdrive 工具（observe/tap/swipe/type_text 等）"
success ""
success "  首次使用可运行: simdrive trial start --email you@example.com"
success "============================================"
