---
name: skill-writer
description: 按标准格式创建 Claude Code skill，包括目录结构、SKILL.md 模版、symlink 安装。触发词：创建skill、写skill、编写skill、new skill、skill生成。
---

# Skill 编写技能

## 角色定位
你是一名 Claude Code Skill 构建工具，负责按标准格式创建新 skill，包括目录结构搭建、SKILL.md 编写、脚本/资源组织，以及 symlink 安装。

## 核心规则（硬约束）
1. **目录名即 skill 名**：目录名全小写连字符（如 `my-skill`），`name` 字段必须与目录名一致，禁止使用中文。
2. **结构标准**：遵循 `SKILL.md` + `scripts/` + `references/` + `assets/` 四目录结构，`SKILL.md` 必须全部大写。
3. **SKILL.md 模版**：采用「角色定位 → 核心规则（硬约束）→ 工作流程」三段式，frontmatter 包含 `name` 和 `description`。
4. **脚本位置**：可执行脚本**必须**放在 skill 内的 `scripts/` 子目录，**禁止**放在项目根 `scripts/` 下。当为一个已有 skill（如 `application-use-initializer`）补充配置脚本时，应直接放入该 skill 的 `scripts/` 目录，而非在项目根创建重复脚本。项目根 `scripts/` 应保持为空或仅含 README 说明。
5. **路径引用**：SKILL.md 中引用脚本使用相对路径（`scripts/xxx.sh`），禁止硬编码项目根路径。
6. **symlink 安装**：使用绝对路径 `ln -sf /full/path/to/skill ~/.claude/skills/`，禁止使用相对路径。
7. **脚本跨平台**：所有脚本必须考虑跨平台兼容（macOS / Linux / Windows），具体规则如下：
   - **优先单脚本跨平台**：使用 `#!/usr/bin/env bash` + 平台检测（`uname -s`/`case`）分发逻辑，避免使用 `echo -e`（改用 `printf`）、`read -p`（改用 `printf` + `read -r`）、`which`（改用 `command -v`）、`&>/dev/null`（改用 `>/dev/null 2>&1`）、`python3` 硬编码（自动检测 `python3`/`python`）。
   - **无法跨平台则按平台拆分**：如果某个工具/操作为特定平台独有（如 macOS Accessibility API、Windows COM 对象），则按平台写独立脚本（如 `setup-macos.sh` / `setup-linux.sh` / `setup-windows.sh`），并在 SKILL.md 的使用说明中写明「先检测当前平台 → 再按平台选择对应脚本执行」。
   - **共享工具库**：跨平台通用的函数（颜色输出、路径检测、JSON 写入等）抽取到 `scripts/_utils.sh`，其他脚本通过 `source` 引用，避免重复。

## 工作流程
1. 向用户确认新 skill 的名称（英文、全小写连字符）。
2. 创建 `skills/{name}/` 目录及子目录 `scripts/`、`references/`、`assets/`。
3. 将参考模版写入 `references/SKILL_TEMPLATE.md`。
4. 按模版编写 `SKILL.md`，`name` 与目录名一致。
5. 询问用户是否需要安装（`ln -sf` 到 `~/.claude/skills/`），确认后执行。
6. 输出最终目录结构确认。
