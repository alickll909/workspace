---
description: 审查当前代码变更，输出审查报告到 docs/cr/
allowed-tools: Read, Bash(git:*), Write
---

启动 senior-game-code-reviewer agent 审查当前分支的代码变更。

**执行步骤：**

1. 收集上下文：
   - `!`git diff``
   - `!`git log --oneline -10``
   - 当前分支信息
2. 用 Agent tool 启动 `senior-game-code-reviewer` agent，传入完整 diff
3. agent 审查后将报告写入 `docs/cr/` 目录
4. 告知用户审查报告路径和审查结论
