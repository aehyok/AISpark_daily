#!/usr/bin/env bash
# AI Spark 日报自动提交 + 推送
# 作为 .claude/settings.json 里的 Stop hook 运行：每轮对话结束时触发，
# 仅当工作区里出现/改动了「日报文件」(YYYY-MM-DD-第N期-*.md) 时才提交并 push。
# 普通对话（没生成日报）会直接静默退出，不动 git。
#
# stdin 会收到 Stop 事件的 JSON，这里用不到、忽略即可。
# 设 DAILY_HOOK_DRYRUN=1 可只打印将要执行的动作，不真正 commit/push（用于测试）。

# 不用 set -e：hook 里任何中途失败都不该阻断会话，统一手动收口、永远 exit 0。
emit() { printf '{"systemMessage": %s}\n' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/^/"/; s/$/"/')"; }

# 定位仓库根目录：优先用 Claude Code 注入的 $CLAUDE_PROJECT_DIR，否则按脚本位置回推。
ROOT="${CLAUDE_PROJECT_DIR:-}"
[ -z "$ROOT" ] && ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT" 2>/dev/null || exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# 本期日报文件的 pathspec（仓库根目录下的 *-第N期-*.md）
SPEC=':(glob)*-第*期-*.md'

# 收集当前工作区里有变动（新增/修改）的日报文件
# core.quotepath=false：避免把中文文件名转义成 \347 之类；cut -c4- 去掉 "XY " 状态前缀取路径
changed="$(git -c core.quotepath=false status --porcelain -- "$SPEC" 2>/dev/null | cut -c4-)"
[ -z "$changed" ] && exit 0   # 没有日报变动 → 这一轮不是出刊，静默退出

# 取最新一期（按文件名排序，期号大的在后）用于 commit message
newest="$(printf '%s\n' "$changed" | sort | tail -1)"
base="$(basename "$newest")"
date="$(printf '%s' "$base" | sed -n 's/^\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)-.*/\1/p')"
issue="$(printf '%s' "$base" | sed -n 's/.*-\(第[0-9]*期\)-.*/\1/p')"
count="$(printf '%s\n' "$changed" | grep -c .)"

if [ "$count" -gt 1 ]; then
  msg="feat: 日报更新 ${issue}等 ${count} 期 (${date})"
else
  msg="feat: ${issue}日报 (${date})"
fi

if [ "${DAILY_HOOK_DRYRUN:-}" = "1" ]; then
  printf 'DRYRUN changed:\n%s\n' "$changed"
  printf 'DRYRUN would: git add -- "%s" INDEX.md && git commit -m "%s" && git push origin HEAD\n' "$SPEC" "$msg"
  exit 0
fi

# 只暂存日报文件 + INDEX.md，不碰其他改动（.DS_Store / SKILL.md 等）
git add -- "$SPEC" INDEX.md 2>/dev/null

# 没有实际可提交内容就退出（例如改动已被提交过）
git diff --cached --quiet && exit 0

if ! git commit -m "$msg" >/dev/null 2>&1; then
  emit "日报 hook：commit 失败，未推送"
  exit 0
fi

if git push origin HEAD >/dev/null 2>&1; then
  emit "日报 hook：已提交并推送 ${msg}"
else
  emit "日报 hook：已本地提交「${msg}」，但 push 失败（检查网络/登录），可稍后手动 git push"
fi
exit 0
