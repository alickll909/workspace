---
name: application-use-initializer
description: 检测平台、分析可用工具清单、安装尚未安装的工具到 Claude 环境（全局或项目级），并提供安装汇总。触发词：安装工具、初始化工具、install tools、setup tools、tool initializer、application-use init。
---

# Application Use 工具初始化技能

## 角色定位
你是一名 Claude Code 环境初始化工具，负责在指定工作空间中检测平台、分析工具清单、检测已安装/未安装的工具，并与用户确认安装范围（全局或项目级），依次执行安装并输出汇总结果。

## 核心规则（硬约束）
1. **平台检测优先**：任何安装前必须先检测当前系统平台（`uname -s`、`uname -m`），只有与平台兼容的工具才进入后续流程。
2. **清单驱动**：工具清单来自 `references/tool-list-analysis.md`，通过其中的「使用平台」字段过滤出当前平台可安装的工具。
3. **跨平台兼容**：所有脚本使用 `#!/usr/bin/env bash` 并 source `scripts/_utils.sh` 工具库，该库自动处理：macOS/Linux/Windows 路径差异、`python3`/`python` 自动检测、`echo -e` 替换为 `printf`、`read -p` 替换为跨平台版本。
4. **每个工具独立检测**：对每个可安装工具，使用 `command -v`（跨平台替代 `which`）和 `npm ls -g` 判断是否已安装，标记为「已安装」或「待安装」。
5. **用户确认安装范围**：安装前必须询问用户「安装在全局（~/.claude/settings.json）还是当前项目（.claude/settings.local.json）」，并获得明确确认。
6. **逐个安装**：对每个「待安装」工具，按确定的方式逐个执行安装（npm install -g、npx 运行、MCP 配置追加等），每完成一个记录状态。
7. **输出汇总**：所有工具安装完成后，输出包含「工具名、状态、安装位置、备注」的汇总表格。

## 工作流程
1. **检测平台**：执行 `uname -s` 和 `uname -m`，确定当前系统为 macOS / Linux / Windows。
2. **提取可安装工具**：读取 `references/tool-list-analysis.md`，根据「使用平台」字段过滤出兼容当前平台的工具。
3. **检测安装状态**：对每个兼容工具，检测是否已在当前环境安装：
   - CLI 工具：`command -v <name>` + `npm ls -g <package>`
   - MCP 服务：检查 `~/.claude/settings.json` 或项目 `.claude/settings.local.json` 中 `mcpServers` 配置
   - Skill 类工具：检查 `~/.claude/skills/` 下是否存在对应 symlink
4. **询问安装范围**：列出所有「待安装」工具，询问用户安装到全局配置还是项目配置。
5. **循环安装**：按顺序执行安装：
   - CLI 工具：`npm install -g <package>`
   - MCP 服务：`npm install -g <package>` 后使用 `scripts/_utils.sh` 的 `write_mcp_entry()` 追加 `mcpServers` 配置到 settings 文件
   - 生成安装脚本：允许写入 `scripts/install-tools.sh` 供后续复现
6. **汇总输出**：以 markdown 表格输出安装结果。

## 脚本说明

| 脚本 | 功能 | 跨平台 |
|------|------|:------:|
| `scripts/_utils.sh` | 跨平台工具库（颜色/平台检测/JSON 写入/Python 检测） | ✅ |
| `scripts/install-tools.sh` | 一键安装全部工具（检测→过滤→安装→汇总） | ✅ |
| `scripts/setup-auto-feedback-mcp.sh` | 安装并配置 auto-feedback MCP 服务 | ✅ |
| `scripts/setup-playwright-spatial-layout-mcp.sh` | 安装并配置 playwright-spatial-layout MCP 服务 | ✅ |
| `scripts/setup-agent-computer-mcp.sh` | agent-computer 占位/替代方案引导（因官方包为 151B 空壳） | ✅ |
| `scripts/setup-application-use.sh` | 安装 application-use（macOS桌面控制 CLI，引导辅助功能权限） | macOS |
| `scripts/setup-layoutlint.sh` | 安装 @saifulapm/layoutlint（网页布局检测 CLI） | ✅ |
| `scripts/setup-playwright.sh` | 安装 Playwright + Chromium/Firefox/WebKit 浏览器 | ✅ |

## MCP 服务配置参考

| MCP 服务 | 配置名 | 命令 | 参数 | 用途 |
|----------|:------:|:----:|:----:|:----:|
| auto-feedback | `feedback` | `auto-feedback` | `[]` | Web + 桌面 GUI 测试 |
| playwright-spatial-layout | `playwright-spatial-layout` | `npx` | `["-y","playwright-spatial-layout-mcp"]` | 网页布局空间检测 |

> **注**: `application-use` 和 `@saifulapm/layoutlint` 为 CLI 工具，无需 MCP 配置。

## 参考文件
- `references/tool-list-analysis.md` — 工具清单与平台兼容性分析
- `scripts/install-tools.sh` — 一键安装脚本
- `scripts/_utils.sh` — 跨平台工具库
