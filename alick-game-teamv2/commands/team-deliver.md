---
description: 启动需求交付流程，利用 Agent Teams 实现 PD→架构→开发→审查→测试 全链路自主协作，每步输出经验证者评分
argument-hint: [需求描述]
allowed-tools: Read, Write
---

利用 Agent Teams 的共享 Task 队列和分层 delegate 机制启动需求交付流程。
每一步工作完成后，由验证者（senior-game-validator）评分，及格方可进入下一步。

**执行步骤：**

1. 确保 `.claude/agents.yaml` 存在（如果没有，先执行 `/init-team`）

2. 读取 `docs/team-memory/` 确认当前项目进度上下文

3. 在 Team Task 队列中创建任务链（按以下顺序依次创建 Task）：
   - Task 1: `senior-game-pd → 编写 PRD`，传入 `$ARGUMENTS` 作为需求描述
   - 待验证评分通过后 →
   - Task 2: `senior-game-tech-architect → 架构评审/设计`
   - 待验证评分通过后 →
   - Task 3: `senior-game-coder → 开发实现`

4. **验证门禁机制**：每步 agent 完成后，自动创建验证 Task 分配给 `senior-game-validator`：
   - 验证者对交付物评分（完成度 0-5 + 质量 0-5，总分 0-10）
   - **及格线**：总分 ≥ 6 分
   - **不及格**：将评分报告和扣分明细发给原 agent 重新执行 → 再次验证
   - **连续 3 次不及格**：写入 `docs/team-memory/ESCALATION_*` 标记，**停止流程，通知用户人工介入**
   - 及格后才进入下一步

5. 监控 Task 进度：
   - senior-game-pd → 验证 → 架构师 → 验证 → coder（→ reviewer → tester）
   - coder 启动后，自动 delegate 给 code-reviewer → tester（这些步骤同样需要验证）
   - 各 agent 通过共享记忆层同步上下文

6. **交付停止条件**：tester 执行的测试中，S0、P1 级别用例通过率必须达到 **100%**，方可视为测试通过
7. 测试通过后，汇总交付物并告知用户项目达到可交付状态

**共享记忆同步：**
- 每完成一个 Task，对应 agent 自动写入摘要到 `docs/team-memory/`
- 验证者的评分报告也写入 `docs/team-memory/`
- 主会话定期检查 `docs/team-memory/` 了解进度
