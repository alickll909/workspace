---
description: 启动需求交付流程，利用 Agent Teams 实现 PD→架构→开发→审查→测试 全链路自主协作，每步输出经验证者评分
argument-hint: [需求描述]
allowed-tools: Read, Write, Agent
---

利用 Agent Teams 的共享 Task 队列和分层 delegate 机制启动需求交付流程。
**每步完成后必须由验证者评分，及格方可进入下一步。**

**执行步骤：**

1. 确保 `.claude/agents.yaml` 存在（如果没有，先执行 `/init-team`）

2. 读取 `docs/team-memory/` 确认当前项目进度上下文

3. **阶段一：产品设计 + 验证**
   - 用 Agent tool 启动 `senior-game-pd`，传入 `$ARGUMENTS`
   - 等待 PD 交付 PRD 到 `docs/prd/`
   - **用 Agent tool 启动 `senior-game-validator`**，传入：
     > 请验证 senior-game-pd 的 PRD 交付物（`docs/prd/`），按评分标准打分。≥ 6 分及格，< 6 分打回并说明扣分明细。
   - 不及格 → 返回 PD 修复 → 再次验证
   - **连续 3 次不及格** → 写入 ESCALATION 标记，通知用户人工介入，中止流程
   - 及格后进入阶段二

4. **阶段二：架构设计 + 验证**
   - 用 Agent tool 启动 `senior-game-tech-architect`，传入 PRD 内容
   - 等待架构师交付设计文档到 `docs/architecture/`
   - **用 Agent tool 启动 `senior-game-validator`**，传入：
     > 请验证 senior-game-tech-architect 的架构设计文档（`docs/architecture/`），按评分标准打分。
   - 不及格 → 返回架构师修复 → 再次验证，3 次不及格则触发人工介入
   - 及格后进入阶段三

5. **阶段三：编码 + 审查 + 测试 + 验证**
   - 用 Agent tool 启动 `senior-game-coder`，传入架构设计文档
   - coder 完成后自动 delegate 给 code-reviewer 审查
   - reviewer 通过后自动 delegate 给 tester 执行回归测试
   - **回归测试通过后**，用 Agent tool 启动 `senior-game-validator`，传入：
     > 请验证代码交付物和测试报告（`docs/cr/`、`docs/test/reports/`），按评分标准打分。
   - 不及格 → 返回 coder 修复 → 循环，3 次不及格则触发人工介入

6. **交付停止条件**：tester 执行的测试中 S0、P1 通过率 **100%**，且验证者评分 ≥ 6 分
7. 全部通过后汇总交付物，告知用户项目达到可交付状态

**验证失败处理：**
- 每次验证不及格，validator 会在 `docs/team-memory/` 写入带 `fail_count` 标记的摘要
- `fail_count` 达到 3 → 写入 `ESCALATION_*` 文件，通知用户人工介入
- 主会话定期检查 `docs/team-memory/` 确认是否有升级标记
