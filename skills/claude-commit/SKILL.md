---
name: claude-commit
description: 以 Claude Code 的身份提交代码。当用户说"提交代码"、"commit"、"以claude身份提交"时触发。
---

# Claude Commit Skill

以 Claude Code 的身份执行 git commit，让 commit 的 author 显示为 Claude Code。

## 执行步骤

1. **检查暂存区**
   - 执行 `git diff --cached --stat` 查看有哪些文件待提交
   - 如果没有暂存文件，提示用户先 `git add`

2. **生成 commit message**
   - 根据 diff 内容生成规范的 commit message
   - 格式：`<type>(<scope>): <subject>`

3. **以 Claude 身份提交**
   - 使用环境变量临时覆盖 Git 作者信息：
   ```bash
   GIT_AUTHOR_NAME="Claude Code" \
   GIT_AUTHOR_EMAIL="noreply@anthropic.com" \
   GIT_COMMITTER_NAME="Claude Code" \
   GIT_COMMITTER_EMAIL="noreply@anthropic.com" \
   git commit -m "生成的message"