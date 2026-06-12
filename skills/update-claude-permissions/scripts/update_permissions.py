#!/usr/bin/env python3
"""
Update permissions in a Claude settings file from a template.
Usage:
    python3 update_permissions.py --target <settings.json> --template <template.json>
"""
import json
import sys
import os
import argparse
from copy import deepcopy


def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write('\n')


def diff_summary(old_perms, new_perms):
    """Generate a human-readable summary of what changed."""
    lines = []
    for key in ['allow', 'ask', 'deny']:
        old_set = set(old_perms.get(key, []))
        new_set = set(new_perms.get(key, []))
        added = new_set - old_set
        removed = old_set - new_set
        if added:
            lines.append(f"  + {key} 新增 {len(added)} 条")
        if removed:
            lines.append(f"  - {key} 移除 {len(removed)} 条")
    if not lines:
        lines.append("  (无变化)")
    return lines


def main():
    parser = argparse.ArgumentParser(description='Update Claude settings permissions')
    parser.add_argument('--target', required=True, help='目标 settings 文件路径')
    parser.add_argument('--template', required=True, help='模板 JSON 文件路径')
    args = parser.parse_args()

    # 检查文件是否存在
    if not os.path.exists(args.target):
        print(f"❌ 目标文件不存在: {args.target}")
        sys.exit(1)
    if not os.path.exists(args.template):
        print(f"❌ 模板文件不存在: {args.template}")
        sys.exit(1)

    # 读取
    target_data = load_json(args.target)
    template_data = load_json(args.template)
    old_permissions = deepcopy(target_data.get('permissions', {}))

    if 'permissions' not in template_data:
        print("❌ 模板文件中未找到 'permissions' 字段")
        sys.exit(1)

    # 覆盖 permissions
    target_data['permissions'] = deepcopy(template_data['permissions'])

    # 写入
    save_json(args.target, target_data)

    # 输出 diff
    new_permissions = target_data['permissions']
    print(f"✅ 已更新: {args.target}")
    for line in diff_summary(old_permissions, new_permissions):
        print(line)

    # 统计
    allow_count = len(new_permissions.get('allow', []))
    ask_count = len(new_permissions.get('ask', []))
    deny_count = len(new_permissions.get('deny', []))
    print(f"\n当前权限统计:")
    print(f"  allow: {allow_count} 条")
    print(f"  ask:   {ask_count} 条")
    print(f"  deny:  {deny_count} 条")


if __name__ == '__main__':
    main()
