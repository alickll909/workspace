#!/usr/bin/env bash
# 检查并安装 alick-game-teamv2 插件所需的依赖工具
# 在 /init-team 中自动调用

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== 检查依赖工具 ==="

# 1. glm-cogview-zijie
if npm list -g glm-cogview-zijie 2>/dev/null | grep -q glm-cogview-zijie; then
  echo -e "${GREEN}✔ glm-cogview-zijie${NC}"
else
  echo -e "${YELLOW}✗ glm-cogview-zijie 未安装，正在安装...${NC}"
  npm install -g glm-cogview-zijie
  echo -e "${GREEN}✔ glm-cogview-zijie 安装完成${NC}"
fi

# 2. glm-vision-mcp-server
if npm list -g glm-vision-mcp-server 2>/dev/null | grep -q glm-vision-mcp-server; then
  echo -e "${GREEN}✔ glm-vision-mcp-server${NC}"
else
  echo -e "${YELLOW}✗ glm-vision-mcp-server 未安装，正在安装...${NC}"
  npm install -g glm-vision-mcp-server
  echo -e "${GREEN}✔ glm-vision-mcp-server 安装完成${NC}"
fi

# 3. zai-mcp-server (@z_ai/mcp-server)
if which zai-mcp-server 2>/dev/null; then
  echo -e "${GREEN}✔ zai-mcp-server${NC}"
else
  echo -e "${YELLOW}✗ zai-mcp-server 未安装，正在安装...${NC}"
  npm install -g @z_ai/mcp-server
  echo -e "${GREEN}✔ zai-mcp-server 安装完成${NC}"
fi

echo ""
echo "=== 环境变量检查 ==="
if [ -n "$ZHIPU_API_KEY" ]; then
  echo -e "${GREEN}✔ ZHIPU_API_KEY 已设置${NC}"
else
  echo -e "${YELLOW}⚠ ZHIPU_API_KEY 未设置，glm-cogview-zijie 和 glm-vision-mcp-server 需要此变量${NC}"
fi

echo ""
echo "=== 依赖检查完成 ==="
