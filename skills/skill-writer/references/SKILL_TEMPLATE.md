# Skill 目录结构（标准格式）

```
my-first-skill/             # 目录名即 skill 名，全小写 + 连字符
├── SKILL.md                # ⭐ 唯一必需的核心文件（注意：必须全部大写）
├── scripts/                # 可选，放可执行脚本（Python/Bash）
├── references/             # 可选，放额外文档
└── assets/                 # 可选，放模板、图片等资源
```

# SKILL.md 模版

```markdown
---
name: my-skill                # 必须与目录名一致，全小写连字符，不要中文
description: 一句话描述技能功能及触发词
---

# 技能名称

## 角色定位
你是一名xxx，负责xxx。

## 核心规则（硬约束）
1. **规则一**：xxx
2. **规则二**：xxx

## 工作流程
1. 第一步：xxx
2. 第二步：xxx
```

# 关键注意事项

| 项目 | 正确做法 | 错误做法 |
|------|---------|---------|
| `name` | 全小写连字符，与目录名一致 | 中文名 |
| SKILL.md | 文件名全部大写 | `skill.md` / `Skill.md` |
| 脚本路径 | skill 目录内 `scripts/` 子目录 | 项目根 `scripts/` |
| symlink | 绝对路径 `ln -sf /full/path ~/.claude/skills/` | 相对路径 |
| SKILL.md 指令 | 描述性指令，让 Claude 自行解析 | 硬编码路径 |
