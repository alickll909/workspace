---
name: claude-commit
description: 以 Claude Code 的身份提交代码。当用户说"提交代码"、"commit"、"以claude身份提交"时触发。
---

# Claude Commit Skill

以 Claude Code 的身份执行 git commit，让 commit 的 author 显示为 Claude Code。

## 执行步骤

1. **检查暂存区**
   - 执行 `git diff --cached --stat` 查看有哪些文件待提交
   - 如果没有暂存文件，提示用户先 `git add`，默认情况下就是add所有未跟踪的文件
   - 如果未跟踪文件中，有些常见的不需要跟踪内容，则添加到.gitignore中，比如.idea、*.imp

2. **生成 commit message**
   - 根据 diff 内容生成规范的 commit message
   - message内容中文为主，且要简洁明了，不超过三句话总结变更内容
   - 格式：`<type>(<scope>): <subject>`

3. **以 Claude 身份提交**
   - 使用环境变量临时覆盖 Git 作者信息：
   ```bash
   GIT_AUTHOR_NAME="Claude Code" \
   GIT_AUTHOR_EMAIL="noreply@anthropic.com" \
   GIT_COMMITTER_NAME="Claude Code" \
   GIT_COMMITTER_EMAIL="noreply@anthropic.com" \
   git commit -m "生成的message"
   
4. **将本地代码提交到remote**
   - git branch 检查当前分支，如果是master分支，则禁止提交
   - 如果不是master分支，则使用git push提交