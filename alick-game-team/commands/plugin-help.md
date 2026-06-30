---
description: 列出 alick-plugin-test 的所有可用命令
allowed-tools: Read
---

列出 `alick-plugin-test` 插件中所有已注册的命令及其用途：

| 命令 | 用途 |
|------|------|
| `/init-flow` | 初始化项目多 Agent 交付流程（调用 senior-game-pm） |
| `/deliver-requirement` | 启动需求交付流程（调度 PD→架构→开发→审查→测试） |
| `/daily-report` | 汇总各角色日报并生成项目日报 |
| `/bug-fix` | 启动缺陷修复流程（开发→审查→回归） |
| `/code-review` | 审查当前代码变更（调用 senior-game-code-reviewer） |
| `/run-tests` | 编写测试用例或执行测试（调用 senior-game-tester） |
| `/plugin-help` | 显示本帮助信息 |

**快速开始：**
1. 首次使用先执行 `/init-flow` 初始化团队协作规范
2. 有新需求时执行 `/deliver-requirement [需求描述]`
3. 每日结束时执行 `/daily-report`
4. 发现缺陷时执行 `/bug-fix [缺陷描述]`
