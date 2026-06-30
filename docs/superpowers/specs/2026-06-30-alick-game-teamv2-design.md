# alick-game-teamv2 设计文档

> 基于 Claude Code Agent Teams 的多 Agent 游戏开发协作插件

- **版本**: 1.0.0
- **日期**: 2026-06-30
- **作者**: Alick Liu

---

## 1. 背景

现有 `alick-game-team` 插件通过主会话手动调度 subagent，采用"PM 逐个调用 Agent tool + 人工转达上下文"的协作模式。Claude Code 2026 年推出的 **Agent Teams** 实验特性支持 peer-to-peer 协作、共享 Task 队列、inbox 消息系统。

v2 目标：利用 Agent Teams 能力，让 agent 团队自主协作，减少人工调度，并通过共享记忆层解决上下文孤岛问题。

## 2. 技术栈

| 组件 | 技术方案 |
|------|---------|
| Agent 协作模型 | Agent Teams（实验性，`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`） |
| Agent 层级定义 | `agents.yaml`（支持 3 级 `delegate_to` 嵌套） |
| Agent 定义格式 | Markdown + YAML frontmatter |
| 最低 Claude Code 版本 | v2.1.32+ |
| 共享记忆层 | 文件系统（`docs/team-memory/`） |

## 3. 团队拓扑结构

采用 **分层嵌套模式**：PD 和架构师为独立顶层 agent；coder 为父级，下属 code-reviewer 和 tester。

```
主会话 (Team Lead)
├── senior-game-pd                  [产品设计 - 独立顶层]
├── senior-game-tech-architect      [架构设计 - 独立顶层]
└── senior-game-coder               [开发 - 父级]
    ├── senior-game-code-reviewer   [子级 - 代码审查]
    └── senior-game-tester          [子级 - 测试]
```

### agents.yaml

```yaml
max_depth: 3
agents:
  - agent_role: senior-game-pd
    description: "轻游戏行业高级产品经理，负责需求拆解、竞品调研、PRD输出"
  - agent_role: senior-game-tech-architect
    description: "游戏行业技术架构师，负责架构设计与评审"
  - agent_role: senior-game-coder
    description: "高级游戏程序员，负责需求拆分、编码实现"
    delegate_to:
      - agent_role: senior-game-code-reviewer
        description: "代码审查专家，关注架构遵循、代码风险、安全漏洞"
      - agent_role: senior-game-tester
        description: "高级游戏测试工程师，负责测试用例编写、测试执行、UI评分"
```

## 4. Agent 定义

所有 agent 去掉 v1 中大量重复的持久化记忆系统模板（约 300 行/个），只保留角色特有指令。每个 agent 使用以下 frontmatter 字段：

| 字段 | 值 | 说明 |
|------|-----|------|
| `name` | kebab-case 标识 | 与 agents.yaml 中的 agent_role 一致 |
| `description` | 一行描述 | Agent tool 自动匹配依据 |
| `tools` | 工具列表 | 按角色精简 |
| `model` | inherit / Sonnet | tester 用 Sonnet（视觉能力），其余 inherit |
| `memory` | project | 项目级记忆 |

### senior-game-pd

```yaml
name: senior-game-pd
description: "轻游戏行业高级产品经理，负责需求拆解、竞品调研、PRD输出"
tools: Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch
model: inherit
memory: project
```

职责：
- 需求拆解：核心链路 vs 旁支链路，S0/P1/P2/P3 优先级
- 竞品调研：≥3 款同类游戏分析
- 产品方案：核心规则、心流路径、原型描述
- PRD 输出到 `docs/prd/`

### senior-game-tech-architect

```yaml
name: senior-game-tech-architect
description: "游戏行业技术架构师，负责架构设计与评审"
tools: Read, Write, WebFetch, WebSearch, Bash, Grep
model: inherit
memory: project
```

职责：
- 分析 PRD，产出架构设计文档到 `docs/architecture/`
- 评审 coder 的详细设计是否符合架构规范

### senior-game-coder

```yaml
name: senior-game-coder
description: "高级游戏程序员，负责需求拆分、编码实现、响应审查反馈"
tools: Read, Write, TaskCreate, TaskGet, Bash, Grep, Git
model: inherit
memory: project
```

职责：
- 分析 PRD 和架构设计，拆分为可交付任务
- 编码开发，git commit
- 响应 code-reviewer 审查反馈
- 编码完成后自动 delegate 给 senior-game-code-reviewer 审查

### senior-game-code-reviewer

```yaml
name: senior-game-code-reviewer
description: "代码审查专家，关注架构遵循、代码风险、安全漏洞"
tools: Read, Write, Bash, Grep
model: inherit
memory: project
```

职责：
- git diff 获取变更，对照架构设计审查
- 报告输出到 `docs/cr/YYYY-MM-DD-{scope}-review.md`
- 通过后自动 delegate 给 senior-game-tester 回归测试

### senior-game-tester

```yaml
name: senior-game-tester
description: "高级游戏测试工程师，负责测试用例编写、测试执行、UI评分"
tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch, WebSearch, Git
model: Sonnet
memory: project
```

职责：
- 编写测试用例到 `docs/test/cases/`
- 执行测试，产出报告到 `docs/test/reports/`
- 前端 UI 变更执行 UI 评分（审美 0-5 + 交互 0-5，总分 < 8 打回 PD）
- 回归测试通过后通知父级 agent

## 5. 共享记忆层

> 解决 Agent Teams 模式下各 teammate 独立上下文导致的"上下文孤岛"问题。

### 存储结构

```
docs/team-memory/
├── MEMORY_INDEX.md           ← 索引：列出所有摘要
├── 2026-06-30_1430_pd_prd-v2.md
├── 2026-06-30_1500_arch_review.md
├── 2026-06-30_1530_coder_impl-login.md
├── 2026-06-30_1545_reviewer_cr-login.md
└── 2026-06-30_1600_tester_test-login.md
```

### 摘要文件格式

每个 agent 完成任务后写入：

```markdown
---
role: senior-game-coder
task: "实现用户登录功能"
status: completed
artifacts:
  - "src/auth/login.ts"
decisions:
  - "使用 JWT 而非 Session"
handoff_to: senior-game-code-reviewer
next_steps: "代码已提交，等待 code-reviewer 审查"
---

## 完成摘要

实现了用户登录功能...
```

### 读写规则

- **写入时机**：每个 agent 完成其核心任务后，自动写入一份摘要到 `docs/team-memory/`
- **读取时机**：每个 agent 启动时，按时间倒序读取 `docs/team-memory/` 下最近的 N 条摘要（N 以 tokening 预算动态决定，最多 5 条），理解当前项目上下文
- **生命周期**：摘要文件属于项目产物，随代码仓库版本控制

## 6. 目录结构

```
alick-game-teamv2/
├── agents.yaml                    ← 根目录，团队层级定义
├── README.md
├── .claude-plugin/
│   └── plugin.json                ← 插件元信息
├── agents/                        ← 5 个 agent .md 文件
│   ├── senior-game-pd.md
│   ├── senior-game-tech-architect.md
│   ├── senior-game-coder.md
│   ├── senior-game-code-reviewer.md
│   └── senior-game-tester.md
├── commands/                      ← 4 个核心命令
│   ├── init-team.md               ← 团队初始化（自动部署 agent team 配置）
│   ├── team-deliver.md            ← 需求交付流程
│   ├── team-daily.md              ← 日报汇总
│   └── team-bugfix.md             ← 缺陷修复流程
└── skills/                        ← 复用 v1 技能
    └── ...
```

## 7. 命令定义

### /init-team

一键初始化 Agent Team 环境：

1. 检查 `.claude/settings.local.json`，若未设置 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 则自动追加
2. 将 `agents.yaml` 写入 `.claude/agents.yaml`
3. 将 agent .md 文件复制到 `.claude/agents/`（或 symlink）
4. 验证 Claude Code 版本 ≥ v2.1.32
5. 创建 `docs/team-memory/` 目录
6. 输出配置摘要

### /team-deliver [需求描述]

启动需求交付流程（利用 Agent Teams 共享 Task 队列）：

1. 创建 Team Task：`senior-game-pd → 编写 PRD`
2. Task 完成后自动创建下一个 Task
3. 流程链：PD → 架构师 → Coder（→ Reviewer → Tester）
4. 每步 agent 自动写入共享记忆摘要
5. 主会话监控进度，最后汇总交付物

### /team-daily

日报汇总（利用团队并行能力）：

1. 分配日报 Task 到各 agent
2. agent 并行写入 `docs/daily/YYYY-MM-DD-{role}.md`
3. 主会话收集汇总写入 `docs/daily/YYYY-MM-DD-daily-report.md`
4. commit & push

### /team-bugfix [缺陷描述]

缺陷修复（利用 coder → reviewer → tester 链式 delegate）：

1. 创建 Team Task 指派给 senior-game-coder
2. coder 修复后自动 delegate 给 code-reviewer 审查
3. reviewer 通过后自动 delegate 给 tester 回归
4. 回归通过则提交，否则返回 coder 循环

## 8. 协作流程对比

| 流程 | v1（手动调度） | v2（Agent Teams） |
|------|---------------|-------------------|
| **交付流程** | PM 逐个手动 Agent tool 调用，等一个完成再进入下一阶段 | PM 分配 Task 到团队队列，agent 自动认领；coder 自动 delegate 给 reviewer → tester |
| **缺陷修复** | PM 手工转达审查意见给 coder | coder 修复后自动 delegate 给 reviewer，通过后 delegate 给 tester |
| **日报** | PM 并行发 5 个 Agent tool 调用 | PM 分配日报 Task，各 agent 并行认领 |
| **上下文传递** | PM 在 prompt 中手动拼接 | 共享记忆层自动读写 `docs/team-memory/` |
| **PM 手动调度** | 大量 | 最小化（仅初始分配 Task） |

## 9. 迁移策略

- **不删除 v1**：`alick-game-team` 保留不动，v2 作为独立插件 `alick-game-teamv2`
- **共享记忆目录兼容**：v2 输出的 `docs/test/`、`docs/cr/`、`docs/prd/` 等路径与 v1 一致
- **skills 复用**：所有 v1 技能文件通过 symlink 引用，不重复拷贝
- **用户选择**：用户可选择继续使用 v1 或切换到 v2

## 10. 已知限制

| 限制 | 说明 |
|------|------|
| Agent Teams 为实验特性 | 需设置环境变量启用，可能存在稳定性问题 |
| 每 agent 独立上下文 | 共享记忆层通过文件系统弥补，但非实时同步 |
| 版本要求 | 需要 Claude Code v2.1.32+ |
| 不兼容 v1 | v1 的 `/init-flow` 产生的 `.claude/senior-game-interaction.md` 不再需要 |

## 11. 交付物清单

| 交付物 | 说明 |
|--------|------|
| `alick-game-teamv2/` | 插件根目录 |
| `agents.yaml` | 3 级嵌套团队定义 |
| `agents/senior-game-pd.md` | 精简版 agent 定义 |
| `agents/senior-game-tech-architect.md` | 精简版 agent 定义 |
| `agents/senior-game-coder.md` | 精简版 agent 定义 + delegate 指令 |
| `agents/senior-game-code-reviewer.md` | 精简版 agent 定义 + delegate 指令 |
| `agents/senior-game-tester.md` | 精简版 agent 定义 + Sonnet 模型 |
| `commands/init-team.md` | 自动部署命令 |
| `commands/team-deliver.md` | 交付流程命令 |
| `commands/team-daily.md` | 日报命令 |
| `commands/team-bugfix.md` | 缺陷修复命令 |
| `.claude-plugin/plugin.json` | 插件元信息 |
| `README.md` | 使用说明 |
