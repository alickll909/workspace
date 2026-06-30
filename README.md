# Workspace

Claude Code 工作空间，包含游戏开发相关的技能（skills）、子代理（subagents）和插件（plugin）。

## 目录结构

```
.
├── .claude-plugin/marketplace.json   # Plugin marketplace 注册文件
├── alick-game-team/                  # Claude Code 插件包
│   ├── skills/                       #   8 个技能
│   ├── agents/                       #   7 个子代理
│   └── commands/                     #   7 个命令
├── skills/                           # 技能（独立目录，插件的源文件）
│   ├── agent-writer/                 #   创建 Claude Code agent
│   ├── application-use-initializer/  #   安装自动化测试工具
│   ├── backend-api-standards/        #   RESTful API 开发规范
│   ├── claude-commit/                #   以 Claude Code 身份提交
│   ├── guizang-ppt-skill-main/       #   生成网页 PPT
│   ├── linkgame-cropper/             #   裁剪连连看牌面
│   ├── skill-writer/                 #   创建 Claude Code skill
│   └── update-claude-permissions/    #   同步权限模板
├── subagents/                        # 子代理定义
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
/plugin install alick-game-team
```

重开会话后可使用 `/init-flow` 等命令启动游戏项目交付流程。

## 许可证

MIT
