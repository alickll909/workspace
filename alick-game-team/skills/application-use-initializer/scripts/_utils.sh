#!/usr/bin/env bash
# ============================================================
# 跨平台工具库 — 供其他脚本 source 使用
# ============================================================
# 本脚本不独立执行，被 setup-*.sh 和 install-tools.sh source 使用
# ============================================================

# ---------- 安全退出 ----------
safe_exit() {
  local code=${1:-1}
  shift
  printf '%s\n' "$*" >&2
  exit "$code"
}

# ---------- 颜色（禁用转义序列检测） ----------
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''
fi

# ---------- 跨平台 echo（替代 echo -e） ----------
cecho() {
  local color="$1"; shift
  printf '%b%s%b\n' "$color" "$*" "$NC"
}

info()    { cecho "$CYAN" "$@"; }
success() { cecho "$GREEN" "$@"; }
warn()    { cecho "$YELLOW" "$@"; }
error()   { cecho "$RED" "$@"; }

# ---------- 跨平台 read -p（兼容 POSIX sh） ----------
prompt() {
  local msg="$1"
  printf '%s' "$msg"
  read -r "$2"
}

# ---------- 平台检测 ----------
detect_os() {
  OS="$(uname -s 2>/dev/null || echo "Unknown")"
  ARCH="$(uname -m 2>/dev/null || echo "Unknown")"

  case "$OS" in
    Darwin)  PLATFORM="macOS"    ;;
    Linux)   PLATFORM="Linux"    ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="Windows" ;;
    *)       PLATFORM="Unknown"  ;;
  esac

  printf '%s\n' "OS=$OS"
  printf '%s\n' "ARCH=$ARCH"
  printf '%s\n' "PLATFORM=$PLATFORM"
}

# ---------- settings 路径检测 ----------
detect_settings_path() {
  local choice="$1"  # 1=global, 2=project-local, 3=project

  case "$choice" in
    1)
      # 跨平台 $HOME
      local home="${HOME:-}"
      if [ -z "$home" ]; then
        case "$PLATFORM" in
          Windows) home="$USERPROFILE" ;;
          *)       home="$HOME" ;;
        esac
      fi
      printf '%s/.claude/settings.json' "$home"
      ;;
    2) printf '%s/.claude/settings.local.json' "$(pwd)" ;;
    3) printf '%s/.claude/settings.json' "$(pwd)" ;;
    *) safe_exit 1 "错误: 未知配置目标 '$choice'" ;;
  esac
}

# ---------- Python 检测 ----------
detect_python() {
  if command -v python3 >/dev/null 2>&1; then
    printf 'python3'
  elif command -v python >/dev/null 2>&1; then
    # 检查 python 是否为 Python 3（而非 2）
    local ver
    ver="$(python --version 2>&1 || true)"
    case "$ver" in
      *3*) printf 'python' ;;
      *)   safe_exit 1 "错误: python 版本为 2.x，需要 Python 3" ;;
    esac
  else
    safe_exit 1 "错误: 未找到 python3/python，请先安装 Python 3"
  fi
}

# ---------- JSON 工具检测 ----------
detect_json_tool() {
  if command -v jq >/dev/null 2>&1; then
    printf 'jq'
  elif command -v python3 >/dev/null 2>&1; then
    printf 'python3'
  elif command -v python >/dev/null 2>&1; then
    printf 'python'
  else
    safe_exit 1 "错误: 需要 jq 或 python3 来处理 JSON"
  fi
}

# ---------- 安全写入 JSON (mcpServers 条目) ----------
write_mcp_entry() {
  local settings_file="$1"
  local mcp_name="$2"
  local mcp_command="$3"
  local mcp_args="$4"  # JSON 数组字符串，如 '["-y","some-pkg"]'

  local py
  py="$(detect_python)"

  "$py" << PYEOF
import json, os, sys

fpath = "$settings_file"
mcp_name = "$mcp_name"
mcp_config = {"command": "$mcp_command", "args": $mcp_args}

try:
    if os.path.exists(fpath):
        with open(fpath, 'r') as f:
            data = json.load(f) if f.read().strip() else {}
    else:
        data = {}

    if "mcpServers" not in data or data["mcpServers"] is None:
        data["mcpServers"] = {}

    data["mcpServers"][mcp_name] = mcp_config

    os.makedirs(os.path.dirname(fpath) or '.', exist_ok=True)
    with open(fpath, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"   mcpServers.{mcp_name} -> {fpath}")
except Exception as e:
    print(f"   JSON 写入失败: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

# ---------- 检测命令是否存在 ----------
cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ---------- npm 全局包检测 ----------
npm_pkg_installed() {
  npm ls -g "$1" >/dev/null 2>&1
}
