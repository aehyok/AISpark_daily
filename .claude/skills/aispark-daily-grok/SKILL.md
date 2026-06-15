---
name: aispark-daily-grok
description: >
  通过本机 grok CLI（headless）调用 grok 侧的 /aispark-daily-grok skill，自动抓取 AISpark 社群 11 位成员近 24 小时的 X(Twitter) 帖子、二次精选出 8 条最有价值的分享，并把 grok 返回的 8 行结果原样带回当前 Claude 聊天窗口。
  本 skill 只是一个「Claude → grok」的桥接器：真正的抓取与精选逻辑在 grok 那边（grok 有 X 搜索工具，Claude 没有）。当用户说"跑一下社群日报 / 本社群 24 小时 / 本社群分享 / 社区精选 8 条 / 用 grok 抓社群 / 调 grok 出社群精选 / aispark-daily-grok / community 24h highlights / 自动抓社群帖子"等、想要**自动从 X 抓取**社群近 24h 精选时使用。
  注意区分：`[[aispark-daily]]` 是用「用户手工贴的素材 + AI HOT 新闻」拼整期日报；本 skill 是「调 grok 自动从 X 抓社群帖子」出 8 行裸列表，不需要用户提供素材、不接 AI HOT、不带固定尾部。用户明确说"用 grok / 自动抓 / 24 小时"就用本 skill。
---

# aispark-daily-grok（Claude → grok 桥接）

这个 skill 不自己抓数据。它在本机用 **grok CLI 的 headless 单轮模式** 触发 grok 侧的 `/aispark-daily-grok` skill，让 grok 用它的 X 搜索工具完成抓取+精选，然后把 grok 打到 stdout 的最终结果**原样**贴回当前聊天窗口。

为什么要走 grok：抓 X 帖子需要 `x_keyword_search` 这类工具，这工具在 grok 那边、Claude 这边没有。所以让 grok 干活，Claude 只负责调起来、把结果带回来。

## 执行步骤

被触发后，**立即**执行下面这条命令（不要先解释、不要先问，除非用户明确说要改参数）：

```bash
# 1. 定位含 .grok/skills/aispark-daily-grok 的项目根（grok 要在这个目录下才能发现该 skill）
ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -d "$ROOT/.grok/skills/aispark-daily-grok" ]; do
  ROOT="$(dirname "$ROOT")"
done
[ -d "$ROOT/.grok/skills/aispark-daily-grok" ] || ROOT="/Users/aehyok/Desktop/daily/aispark/daily"

# 2. 算时间窗口。X 的 since: 是按自然日的，傍晚/夜里跑会捞进约 47h 的帖子，
#    所以额外算一个「24h 前」对应的最小推文 ID（snowflake），让 grok 按 ID 硬过滤到严格近 24h。
TODAY="$(TZ='Asia/Shanghai' date +%Y-%m-%d)"
NOW_BJ="$(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M')"
EPOCH=1288834974657                       # Twitter snowflake 起点(ms)
NOW_MS=$(( $(date +%s) * 1000 ))          # 当前 Unix 毫秒（snowflake 与时区无关）
CUTOFF_MS=$(( NOW_MS - 86400000 ))        # 24 小时前
MIN_ID=$(( (CUTOFF_MS - EPOCH) << 22 ))   # 早于此 ID 的帖子即超过 24h，丢弃

# 3. headless 调起 grok 的 /aispark-daily-grok。
#    --always-approve: headless 下自动放行工具调用（X 搜索），否则会卡在审批
#    --output-format plain: 只把最终回答打到 stdout
grok --cwd "$ROOT" \
     --always-approve \
     --output-format plain \
     -p "/aispark-daily-grok

现在时间: ${NOW_BJ} (Asia/Shanghai)。
取近 24 小时的帖子：用 since:${TODAY} 之类多捞当网，但**必须按推文 ID 硬过滤**——只保留 status ID >= ${MIN_ID} 的帖子（早于这个 ID 即超过 24 小时，一律丢弃，不要拿来凑数）。
从过滤后的帖子里选最多 8 条；不足 8 条就输出实际条数，宁缺毋滥。
只输出最终列表（最多 8 行），前后不要任何多余文字。"
```

- 这条会跑一段时间（grok 要对 11 个账号各发一次 X 搜索再精选），**给足超时**（建议 600000ms / 10 分钟）。
- `MIN_ID` 是关键：grok 侧 skill 会拿它把 `since:` 多捞回来的「超 24h」帖子剔掉，保证严格近 24 小时。
- 正常情况下 stdout 就是干净的列表（最多 8 行，社群安静时可能不足 8 条，这是正常的）。

## 把结果带回聊天窗口

- grok 跑完后，把它 **stdout 的内容原样**贴到当前聊天窗口——这就是用户要的「数据返回到当前聊天」。
- 不要改写、不要重新编号、不要补充总结、不要加 markdown 包裹（除非用户额外要求）。grok 给几行就贴几行（最多 8 行；严格近 24h 内若不足 8 条就是几条贴几条，**不要**自己补足或回填超时帖子）。
- 典型输出形如：

  ```
  1、本社群 昵称分享：精炼标题 https://x.com/handle/status/ID
  2、本社群 昵称分享：精炼标题 https://x.com/handle/status/ID
  …
  N、本社群 昵称分享：精炼标题 https://x.com/handle/status/ID
  ```

## 出错时怎么办（如实报告，别脑补内容）

- **grok 命令找不到**（`command not found: grok`）：告诉用户本机没装/没在 PATH 里的 grok CLI（应在 `~/.grok/bin/grok`），让用户确认安装。
- **找不到 grok 侧 skill**（grok 报没有 aispark-daily-grok / 没产出列表）：确认 `<ROOT>/.grok/skills/aispark-daily-grok/SKILL.md` 存在；不存在就提示用户先放好那个 grok skill。
- **X 搜索工具不可用 / 401 / 限流**：把 grok 的 stderr 关键报错转述给用户，说明是 grok 侧 X 工具的问题，不是本 skill 能修的。
- **输出为空 / 完全不是列表格式**：把 grok 实际打出来的东西原样给用户看，并说明"grok 这次没按预期返回列表"，可让用户重试一次。（注意：严格近 24h 内不足 8 条属正常，不算异常。）
- 绝不要因为 grok 失败就**自己用训练数据编造**社群帖子或链接——本 skill 的数据只能来自 grok 实抓。

## 不要做

- 不要用 Claude 自己去抓 X（没有那个工具，会编造）。数据一律来自 grok。
- 不要把 grok 的 8 行再套进 `[[aispark-daily]]` 的整期模板（那是另一个 skill 的事）；本 skill 只负责把 grok 的裸列表带回来。
- 不要在正文里暴露命令参数、cwd、超时、审批等基础设施细节——那些是给你执行用的，不是给用户看的。
- 用户没让改就别改 grok 的参数（模型、effort、账号清单等都在 grok 侧 skill 里管）。
