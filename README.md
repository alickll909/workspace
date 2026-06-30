# Workspace

Claude Code 工作空间，包含游戏开发相关的技能（skills）、子代理（subagents）和插件（plugins）。

## 目录结构

```
.
├── .claude-plugin/marketplace.json   # Plugin marketplace 注册文件
├── alick-game-team/                  # v1 插件：Subagent 模式
│   ├── skills/                       #   8 个技能
│   ├── agents/                       #   7 个子代理
│   └── commands/                     #   7 个命令
├── alick-game-teamv2/               # v2 插件：Agent Teams 模式
│   ├── agents.yaml                   #   团队层级定义（3 级嵌套）
│   ├── agents/                       #   5 个 agent
│   └── commands/                     #   4 个命令
├── skills/                           # 技能（独立目录，插件的源文件）
│   ├── agent-writer/                 #   创建 Claude Code agent
│   ├── application-use-initializer/  #   安装自动化测试工具
│   ├── backend-api-standards/        #   RESTful API 开发规范
│   ├── claude-commit/                #   以 Claude Code 身份提交
│   ├── guizang-ppt-skill-main/       #   生成网页 PPT
│   ├── linkgame-cropper/             #   裁剪连连看牌面
│   ├── skill-writer/                 #   创建 Claude Code skill
│   └── update-claude-permissions/    #   同步权限模板
├── subagents/                        # 子代理定义（v1 使用）
│   ├── senior-game-pm.md             #   协作规范初始化器
│   ├── senior-game-pd.md             #   产品经理
│   ├── senior-game-tech-architect.md #   技术架构师
│   ├── senior-game-coder.md          #   开发工程师
│   ├── senior-game-code-reviewer.md  #   代码审查员
│   ├── senior-game-tester.md         #   测试工程师
│   └── tester.md                     #   基础测试编写
└── claude_setting_template.json      # 权限模板
```

## Plugin 安装

```bash
/plugin marketplace add git@github.com:alickll909/workspace.git
```

**v1（Subagent 模式，稳定可控）：**
```bash
/plugin install alick-game-team
```
重开会话后可使用 `/init-flow` 启动交付流程。

**v2（Agent Teams 模式，自主协作）：**
```bash
/plugin install alick-game-teamv2
```
重开会话后先执行 `/init-team` 初始化 Agent Team 环境。

## v1 vs v2 对比

| 维度 | v1 | v2 |
|------|-----|-----|
| **协作模式** | PM 手动逐个 Agent tool 调用 | Agent Teams 共享 Task 队列 + `delegate_to` 自动链式 |
| **上下文传递** | PM 手动拼接 prompt | `docs/team-memory/` 共享记忆层自动读写 |
| **技术基础** | Subagent 标准机制 | Agent Teams 实验特性（需 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`） |
| **Agent 数量** | 7 个 | 5 个（去掉 PM 初始化和基础 tester） |
| **命令数量** | 7 个 | 4 个 |
| **停止条件** | S0、P1 测试用例通过率 100% | 同 v1 |
| **适用场景** | 精确控制每步调度 | 减少人工介入的持续开发 |

> 两个版本相互独立，可同时安装。共同遵循的交付停止条件：**S0、P1 级别测试用例通过率必须达到 100% 方可视为可交付。**

## 许可证

MIT
