# alick-game-team

游戏开发团队插件 — 8 个技能 + 7 个 senior agent + 7 个命令，覆盖轻游戏项目从需求到测试的全交付流程。

## 安装

```bash
/plugin marketplace add git@github.com:alickll909/workspace.git
/plugin install alick-game-team
```

重新打开 Claude Code 会话后生效。

## 命令

| 命令 | 用途 | 调度的 Agent |
|------|------|-------------|
| `/init-flow` | **初始化项目交付流程** — 检测 subagent 安装情况，生成团队交互规范 | senior-game-pm |
| `/deliver-requirement [需求描述]` | **需求交付流程** — PD→架构→开发→审查→测试全链路 | 全体 agent |
| `/daily-report` | **日报汇总** — 并行收集各角色日报，合并生成项目日报 | 全体 agent |
| `/bug-fix [缺陷描述]` | **缺陷修复流程** — 开发修复→审查→测试回归 | coder + reviewer + tester |
| `/code-review` | **代码审查** — 审查当前变更，输出报告到 `docs/cr/` | senior-game-code-reviewer |
| `/run-tests [用例/执行]` | **测试任务** — 编写测试用例或执行测试 | senior-game-tester |
| `/plugin-help` | 显示本帮助信息 | — |

**快速开始：** 首次使用先执行 `/init-flow`。

## Agent

| Agent | 角色 |
|-------|------|
| senior-game-pm | 多 Agent 协作规范初始化器 |
| senior-game-pd | 产品经理 — 需求拆解、调研、PRD |
| senior-game-tech-architect | 技术架构师 — 架构设计与评审 |
| senior-game-coder | 开发工程师 — 需求拆解、代码编写 |
| senior-game-code-reviewer | 代码审查员 — 代码变更审查 |
| senior-game-tester | 测试工程师 — 测试用例与执行 |
| tester | 基础测试用例编写 |

## 技能

| 技能 | 用途 |
|------|------|
| agent-writer | 按标准格式创建 Claude Code agent |
| application-use-initializer | 检测平台、安装自动化测试工具到 Claude 环境 |
| backend-api-standards | RESTful API 开发规范（Node.js/Express） |
| claude-commit | 以 Claude Code 身份提交代码 |
| guizang-ppt-skill-main | 生成单文件 HTML 横向滚动网页 PPT |
| linkgame-cropper | 裁剪 PNG/JPG 图片为连连看牌面 |
| skill-writer | 按标准格式创建 Claude Code skill |
| update-claude-permissions | 同步权限模板到 settings.json |

## 完整交付流程

启动 `/init-flow` 后，项目将按照以下流程运作：

```
需求 → PRD → 架构评审 → 范围确认 → 详细设计 → 设计评审
→ 测试用例 → 用例评审 → 编码 → 代码审查 → 测试执行
→ 缺陷修复 → 回归测试 → 交付确认
```

详见生成的 `.claude/senior-game-interaction.md`。

## 版本对比

| 维度 | v1（alick-game-team） | v2（alick-game-teamv2） |
|------|----------------------|------------------------|
| **协作模式** | PM 手动 Agent tool 逐个调用，等一个完成再进入下一阶段 | Agent Teams 共享 Task 队列 + `delegate_to` 自动链式，agent 间自主协作 |
| **上下文传递** | PM 在 prompt 中手动拼接 | `docs/team-memory/` 共享记忆层自动读写 |
| **Agent 定义** | 7 个角色，每个 300-500 行（含大量记忆模板） | 5 个核心角色，精简到 ~50 行（去掉冗余模板） |
| **命令数量** | 7 个 | 4 个（利用自动 delegate，去掉 code-review / run-tests） |
| **技术基础** | Subagent（标准机制） | Agent Teams（实验特性，需 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`） |
| **适用场景** | 稳定可靠，适合需要精确控制每步调度 | 高效自主，适合减少人工介入的持续开发流程 |

> v1 和 v2 相互独立，可同时安装。选择 v1 获得稳定可控的调度，选择 v2 获得自主协作的效率。
