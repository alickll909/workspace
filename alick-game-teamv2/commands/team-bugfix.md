---
description: 启动缺陷修复流程，利用 Agent Teams 链式 delegate 实现修复→审查→回归自主协作，修复成果经验证者评分
argument-hint: [缺陷描述]
allowed-tools: TaskCreate, Read, Write, Agent, Bash(git:*)
---

利用 Agent Teams 的分层 delegate 机制（coder → reviewer → tester）完成缺陷修复。
修复交付后由验证者（senior-game-validator）评分，及格方可关闭。

**执行步骤：**

1. 读取 `docs/team-memory/` 了解当前项目上下文

2. 创建 Team Task 分配给 `senior-game-coder`：
   > 缺陷描述：$ARGUMENTS
   > 请分析缺陷并修复，提交修复代码

3. 后续流程由分层 delegate 机制自动完成：
   - coder 修复完成后 → 自动 delegate 给 `senior-game-code-reviewer` 审查
   - 审查不通过 → reviewer 将反馈发送回 coder → coder 修复 → 再次 delegate
   - 审查通过 → 自动 delegate 给 `senior-game-tester` 执行回归测试
   - 回归测试发现缺陷（S0、P1 级别用例未全部通过）→ 通知 coder 修复 → 再次启动修复→审查→测试循环
   - **回归测试通过条件**：S0、P1 级别用例通过率 **100%**

4. 回归测试通过后，**用 Agent tool 启动 `senior-game-validator`**，传入：
   > 请验证 coder 的修复质量和测试报告，按评分标准打分。≥ 6 分及格，< 6 分打回并说明扣分明细。
   - 及格 → 通知主会话确认修复完成
   - 不及格 → 将评分报告发给 coder 重新修复 → 再次验证
   - **连续 3 次不及格**：写入 `docs/team-memory/ESCALATION_*` 标记，**通知用户人工介入**

5. 各 agent 自动写入共享记忆摘要到 `docs/team-memory/`

6. 主会话监控进度，确认缺陷已修复后关闭 Task

**注意事项：**
- 主会话不需要手动转达审查意见，Agent Teams 的 delegate 和 inbox 机制自动处理
- 验证者的评分是最后的门禁，确保修复质量达标
