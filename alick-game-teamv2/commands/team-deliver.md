---
description: 启动需求交付流程，利用 Agent Teams 实现 PD→架构→开发→审查→测试 全链路自主协作
argument-hint: [需求描述]
allowed-tools: Read, Write
---

利用 Agent Teams 的共享 Task 队列和分层 delegate 机制启动需求交付流程。

**执行步骤：**

1. 确保 `.claude/agents.yaml` 存在（如果没有，先执行 `/init-team`）

2. 读取 `docs/team-memory/` 确认当前项目进度上下文

3. 在 Team Task 队列中创建任务链（按以下顺序依次创建 Task）：
   - Task 1: `senior-game-pd → 编写 PRD`，传入 `$ARGUMENTS` 作为需求描述
   - Task 2: `senior-game-tech-architect → 架构评审/设计`
   - Task 3: `senior-game-coder → 开发实现`

4. 监控 Task 进度：
   - Task 1（PD）完成后 → 通知架构师 Task 2 已就绪
   - Task 2（架构师）完成后 → 通知 coder Task 3 已就绪
   - Task 3（coder）启动后，自动 delegate 给 code-reviewer → tester
   - 各 agent 通过共享记忆层同步上下文

5. **交付停止条件**：tester 执行的测试中，S0、P1 级别用例通过率必须达到 **100%**，方可视为测试通过
6. 测试通过后，汇总交付物并告知用户项目达到可交付状态

**共享记忆同步：**
- 每完成一个 Task，对应 agent 会自动写入摘要到 `docs/team-memory/`
- 主会话定期检查 `docs/team-memory/` 了解进度
