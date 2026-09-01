# AI Spark 新闻干货分享 · 日报归档

AI Spark 社群「新闻干货分享」的逐日归档。自 **2026-05-11 第 1 期**起每日一期，最新一期是 **[第 114 期（2026-09-01）](./2026-09-01-第114期-AI少年.md)**。

每期 10 条，方便直接转发到群聊（一句话总结 + 一行链接）：

| 序号 | 板块 | 来源 |
| ---: | --- | --- |
| 1–5 | 社群干货 | 成员当天在 X 上的教程、实战、观点、项目，二次精选 5 条 |
| 6–10 | AI 新闻 | 从 [AI HOT](https://aihot.virxact.com) 今日精选中挑 5 条 |
| 尾部 | 固定介绍 | 社群 AI 知识库与 VIP 社群说明（`footer.md` 逐字复用） |

## 查阅往期

打开 [INDEX.md](./INDEX.md)：按期号倒序（最新在前），含出刊人和各出刊人期数统计。

## 文件命名

```
<日期 YYYY-MM-DD>-第<N>期-<出刊人>.md
```

日期用北京时区。期号与 `INDEX.md` 一一对应，文件名末尾是当期出刊人。

## 出刊流程

在 Claude Code 里跑 `/aispark-daily`：

1. **抓社群素材**：`aispark-daily-grok` 调本机 `grok` CLI，用 X 搜索拉近 24 小时社群帖，最多带回 8 条
2. **二次精选 5 条**：优先教程 / 实战 / 深度观点 / 项目；同一作者最多一条，并与前 1–2 期查重
3. **AI 新闻 5 条**：从 AI HOT 今日精选按重要性挑，同样跨期查重
4. **拼版**：北京日期 + 期号（`INDEX` 最新一期 + 1，日期交叉校验）+ 固定尾部
5. **归档**：正文写入仓库根目录，并更新 `INDEX.md` 往期表和出刊人统计

也可以「直通存档」：把别处排好的完整正文贴给 Claude，说「存档」，即逐字落盘并更新 INDEX。

## 目录

```
├── README.md
├── INDEX.md                         # 往期总目录
├── 2026-05-11-第1期-AI少年.md        # 每期正文
├── …
├── .claude/skills/
│   ├── aispark-daily/               # 主 skill：拼期、存档、更新 INDEX
│   ├── aispark-daily-grok/          # 桥接：调 grok CLI 抓 X 社群帖
│   ├── ai-top5 / aihot/             # AI HOT 新闻拉取与精选
│   └── bestblogs-*                  # BestBlogs 相关 skill（非日报主流程）
└── .grok/skills/
    └── aispark-daily-grok/          # grok 侧：X 搜索 + 精选
```

## 相关链接

- 社群 AI 知识库：https://lcnniolukk80.feishu.cn/wiki/space/7644091204958866380
- 知识库开源：https://github.com/aisparkedu/knowledge-base
- AI HOT：https://aihot.virxact.com
