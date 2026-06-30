# alick-game-teamv2

游戏开发团队 v2 — 基于 **Claude Code Agent Teams** 的多 Agent 自主协作插件。

## v1 vs v2 核心区别

| 维度 | v1（alick-game-team） | v2（alick-game-teamv2，本插件） |
|------|----------------------|-------------------------------|
| **协作模式** | PM 逐个手动 Agent tool 调用，等一个完成再进入下一阶段 | Agent Teams 共享 Task 队列 + `delegate_to` 自动链式，agent 间自主协作 |
| **上下文传递** | PM 在 prompt 中手动拼接上下文 | `docs/team-memory/` 共享记忆层自动读写，各 agent 启动时自动同步 |
| **Agent 定义** | 7 个角色（含 senior-game-pm 初始化和基础 tester），每个 300-500 行 | 5 个核心角色（去掉 PM 初始化和基础 tester），精简到 ~50 行 |
| **命令数量** | 7 个命令（含独立的 code-review / run-tests） | 4 个命令（利用自动 delegate，code-review 和 run-tests 由 coder 自动调用） |
| **技术基础** | Subagent 标准机制 | Agent Teams 实验特性（需 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`） |
| **停止条件** | S0、P1 级别测试用例通过率 100% 方可交付 | 同 v1，S0、P1 通过率 100% 方可交付，通过共享记忆层自动判定 |
| **适用场景** | 稳定可靠，适合需要精确控制每步调度 | 高效自主，适合减少人工介入的持续开发流程 |

> v1 和 v2 相互独立，可同时安装。选择 v1 获得稳定可控的调度，选择 v2 获得自主协作的效率。

## 安装

```bash
/plugin marketplace add git@github.com:alickll909/workspace.git
/plugin install alick-game-teamv2
```

重新打开 Claude Code 会话后生效。

## 快速开始

首次使用先执行 **`/init-team`**，一键初始化 Agent Team 环境：
- 启用 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- 部署 `agents.yaml` 到 `.claude/`
- 安装 5 个 agent 到 `.claude/agents/`
- 创建共享记忆目录 `docs/team-memory/`

## 命令

| 命令 | 用途 |
|------|------|
| `/init-team` | **一键初始化 Agent Team 环境**（首次使用先执行） |
| `/team-deliver [需求描述]` | **需求交付流程** — PD→架构→开发(→审查→测试) 全链路自主协作 |
| `/team-daily` | **日报汇总** — 并行收集各角色日报，合并生成项目日报 |
| `/team-bugfix [缺陷描述]` | **缺陷修复流程** — coder 修复→自动 delegate 审查→自动 delegate 回归测试 |

## Agent 团队

```
主会话 (Team Lead)
├── senior-game-pd                 产品设计
├── senior-game-tech-architect     架构设计
└── senior-game-coder              开发
    ├── senior-game-code-reviewer  代码审查
    └── senior-game-tester         测试
```

## 共享记忆层

所有 agent 通过 `docs/team-memory/` 目录共享上下文：
- **写入**：每个 agent 完成任务后自动写入结构化摘要
- **读取**：每个 agent 启动时自动读取最近 5 条摘要

解决 Agent Teams 模式下各 teammate 独立上下文的"上下文孤岛"问题。

## 协作流程

```
/team-deliver "实现登录功能"

  → PD → 编写 PRD → 写入共享记忆
  → 架构师 → 架构评审 → 写入共享记忆
  → Coder → 编码实现 → 写入共享记忆
    → 自动 delegate code-reviewer → 审查 → 写入共享记忆
      → 自动 delegate tester → 回归测试 → 写入共享记忆
  ✓ 交付完成
```

```
/team-bugfix "登录按钮无响应"

  → Coder → 修复 → 写入共享记忆
    → 自动 delegate code-reviewer → 审查 → 写入共享记忆
      → 自动 delegate tester → 回归测试 → 写入共享记忆
  ✓ 缺陷已修复
```

## 技能

| 技能 | 用途 |
|------|------|
| agent-writer | 按标准格式创建 Claude Code agent |
| application-use-initializer | 检测平台、安装测试工具到 Claude 环境 |
| backend-api-standards | RESTful API 开发规范（Node.js/Express） |
| claude-commit | 以 Claude Code 身份提交代码 |
| guizang-ppt-skill-main | 生成单文件 HTML 横向滚动网页 PPT |
| linkgame-cropper | 裁剪 PNG/JPG 图片为连连看牌面 |
| skill-writer | 按标准格式创建 Claude Code skill |
| update-claude-permissions | 同步权限模板到 settings.json |
