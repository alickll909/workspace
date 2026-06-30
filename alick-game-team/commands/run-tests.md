---
description: 依据详细设计编写测试用例或执行测试
argument-hint: [测试任务]
allowed-tools: Read, Write, Bash(git:*)
---

启动 senior-game-tester agent 执行测试相关任务。

**执行步骤：**

1. 用 Agent tool 启动 `senior-game-tester` agent
2. 如果 `$ARGUMENTS` 包含"用例"，传入：
   > 依据详细设计编写测试用例，输出到 `docs/test-cases/` 目录
3. 如果 `$ARGUMENTS` 包含"执行"或为空，传入：
   > 依据代码和测试用例执行测试，输出测试报告到 `docs/reports/` 目录
4. agent 完成后告知用户产出路径
