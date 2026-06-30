# glm-cogview-zijie

智谱AI CogView 图像生成 MCP 服务器。

## 用途

文生图（Text-to-Image），支持多种模型：

- `cogview-4-250304`（最新，高清)
- `cogview-4`
- `cogview-3-flash`
- `glm-image`

支持自定义图像尺寸（如 1024x1024）、质量（hd/standard）、水印控制。

## 使用方式

```bash
# 直接使用
npx glm-cogview-zijie

# 或在 settings.json 中配置为 MCP 服务器：
# mcpServers.glm-cogview-zijie.command = "glm-cogview-zijie"
```

## 前置要求

- 已安装 `glm-cogview-zijie`（`npm install -g glm-cogview-zijie`）
- 环境变量 `ZHIPU_API_KEY` 已设置
