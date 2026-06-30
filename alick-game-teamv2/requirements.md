# alick-game-teamv2 依赖清单

## 必需运行时

| 依赖 | 版本 | 安装方式 | 用途 |
|------|------|---------|------|
| Claude Code | ≥ v2.1.32 | 官方安装 | Agent Teams 特性支持 |
| npm | ≥ 8.x | Node.js 内置 | 包管理器 |

## 可选工具（MCP 服务器）

| 工具 | 版本 | 安装命令 | 用途 | 必需密钥 |
|------|------|---------|------|---------|
| glm-cogview-zijie | ≥ 1.0.3 | `npm install -g glm-cogview-zijie` | 文生图（Ai绘画） | ZHIPU_API_KEY |
| glm-vision-mcp-server | ≥ 1.0.1 | `npm install -g glm-vision-mcp-server` | 图片理解/视觉分析 | ZHIPU_API_KEY |
| zai-mcp-server | latest | 见文档 | UI转代码、图片分析、视频分析 | — |

> 以上可选工具在 `/init-team` 初始化时会自动检查并提示安装。它们为 agent 提供图像生成、图片理解和 UI 转代码等 AI 多模态能力。
