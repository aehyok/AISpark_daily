---
name: aispark-daily-grok
description: >
  Daily curated highlights from the AISpark community on X. Fetches recent posts from the 11 key members (aehyok, MinLiBuilds, Lonely__MH, cheery9998, etc.), excludes replies/comments, **hard-filters to strictly the last 24 hours by tweet ID** (X's since: is calendar-day granular and over-captures, so we drop anything older than 24h), internally classifies types (单纯的post / 文章 / 引用), selects up to 8 valuable shares (tools, workflows, resources, insights, tutorials), and outputs up to 8 lines in the strict format: 序号、本社群 昵称分享：精炼标题 链接.
  Slash command: /aispark-daily-grok. Triggers on: aispark-daily-grok, 社群日报, AISpark daily, 本社群24小时, 本社群分享, 社区精选, 24h posts, 跑一下社群, community highlights, AISpark 精选.
---

# aispark-daily-grok

When this skill is invoked (by `/aispark-daily-grok` or matching intent), **immediately** execute the workflow below and return **ONLY** the final list (up to 8 lines). Do not add any extra text, explanations, or markdown unless the user explicitly asks for more details.

## User Mapping (exact nicknames)
Use these exact nicknames in the output:

- MinLiBuilds → 实践哥
- Lonely__MH → L总
- cheery9998 → cheery老师
- xiangxiang103 → 雨哥老师
- legacyvps → 小墨老师
- alin_zone → 阿蔺老师
- LawrenceW_Zen → 劳伦斯老师
- Liu_zhongxisn → Drunk老师
- ModengSir → 优秀学员勇哥
- MainCaseZ → 优秀学员张总
- jinglian → 前端哥老师
- aehyok → AI少年老师


## Step-by-step Workflow

1. **Determine the time window (and the 24h cutoff tweet ID)**
   - X 的 `since:` operator 是**按自然日**的，不是滚动 24 小时——傍晚/夜里跑时，`since:昨天` 实际会捞进约 47 小时的帖子。所以我们用 `since:` 多捞当网，再**按推文 ID 硬过滤**到严格的近 24 小时。
   - 取一个「24 小时前」对应的**最小推文 ID** `MIN_ID`，凡是 `status ID < MIN_ID` 的帖子都超过 24 小时，**一律丢弃**。
     - **首选**：宿主（Claude 桥接器）会在 prompt 里给出「现在时间」和一个具体的 `MIN_ID`。给了就直接用。
     - **兜底**（有人不经桥接、直接在 grok 里跑时自己算）：用 Twitter snowflake 公式。
       - snowflake 起点 `EPOCH = 1288834974657`（ms）。
       - 24 小时前的毫秒数 `m = 现在的 Unix 毫秒 - 86400000`。
       - `MIN_ID = (m - EPOCH) << 22`（即 `(m - 1288834974657) * 4194304`）。
       - 反过来，任一帖子的发帖时间 `ms = (ID >> 22) + EPOCH`，可用来核对。
   - `since:` 仍用昨天的日期（`since:YYYY-MM-DD`）即可，宁可多捞，过滤交给 `MIN_ID`。

2. **Fetch posts for all members**
   - For **each** of the 11 handles above, call the tool:
     ```
     x_keyword_search
     query: from:HANDLE since:YYYY-MM-DD -filter:replies
     limit: 6
     mode: Latest
     ```
   - Replace HANDLE with the actual username (e.g. `from:aehyok`, `from:MinLiBuilds`, etc.).
   - Collect all returned "Main Post" items. Ignore any that are clearly replies (we already filter them).

3. **Process each post and extract data**
   - From the tool result, extract:
     - Post ID (the number after "ID:") — 这个 ID 既用来建链接，也用来做 24h 硬过滤，**务必保留**。
     - Author handle (use the one from the query or the @username in "Author:")
     - Content (the full text after "Content:")
     - Engagement numbers (Likes, Views, etc.)
     - Whether a "Quoted Post:" section exists
     - Any Media or links mentioned
   - Construct the full URL: `https://x.com/{handle}/status/{ID}` (use lowercase handle).
   - Classify type **internally** (do not output the type in the final list):
     - If the result contains a "Quoted Post:" block → "引用"
     - Else if Content is long (> ~350 chars), contains numbered lists, GitHub links, detailed steps, "教程"/"指南"/"资源"/"方法论", or X article links (`/i/article/`) → "文章"
     - Otherwise → "单纯的post"

4. **Hard-filter to strictly the last 24 hours**
   - 逐条比较：**只保留 `status ID >= MIN_ID` 的帖子**；`ID < MIN_ID` 的（超过 24 小时）直接剔除，不进入候选池。
   - 这一步是这个 skill 的硬约束：**绝不**为了凑满 8 条而把超过 24 小时的帖子放回来。宁可少，也不要把过期的塞进来。
   - 过滤后若候选寥寥（比如只剩三五条），那就是这 24 小时社群确实发得少——如实输出实际条数。

5. **Curate up to 8 items**
   - 只在**第 4 步过滤后**的帖子里挑。
   - Filter out very low-value posts (e.g. < 3 likes + < 200 views and purely casual one-liners).
   - Rank and select the best (最多 8 条) using these priorities (in order):
     1. High engagement (Likes + Views + Bookmarks).
     2. Practical value to the community: real tool usage, workflows, coding tips, resource lists, tutorials, deep insights, "保姆级" guides, indie hacking / AI building experiences.
     3. Diversity: spread across different members when possible. Avoid picking multiple quotes of the exact same post unless the commentary adds unique value.
     4. Presence of media, external links (GitHub, articles, tools), or structured content.
   - **数量规则**：目标最多 8 条；若 24h 内达标的帖子不足 8 条，就输出实际条数（哪怕只有 4 条），**不要**用超过 24 小时的帖子补足。

6. **Create the title / summary for each selected post**
   - Turn the post Content into a short, attractive, refined Chinese title or one-sentence summary.
   - It should read naturally after "分享：".
   - Keep it concise (ideally under 25-30 characters when possible), capture the core value or hook.
   - Examples of good style:
     - "零基础 Vibe Coding 推荐的 5 个优质开源项目"
     - "用 Helio 搭建自媒体 AI 工作流团队的实战经验"
     - "DeepSeek 对接 Codex 的正确打开方式 + 视频演示"

7. **Map handle to nickname and format output**
   - Use the exact mapping table above.
   - Output 连续编号、最多 8 行，nothing before or after（实际选了 N 条就输出 N 行，编号 1…N）：
     ```
     1、本社群 昵称分享：精炼标题 https://x.com/handle/status/ID
     2、本社群 昵称分享：精炼标题 https://x.com/handle/status/ID
     ...
     N、本社群 昵称分享：精炼标题 https://x.com/handle/status/ID
     ```

## Important Rules
- **严格近 24 小时**：每条入选帖子必须 `ID >= MIN_ID`。这是最重要的约束——`since:` 捞回来的超 24h 帖子必须被第 4 步剔除。
- Never include replies or comments.
- Never output the internal post type in the final list (user only wants the clean formatted list).
- Be consistent with the exact output format the user specified.
- Use only the provided X search tool for recency and accuracy.
- If a post is a quote, you may still select it if the author's commentary adds strong value.
- Prioritize quality over quantity — the selected items should feel like the "best of" the community's last-24h activity；条数少是可以接受的，过期混入不可以。

Execute the full workflow as soon as the skill is triggered and return only the list (up to 8 lines).
