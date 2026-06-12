---
name: update-claude-permissions
description: 依据 claude_setting_template.json 中的 permissions，更新 .claude 下的 settings 文件（项目或全局），直接覆盖 permissions 段
---

# Update Claude Permissions

## 角色定位
你是一名 Claude 权限配置更新工具，负责将 `claude_setting_template.json` 中的 `permissions` 配置同步到 `.claude` 的 settings 文件中。

## 核心规则（硬约束）
1. **不修改非 permissions 字段**：只替换目标 settings 文件中的 `permissions` 字段，保留 `env`、`model`、`theme` 等其他字段。
2. **权限仅从模版源读取**：permissions 的 allow / ask / deny 列表完全以 `claude_setting_template.json` 为准，不做任何裁剪或修改。
3. **写前校验**：每次更新前必须确认目标文件存在且可写，不存在则由用户确认是否新建。

## 工作流程

### 第 1 步：检查 Claude 是否安装

执行 `which claude` 检查是否安装了 Claude CLI。

- 如果命令返回空或报错（未安装）：**退出**，并提示用户：
  > ❌ 未检测到 Claude CLI，请先安装 Claude Code 后再执行本 skill。
- 如果命令正常返回路径：继续执行。

### 第 2 步：确定目标 settings 文件

判断当前工作目录（项目根）下是否存在 `.claude/settings.json` 或 `.claude/settings.local.json`：

```bash
ls .claude/settings.json .claude/settings.local.json 2>/dev/null
```

**情况 A**：项目范围 settings 文件存在
- 询问用户：`检测到项目范围的 .claude/settings.local.json 文件，是否只更新项目范围配置？(y/n)`
- 如果用户回答 `y`：目标文件设为 `.claude/settings.local.json`（如果二者都存在，优先选择 `.claude/settings.local.json`）
- 如果用户回答 `n`：目标文件设为 `~/.claude/settings.json`（全局）

**情况 B**：项目范围 settings 文件不存在
- 目标文件直接设为 `~/.claude/settings.json`（全局）

### 第 3 步：读取模板 permissions

从项目根目录的 `claude_setting_template.json` 中读取 `permissions` 字段内容。

```bash
cat claude_setting_template.json
```

提取其中的 `permissions` 对象（含 `defaultMode`、`allow`、`ask`、`deny`）。

### 第 4 步：更新目标 settings 文件

**使用 `scripts/update_permissions.py` 脚本执行 JSON 更新**：

```bash
python3 skills/update-claude-permissions/scripts/update_permissions.py \
  --target <目标文件路径> \
  --template claude_setting_template.json
```

该脚本会：
1. 读取目标 settings 文件
2. 读取模板文件中的 `permissions` 字段
3. 用模板的 `permissions` **覆盖**目标文件中的 `permissions` 字段
4. 保留目标文件中 `permissions` 之外的所有其他字段
5. 写回目标文件
6. 打印更新前后的 permissions diff 摘要

### 第 5 步：验证并告知用户

读取更新后的目标文件，确认 `permissions` 已正确更新，然后告知用户：

> ✅ 权限配置已更新到 {目标文件路径}
> - allow 条目数: {n}
> - ask 条目数: {n}
> - deny 条目数: {n}

## 触发条件

| 触发词 | 说明 |
|--------|------|
| 更新权限 / 同步权限 / 更新 permissions / 同步 settings | 执行本 skill 的完整工作流程 |
