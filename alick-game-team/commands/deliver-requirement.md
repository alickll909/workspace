---
description: 启动需求交付流程，调度 PD/架构/开发/测试/审查团队
argument-hint: [需求描述]
allowed-tools: Read, Write
---

根据 senior-game-pm 初始化的交互规范（`.claude/senior-game-interaction.md`），启动需求交付流程。

如果交互规范文件不存在，先执行 `/init-flow`。

**执行步骤：**

1. 读取 `.claude/senior-game-interaction.md` 确认流程
2. 用 Agent tool 启动 `senior-game-pd` agent，传入需求描述：
   > 需求描述：$ARGUMENTS
   > 请编写 PRD 文档，输出到 `docs/prd/` 目录
3. 按交互规范中各阶段顺序逐个调度：
   - senior-game-pd → PRD
   - senior-game-tech-architect → 架构评审
   - senior-game-coder → 范围分析 + 详细设计
   - senior-game-tester → 测试用例
   - senior-game-coder → 编码开发
   - senior-game-code-reviewer → 代码审查
   - senior-game-tester → 测试执行
4. 每阶段等待交付物就绪后再进入下一阶段
5. 测试阶段要求 senior-game-tester 执行所有测试用例，**S0、P1 级别用例通过率达 100%** 方可视为测试通过
6. 全部完成后告知用户项目达到可交付状态
