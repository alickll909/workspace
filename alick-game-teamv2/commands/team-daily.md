---
description: 汇总各角色日报并生成项目日报（利用团队并行能力）
allowed-tools: Read, Write, Bash(git:*)
---

利用 Agent Teams 的并行能力，由 Team Task 分配日报任务给各 agent，收集后汇总。

**执行步骤：**

1. 用 `!`date +%Y-%m-%d`` 获取当前日期 `YYYY-MM-DD`

2. 创建日报 Task 分配给各 agent（可并行触发）：
   - `senior-game-pd` → 写入 `docs/daily/YYYY-MM-DD-pd.md`
   - `senior-game-tech-architect` → 写入 `docs/daily/YYYY-MM-DD-architect.md`
   - `senior-game-coder` → 写入 `docs/daily/YYYY-MM-DD-coder.md`
   - `senior-game-code-reviewer` → 写入 `docs/daily/YYYY-MM-DD-reviewer.md`
   - `senior-game-tester` → 写入 `docs/daily/YYYY-MM-DD-tester.md`

3. agent 完成各自日报后写入文件

4. 读取所有日报文件，汇总内容写入 `docs/daily/YYYY-MM-DD-daily-report.md`

5. 执行 `git add`、`git commit -m "chore(daily): YYYY-MM-DD 项目日报"`、`git push`

**各 agent 日报模板：**
```markdown
# {角色名} 日报
**日期**: YYYY-MM-DD

## 今日工作
- {今日完成的工作事项}

## 遇到的问题
- {遇到的问题及解决方案}

## 明日计划
- {明日计划事项}
```
