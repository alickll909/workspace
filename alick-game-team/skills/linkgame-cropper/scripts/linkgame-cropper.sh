#!/usr/bin/env bash
# =============================================================================
# 连连看牌面裁剪工具 (LinkGame Tile Cropper)
# 对文件夹内的 PNG/JPG 图片裁剪为 64×64、128×128、192×192 三种尺寸，
# 文件名按 @1x/@2x/@3x 命名规范输出。
# 跨平台支持：macOS / Linux / Windows (Git Bash / WSL)
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# 1. 平台检测
# ---------------------------------------------------------------------------
detect_os() {
  case "$(uname -s 2>/dev/null || echo "Unknown")" in
    Darwin)  PLATFORM="macOS"    ;;
    Linux)   PLATFORM="Linux"    ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="Windows" ;;
    *)       PLATFORM="Unknown"  ;;
  esac
  printf '%s\n' "$PLATFORM"
}
PLATFORM=$(detect_os)

# ---------------------------------------------------------------------------
# 2. 检测 ImageMagick，未安装则尝试自动安装
# ---------------------------------------------------------------------------
if ! command -v convert >/dev/null 2>&1; then
  echo "🔍 未检测到 ImageMagick (convert)，正在尝试自动安装..."

  case "$PLATFORM" in
    macOS)
      if ! command -v brew >/dev/null 2>&1; then
        echo "❌ 请先安装 Homebrew：https://brew.sh"
        echo "   安装完成后执行: brew install imagemagick"
        exit 1
      fi
      brew install imagemagick
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y -qq imagemagick
      elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y imagemagick
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y imagemagick
      elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm imagemagick
      else
        echo "❌ 未检测到包管理器，请手动安装 ImageMagick"
        exit 1
      fi
      ;;
    Windows)
      if command -v choco >/dev/null 2>&1; then
        choco install imagemagick -y
      elif command -v winget >/dev/null 2>&1; then
        winget install ImageMagick.ImageMagick
      elif command -v scoop >/dev/null 2>&1; then
        scoop install imagemagick
      else
        echo "❌ 请手动安装 ImageMagick: https://imagemagick.org/script/download.php"
        exit 1
      fi
      ;;
    *)
      echo "❌ 未知平台 ($PLATFORM)，请手动安装 ImageMagick"
      exit 1
      ;;
  esac

  # 安装后再次验证
  if command -v convert >/dev/null 2>&1; then
    echo "✅ ImageMagick 安装完成"
  else
    echo "❌ ImageMagick 安装后仍不可用，请手动安装"
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# 3. 解析参数
# ---------------------------------------------------------------------------
INPUT_DIR="${1:-.}"
cd "$INPUT_DIR" >/dev/null 2>&1 || {
  echo "❌ 无法进入目录: $INPUT_DIR"
  exit 1
}

echo "📂 工作目录: $(pwd)"

# ---------------------------------------------------------------------------
# 4. 尺寸配置
# ---------------------------------------------------------------------------
SIZES=(
  "64:64@1x"
  "128:64@2x"
  "192:64@3x"
)

# ---------------------------------------------------------------------------
# 5. 遍历图片文件
# ---------------------------------------------------------------------------
count_total=0
count_skip=0
count_processed=0

# 跨平台 glob：shopt -s nullglob 对 Windows MSYS 兼容
shopt -s nullglob 2>/dev/null || true

for img in *.png *.jpg *.jpeg *.PNG *.JPG *.JPEG; do
  [ -f "$img" ] || continue
  count_total=$((count_total + 1))

  # 如果文件名已包含裁剪后缀则跳过
  if printf '%s' "$img" | grep -qE '64@(1x|2x|3x)\.[^.]+$'; then
    echo "⏭️  跳过已裁剪文件: $img"
    count_skip=$((count_skip + 1))
    continue
  fi

  base="${img%.*}"
  ext="${img##*.}"
  echo "✂️  处理: $img"

  # 对每种尺寸执行裁剪
  for size_entry in "${SIZES[@]}"; do
    px="${size_entry%%:*}"           # 64
    suffix="${size_entry#*:}"         # 64@1x
    output="${base}${suffix}.${ext}"

    if [ -f "$output" ]; then
      echo "  ⏭️  已存在: $output"
      continue
    fi

    convert "$img" \
      -resize "${px}x${px}^" \
      -gravity center \
      -extent "${px}x${px}" \
      "$output"

    echo "  ✅ 创建: $output (${px}×${px})"
  done

  count_processed=$((count_processed + 1))
done

echo ""
echo "========================================"
echo " ✅ 处理完成"
echo "    总文件: $count_total"
echo "    已跳过: $count_skip"
echo "    已处理: $count_processed"
echo "========================================"
