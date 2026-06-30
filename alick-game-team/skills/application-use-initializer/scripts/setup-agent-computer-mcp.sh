#!/usr/bin/env bash
# ============================================================
# MCP 配置脚本: agent-computer（跨平台 / 信息引导）
# 注意: npm 上的 agent-computer@0.0.1 为占位包（151B 空壳）
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_utils.sh
. "$SCRIPT_DIR/_utils.sh"

# shellcheck disable=SC2046
eval $(detect_os)

info "============================================"
info " 🔧 agent-computer MCP 服务配置"
info "============================================"
echo

warn "⚠️  agent-computer 当前状态"
echo
echo "   npm 上的 agent-computer@0.0.1 是一个占位包（仅 151 字节），"
echo "   不包含实际的 MCP 服务实现。"
echo

# ---------- 替代方案 ----------
info "📌 推荐替代方案（macOS / Linux / Windows）"
echo

printf "   %-35s %-30s %s\n" "方案" "包名" "安装命令"
printf "   %-35s %-30s %s\n" "-----------------------------------" "------------------------------" "-----------------------------------"
printf "   %-35s %-30s %s\n" "macOS 桌面控制 MCP" "@hasna/computer" "npm install -g @hasna/computer"
printf "   %-35s %-30s %s\n" "通用计算机控制 MCP" "computer-control-mcp" "npm install -g computer-control-mcp"

# 按平台推荐
case "$PLATFORM" in
  macOS)
    printf "   %-35s %-30s %s\n" "macOS 原生 MCP" "macos-mcp-server" "npm install -g macos-mcp-server"
    printf "   %-35s %-30s %s\n" "application-use（推荐）" "application-use" "npm install -g application-use"
    ;;
  Linux)
    printf "   %-35s %-30s %s\n" "Linux 桌面控制 MCP" "xdg-mcp" "npm install -g xdg-mcp"
    ;;
  Windows)
    printf "   %-35s %-30s %s\n" "Windows 桌面控制 MCP" "windows-mcp" "npm install -g windows-mcp"
    ;;
esac
echo

# ---------- 用户选择 ----------
info "📌 请选择操作:"
echo "   1) 安装 @hasna/computer（通用替代方案）"
echo "   2) 跳过，稍后手动安装"
echo "   3) 仍创建 agent-computer 占位配置（服务不可用）"
prompt "请输入编号 [1-3] (默认 2): " ACTION

ACTION="${ACTION:-2}"
case "$ACTION" in
  1)
    info "安装 @hasna/computer..."
    if npm install -g @hasna/computer 2>&1; then
      success "   ✅ @hasna/computer 安装成功"

      echo "请选择配置目标:"
      echo "  1) 全局 (~/.claude/settings.json)"
      echo "  2) 当前项目 (.claude/settings.local.json)"
      prompt "请输入编号 [1-2] (默认 1): " TARGET
      TARGET="${TARGET:-1}"
      SETTINGS_FILE="$(detect_settings_path "$TARGET")"
      write_mcp_entry "$SETTINGS_FILE" "hasna-computer" "hasna-computer" "[]"
      success "   ✅ @hasna/computer MCP 配置完成"
    else
      error "   ❌ 安装失败，请手动执行: npm install -g @hasna/computer"
    fi
    ;;
  2)
    info "⏭️  跳过。推荐手动安装:"
    info "   npm install -g application-use"
    info "   npm install -g @hasna/computer"
    ;;
  3)
    warn "创建 agent-computer 占位配置（服务不可用）..."
    echo "请选择配置目标:"
    echo "  1) 全局 (~/.claude/settings.json)"
    echo "  2) 当前项目 (.claude/settings.local.json)"
    prompt "请输入编号 [1-2] (默认 1): " TARGET
    TARGET="${TARGET:-1}"
    SETTINGS_FILE="$(detect_settings_path "$TARGET")"
    write_mcp_entry "$SETTINGS_FILE" "agent-computer" "npx" '["-y","agent-computer"]'
    warn "   ⚠️  占位配置已写入，但服务不可用"
    warn "   请替换为实际可用的 MCP 服务"
    ;;
esac

echo
success "============================================"
success " agent-computer 配置引导完成"
success "============================================"
