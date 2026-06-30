---
description: 一键初始化 Agent Team 环境（首次使用先执行此命令）
allowed-tools: Read, Write
---

一键初始化 Agent Team 环境。执行以下步骤：

**执行步骤：**

1. 检查 `.claude/settings.local.json` 是否已包含 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
   - 如果未设置，使用 `!`cat` 读取文件，使用 Write 工具追加到 `env` 字段中
   - 格式：`"env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }`

2. 将插件内的 `agents.yaml` 复制到项目 `.claude/agents.yaml`
   - `!`cp alick-game-teamv2/agents.yaml .claude/agents.yaml``

3. 将 5 个 agent 定义文件复制到 `.claude/agents/`
   - `!`mkdir -p .claude/agents``
   - `!`cp alick-game-teamv2/agents/*.md .claude/agents/``

4. 创建共享记忆目录
   - `!`mkdir -p docs/team-memory``

5. 输出配置摘要：
   ```
   ✅ Agent Team 环境初始化完成
   
   📋 配置摘要
   - agents.yaml: .claude/agents.yaml
   - Agents: 5（pd, tech-architect, coder, code-reviewer, tester）
   - 共享记忆: docs/team-memory/
   - Agent Teams: 已启用（CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1）
   
   可用命令：
   /team-deliver [需求描述] - 启动需求交付流程
   /team-daily              - 汇总日报
   /team-bugfix [缺陷描述]   - 启动缺陷修复流程
   ```
