#!/usr/bin/env bash
# AI HOT Agent Skill 国内直链安装脚本
# 用法（默认装到 Claude Code skills 目录）：
#   curl -fsSL https://aihot.virxact.com/aihot-skill/install.sh | bash
#
# 装到其他 Agent 平台：
#   SKILL_DIR=$HOME/.codex/skills/aihot   bash <(curl -fsSL https://aihot.virxact.com/aihot-skill/install.sh)
#   SKILL_DIR=$HOME/.gemini/skills/aihot  bash <(curl -fsSL https://aihot.virxact.com/aihot-skill/install.sh)

set -e

DEFAULT_DIR="$HOME/.claude/skills/aihot"
SKILL_DIR="${SKILL_DIR:-$DEFAULT_DIR}"
SITE="https://aihot.virxact.com"

echo ""
echo "Installing AI HOT Agent Skill"
echo "  → $SKILL_DIR"
echo ""

mkdir -p "$SKILL_DIR"
curl -fsSL "$SITE/aihot-skill/SKILL.md"   -o "$SKILL_DIR/SKILL.md"
curl -fsSL "$SITE/aihot-skill/README.md"  -o "$SKILL_DIR/README.md"

echo ""
echo "✓ Done."
echo ""
echo "Next: restart your Agent or start a new conversation, then try:"
echo "  - 今天 AI 圈有什么新东西？"
echo "  - 看一下 5 月 6 号的 AI 日报"
echo "  - 最近一周的 AI 论文"
echo ""
echo "Other Agent platforms (re-run with SKILL_DIR set):"
echo "  Codex CLI:    SKILL_DIR=\$HOME/.codex/skills/aihot   bash <(curl -fsSL $SITE/aihot-skill/install.sh)"
echo "  Gemini CLI:   SKILL_DIR=\$HOME/.gemini/skills/aihot  bash <(curl -fsSL $SITE/aihot-skill/install.sh)"
echo ""
