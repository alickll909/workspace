---
description: 启动缺陷修复流程（开发→审查→测试→回归）
argument-hint: [缺陷描述]
allowed-tools: TaskCreate, Read, Write, Bash(git:*)
---

执行交互规范中定义的缺陷修复流程。

**执行步骤：**

1. 读取 `.claude/senior-game-interaction.md` 确认流程
2. 创建 Task 记录缺陷信息
3. 用 Agent tool 启动 `senior-game-coder` agent，传入：
   > 缺陷描述：$ARGUMENTS
   > 请分析缺陷并修复，提交修复代码
4. 收到修复代码后，用 Agent tool 启动 `senior-game-code-reviewer` agent 审查
5. 审查不通过 → 将审查意见转达 coder，返回步骤 3
6. 审查通过 → 用 Agent tool 启动 `senior-game-tester` agent 测试修复
7. 测试存在缺陷 → 返回步骤 3
8. 测试通过 → 通知 coder 提交到仓库，关闭任务
