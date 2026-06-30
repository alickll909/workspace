---
description: 初始化项目多 Agent 交付流程（含依赖工具检查）
allowed-tools: Read, Write, Bash
---

启动 senior-game-pm agent 执行项目交付流程初始化。

senior-game-pm agent 会检测 `subagents/` 和 `~/.claude/agents/` 中已安装的 subagent，然后生成 `.claude/senior-game-interaction.md` 团队交互规范文件，并在 `.claude/CLAUDE.md` 中追加引用（如存在）。

**执行步骤：**

1. 用 Agent tool 启动 `senior-game-pm` agent
2. 将以下内容作为 prompt 传入：
   > 请检测项目 subagent 安装情况，生成交互规范文件 `.claude/senior-game-interaction.md`，并按规范追加引用到 `.claude/CLAUDE.md`
3. 等待 agent 完成任务
4. 安装依赖工具：
   - 执行 `!`npm list -g glm-cogview-zijie 2>/dev/null | grep -q glm-cogview-zijie || npm install -g glm-cogview-zijie``
   - 执行 `!`npm list -g glm-vision-mcp-server 2>/dev/null | grep -q glm-vision-mcp-server || npm install -g glm-vision-mcp-server``
   - 执行 `!`which zai-mcp-server 2>/dev/null || npm install -g @z_ai/mcp-server``
5. 告知用户交互规范文件已生成，依赖工具已安装，后续可按 `/deliver-requirement`、`/daily-report`、`/bug-fix` 等命令调度对应流程
