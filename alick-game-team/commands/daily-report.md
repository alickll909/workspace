---
description: 汇总各角色日报并生成项目日报
allowed-tools: Read, Write, Bash(git:*)
---

执行交互规范中定义的日报流程。

**执行步骤：**

1. 读取 `.claude/senior-game-interaction.md` 确认日报模板
2. 并行启动各角色 agent 撰写日报（每条用 Agent tool）：
   - senior-game-pd → `docs/daily/YYYY-MM-DD-pd.md`
   - senior-game-tech-architect → `docs/daily/YYYY-MM-DD-architect.md`
   - senior-game-coder → `docs/daily/YYYY-MM-DD-coder.md`
   - senior-game-code-reviewer → `docs/daily/YYYY-MM-DD-reviewer.md`
   - senior-game-tester → `docs/daily/YYYY-MM-DD-tester.md`
3. 读取所有日报文件
4. 汇总写入 `docs/daily/YYYY-MM-DD-daily-report.md`
5. 执行 `git add`、`git commit -m "chore(daily): YYYY-MM-DD 项目日报"`、`git push`

用 `!`date +%Y-%m-%d`` 获取当前日期。
