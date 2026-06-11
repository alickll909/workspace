#!/bin/bash
# =============================================================================
# 连连看牌面裁剪工具 (LinkGame Tile Cropper)
# 对文件夹内的 PNG/JPG 图片裁剪为 64×64、128×128、192×192 三种尺寸，
# 文件名按 @1x/@2x/@3x 命名规范输出。
# =============================================================================

set -e

# ---------------------------------------------------------------------------
# 1. 检测 ImageMagick，未安装则自动安装
# ---------------------------------------------------------------------------
if ! command -v convert &>/dev/null; then
    echo "🔍 未检测到 ImageMagick，正在通过 Homebrew 安装..."
    if ! command -v brew &>/dev/null; then
        echo "❌ 请先安装 Homebrew：https://brew.sh"
        exit 1
    fi
    brew install imagemagick
    echo "✅ ImageMagick 安装完成"
fi

# ---------------------------------------------------------------------------
# 2. 解析参数
# ---------------------------------------------------------------------------
INPUT_DIR="${1:-.}"
cd "$INPUT_DIR" || {
    echo "❌ 无法进入目录: $INPUT_DIR"
    exit 1
}

echo "📂 工作目录: $(pwd)"

# ---------------------------------------------------------------------------
# 3. 尺寸配置
# ---------------------------------------------------------------------------
SIZES=(
    "64:64@1x"
    "128:64@2x"
    "192:64@3x"
)

# ---------------------------------------------------------------------------
# 4. 遍历图片文件
# ---------------------------------------------------------------------------
count_total=0
count_skip=0
count_processed=0

for img in *.png *.jpg *.jpeg *.PNG *.JPG *.JPEG; do
    [ -f "$img" ] || continue
    count_total=$((count_total + 1))

    # 如果文件名已包含裁剪后缀则跳过
    if echo "$img" | grep -qE '64@(1x|2x|3x)\.[^.]+$'; then
        echo "⏭️  跳过已裁剪文件: $img"
        count_skip=$((count_skip + 1))
        continue
    fi

    base="${img%.*}"
    echo "✂️  处理: $img"

    # 对每种尺寸执行裁剪
    for size_entry in "${SIZES[@]}"; do
        px="${size_entry%%:*}"           # 64
        suffix="${size_entry#*:}"         # 64@1x
        output="${base}${suffix}.${img##*.}"

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
