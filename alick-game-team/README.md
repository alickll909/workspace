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
