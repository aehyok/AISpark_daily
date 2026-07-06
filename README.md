# AI Spark 新闻干货分享 · 日报归档

AI Spark 社群每日出刊的「新闻干货分享」归档仓库。自 **2026-05-11 第 1 期**起每日一期，每期结构固定：

- **1–5 条**：社群干货 —— 社群成员当天在 X(Twitter) 上分享的教程、实战经验、深度观点、项目资源，二次精选 5 条
- **6–10 条**：AI 新闻 —— 从 [AI HOT](https://aihot.virxact.com) 今日精选中挑出最值得看的 5 条
- **固定尾部**：社群 AI 知识库与 VIP 社群介绍

每条内容为「一句话总结 + 一行链接」，方便直接转发到群聊。

## 目录结构

```
├── README.md                        # 本文件
├── INDEX.md                         # 往期总目录（期号、日期、出刊人、文件链接 + 出刊人统计）
├── 2026-05-11-第1期-AI少年.md        # 每期正文，逐字归档
├── 2026-05-12-第2期-阿蔺.md
├── ...
├── .claude/skills/                  # Claude Code skills（出刊自动化）
│   ├── aispark-daily/               # 主 skill：拼整期日报 + 自动存档 + 更新 INDEX
│   ├── aispark-daily-grok/          # 桥接 skill：调本机 grok CLI 从 X 抓社群帖子
│   ├── ai-top5 / aihot/             # AI HOT 新闻拉取与精选
│   └── ...
└── .grok/skills/
    └── aispark-daily-grok/          # grok 侧 skill：X 搜索 + 8 条精选（真正的抓取逻辑）
```

## 文件命名规则

```
<日期 YYYY-MM-DD>-第<N>期-<出刊人>.md
```

日期为北京时区，期号与 `INDEX.md` 往期表一一对应，文件名结尾为当期出刊人。

## 出刊流程（自动化）

在 Claude Code 中运行 `/aispark-daily` 即可出刊，流程为：

1. **抓社群素材**：通过 `aispark-daily-grok` 调用本机 grok CLI，用 X 搜索抓取社群成员近 24 小时的帖子，精选出至多 8 条带回
2. **二次精选 5 条**：优先实用教程、实战经验、深度观点、项目资源；同一作者最多一条，并与前 1–2 期查重
3. **拉取 AI 新闻 5 条**：从 AI HOT 今日精选中按重要性挑选，同样跨期查重
4. **拼版**：北京日期 + 期号（以 INDEX 最新一期 +1 为准，日期锚点交叉验证）+ 固定尾部（`footer.md` 逐字复用）
5. **归档**：正文写入根目录归档文件，并同步更新 `INDEX.md` 的往期表与出刊人统计

也支持「直通存档」：把在别处排好的完整正文贴给 Claude 说"存档"，即逐字落盘并更新 INDEX。

## 查阅往期

见 [INDEX.md](./INDEX.md)，按期号倒序排列（最新在前），并附各出刊人的期数统计。

## 相关链接

- 📚 社群 AI 知识库：https://lcnniolukk80.feishu.cn/wiki/space/7644091204958866380
- ⭐ 知识库 GitHub 开源地址：https://github.com/aisparkedu/knowledge-base
- 📰 AI HOT 资讯站：https://aihot.virxact.com
