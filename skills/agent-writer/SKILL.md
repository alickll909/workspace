---
name: agent-writer
description: 按标准格式创建 Claude Code agent（.md），参考 tester.md 模板，生成含 frontmatter、职责描述、持久化记忆系统的 agent 文件，并自动安装 symlink 到 ~/.claude/agents/。触发词：创建agent、写agent、编写agent、new agent、agent生成、新agent
---

# Agent 编写技能

## 角色定位
你是一名 Claude Code Agent 构建工具，负责按标准格式创建新的 agent（.md 文件）并自动完成安装，包括 frontmatter 编写、角色职责描述、工具权限配置、持久化记忆系统模板生成，以及在 `~/.claude/agents/` 下创建 symlink 使其可被 Agent tool 发现。参考模板为 `subagents/tester.md`。

## 核心规则（硬约束）

1. **目录即 agent 名**：agent 的 `name` 字段全小写连字符（如 `my-agent`），与文件名一致，禁止使用中文。
2. **文件位置**：agent `.md` 文件放在项目 `subagents/` 目录下（如 `subagents/my-agent.md`），如将来项目迁移到 `.claude/agents/` 则放在该目录下。
3. **frontmatter 标准**：必须包含 `name`、`description`、`tools`、`model`、`memory` 五个字段：
   - `description`：一句话描述 agent 角色和职责
   - `tools`：根据 agent 职责配置必要的工具集（参考现有 agent 的 tools 配置）
   - `model`：固定为 `inherit`
   - `memory`：固定为 `project`
4. **记忆系统模板**：持久化记忆系统部分直接复用 `subagents/tester.md` 中的完整记忆章节（从 `# 持久化智能体记忆` 开始到文件结束），将路径中的 `tester` 替换为当前 agent 的 name。
5. **职责描述**：在 frontmatter 之后、记忆系统之前，编写 agent 的角色描述和核心职责，风格参考现有 senior-game 系列 agent。
6. **不可保存内容**：不要在记忆系统中保存代码模式、git 历史、调试修复等已有代码记录的信息（详细规则见模板）。
7. **自动安装**：创建 agent `.md` 文件后，**必须自动执行安装** —— 在 `~/.claude/agents/` 下创建指向 `subagents/{name}.md` 的 symlink，使其可被 Agent tool 作为 `subagent_type` 发现。

## 工作流程

1. **确认需求**：向用户确认以下信息：
   - agent 名称（英文、全小写连字符）
   - agent 一句话描述（用于 frontmatter 的 description）
   - agent 核心职责（2-5 条关键职责）
   - agent 需要的工具集（从现有工具中选择：Read、Write、Edit、Bash、Grep、Glob、Git、WebFetch、WebSearch、TaskCreate、TaskGet、TaskList、TaskStop、TaskUpdate、NotebookEdit）
   - agent 所属项目位置（默认 `subagents/` 目录）
2. **读取参考模板**：读取 `subagents/tester.md` 获取完整的记忆系统章节。
3. **创建 agent 文件**：按以下结构写入 agent `.md` 文件到 `subagents/{name}.md`：
   - frontmatter（name、description、tools、model、memory）
   - 角色描述段落（1-2 句概述）
   - 核心职责章节（按需求列出关键职责和流程说明）
   - 持久化智能体记忆章节（从 tester.md 模板复制，替换路径中的 agent 名称）
4. **自动安装 symlink**：执行以下命令完成安装：
   ```bash
   ln -sf /Users/alickliu/Documents/projects/workspace/subagents/{name}.md ~/.claude/agents/{name}.md
   ```
5. **确认结果**：输出最终文件路径和安装状态，验证 symlink 已创建成功。

## 生成的 Agent 文件结构

```markdown
---
name: "my-agent"
description: "一句话描述"
tools: Read, Write, Bash, ...
model: inherit
memory: project
---

一段角色描述（1-2 句概述 agent 的定位和职责）。

# 核心职责

## 职责一
- 具体说明
- 具体说明

## 职责二
- 具体说明
- 具体说明

# 持久化智能体记忆
...（从 tester.md 模板完整复制，路径替换为当前 agent name）
```

## 安装验证

创建 agent 并安装 symlink 后，通过以下方式验证安装成功：

```bash
ls -la ~/.claude/agents/{name}.md     # 应显示 symlink 指向 subagents/{name}.md
```

安装完成后，该 agent 即可作为 `subagent_type` 被 Agent tool 发现和使用，senior-game-pm 等协调 agent 也可以通过 TeamCreate 或 SendMessage 直接调用该 agent。
