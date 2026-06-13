#!/usr/bin/env bash
# ============================================================
# application-use-initializer — 工具安装脚本（跨平台）
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

info "=========================================="
info " 🔧 Application Use 工具安装脚本"
info "   平台: $PLATFORM ($OS $ARCH)"
info "=========================================="
echo

# ---------- 2. 工具清单 ----------
# 格式: 名称|包名|类型|适用平台|安装方式|MCP服务名|MCP命令|MCP参数JSON
TOOLS=(
  "Playwright|playwright|MCP|macOS,Linux,Windows|npm_global_mcp|playwright|npx|[\"-y\",\"@playwright/mcp\",\"--vision\"]"  # Vision 模式默认开启
  "auto-feedback|auto-feedback|MCP|macOS,Linux,Windows|npm_global_mcp|feedback|auto-feedback|[]"
  "@cocaxcode/api-testing-mcp|@cocaxcode/api-testing-mcp|MCP|macOS,Linux,Windows|npx_mcp|api-testing|npx|[\"-y\",\"@cocaxcode/api-testing-mcp@latest\"]"
  "application-use|application-use|CLI|macOS|npm_global|||"
  "agent-computer|agent-computer|MCP|macOS|npm_global_mcp|agent-computer|npx|[\"-y\",\"agent-computer\"]"
  "playwright-spatial-layout-mcp|playwright-spatial-layout-mcp|MCP|macOS,Linux,Windows|npm_global_mcp|playwright-spatial-layout|npx|[\"-y\",\"playwright-spatial-layout-mcp\"]"
  "@saifulapm/layoutlint|@saifulapm/layoutlint|CLI|macOS,Linux,Windows|npm_global|||"
)

warn "[1/6] 检测平台: $PLATFORM"
echo

# ---------- 过滤可安装工具 ----------
warn "[2/6] 过滤可安装工具..."

INSTALLABLE=()
for tool in "${TOOLS[@]}"; do
  IFS='|' read -ra FIELDS <<< "$tool"
  NAME="${FIELDS[0]}"
  PKG="${FIELDS[1]}"
  TYPE="${FIELDS[2]}"
  PLATFORMS="${FIELDS[3]}"
  METHOD="${FIELDS[4]}"

  if echo "$PLATFORMS" | grep -qF "$PLATFORM"; then
    INSTALLABLE+=("$tool")
    success "   ✅ $NAME ($PKG) — 兼容 $PLATFORM"
  else
    warn "   ⏭️  $NAME — 不兼容 $PLATFORM (需要: $PLATFORMS)"
  fi
done
echo

# ---------- 检测安装状态 ----------
warn "[3/6] 检测工具安装状态..."

INSTALLED=()
TO_BE_INSTALLED=()

for tool in "${INSTALLABLE[@]}"; do
  IFS='|' read -ra FIELDS <<< "$tool"
  NAME="${FIELDS[0]}"
  PKG="${FIELDS[1]}"

  if cmd_exists "$PKG" || npm_pkg_installed "$PKG"; then
    success "   ✅ $NAME — 已安装"
    INSTALLED+=("$tool")
  else
    warn "   ⏳ $NAME — 待安装"
    TO_BE_INSTALLED+=("$tool")
  fi
done
echo

# ---------- 询问安装目标 ----------
if [ ${#TO_BE_INSTALLED[@]} -gt 0 ]; then
  warn "[4/6] 安装配置..."
  echo "  待安装工具:"
  for tool in "${TO_BE_INSTALLED[@]}"; do
    IFS='|' read -ra FIELDS <<< "$tool"
    echo "    - ${FIELDS[0]} (${FIELDS[1]}) [${FIELDS[2]}]"
  done
  echo
  echo "请选择 MCP 服务配置目标:"
  echo "  1) 全局 (~/.claude/settings.json)"
  echo "  2) 当前项目 (.claude/settings.local.json)"
  echo "  3) 当前项目 (.claude/settings.json)"
  prompt "请输入编号 [1-3] (默认 1): " CFG_TARGET
  CFG_TARGET="${CFG_TARGET:-1}"
  SETTINGS_FILE="$(detect_settings_path "$CFG_TARGET")"
  success "   配置目标: $SETTINGS_FILE"
  echo
fi

# ---------- 安装 ----------
INSTALL_RESULT=()

if [ ${#TO_BE_INSTALLED[@]} -eq 0 ]; then
  warn "[5/6] 所有工具已安装，无需操作。"
else
  info "[5/6] 开始安装 ${#TO_BE_INSTALLED[@]} 个工具..."

  for tool in "${TO_BE_INSTALLED[@]}"; do
    IFS='|' read -ra FIELDS <<< "$tool"
    NAME="${FIELDS[0]}"
    PKG="${FIELDS[1]}"
    TYPE="${FIELDS[2]}"
    METHOD="${FIELDS[4]}"
    MCP_NAME="${FIELDS[5]}"
    MCP_CMD="${FIELDS[6]}"
    MCP_ARGS="${FIELDS[7]}"

    echo
    info "   ⚙️  正在安装: $NAME ($PKG)..."

    case "$METHOD" in
      npm_global|npm_global_mcp)
        if npm install -g "$PKG" 2>&1; then
          success "   ✅ $NAME 安装成功"
          INSTALL_RESULT+=("$NAME|installed|$PKG")

          # 如果是 MCP 工具，写入配置
          if [ "$METHOD" = "npm_global_mcp" ] && [ -n "$MCP_NAME" ]; then
            info "   📝 写入 MCP 配置: $MCP_NAME"
            write_mcp_entry "$SETTINGS_FILE" "$MCP_NAME" "$MCP_CMD" "$MCP_ARGS"
          fi
        else
          error "   ❌ $NAME 安装失败"
          INSTALL_RESULT+=("$NAME|failed|$PKG")
        fi
        ;;
      npx_mcp)
        success "   ⏭️  $NAME 使用 npx 方式（无需全局安装）"
        INSTALL_RESULT+=("$NAME|installed(npx)|$PKG")
        if [ -n "$MCP_NAME" ]; then
          info "   📝 写入 MCP 配置: $MCP_NAME"
          write_mcp_entry "$SETTINGS_FILE" "$MCP_NAME" "$MCP_CMD" "$MCP_ARGS"
        fi
        ;;
      *)
        warn "   ⚠️  未知安装方法: $METHOD"
        INSTALL_RESULT+=("$NAME|skipped|$PKG")
        ;;
    esac
  done
fi
echo

# ---------- 汇总 ----------
info "=========================================="
info " 📊 安装汇总"
info "=========================================="
echo
printf "%-32s %-16s %s\n" "工具名" "状态" "包名"
printf "%-32s %-16s %s\n" "--------------------------------" "----------------" "-------------------------"

# 已安装的
for tool in "${INSTALLED[@]}"; do
  IFS='|' read -ra FIELDS <<< "$tool"
  printf "%-32s %-16s %s\n" "${FIELDS[0]}" "✅ 已安装" "${FIELDS[1]}"
done

# 本次安装的
for entry in "${INSTALL_RESULT[@]}"; do
  IFS='|' read -ra FIELDS <<< "$entry"
  NAME="${FIELDS[0]}"
  STATUS="${FIELDS[1]}"
  PKG="${FIELDS[2]}"

  case "$STATUS" in
    installed) printf "%-32s %-16s %s\n" "$NAME" "✅ 已安装" "$PKG" ;;
    failed)    printf "%-32s %-16s %s\n" "$NAME" "❌ 失败" "$PKG" ;;
    skipped)   printf "%-32s %-16s %s\n" "$NAME" "⏭️  跳过" "$PKG" ;;
  esac
done

echo
if [ -n "${SETTINGS_FILE:-}" ] && [ -f "$SETTINGS_FILE" ]; then
  info "MCP 配置文件: $SETTINGS_FILE"
fi
echo
info "=========================================="
info " 安装脚本执行完毕"
info " 提示: 重启 Claude Code 后 MCP 服务生效"
info "=========================================="
