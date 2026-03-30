# API 接口契约 (已锁定)

## 新增接口

| 接口 | 方法 | 认证 | 响应模型 |
|------|------|------|----------|
| /api/tags/ | GET | 否 | List&lt;TagItem&gt; |
| /api/circles/ | GET | 否 | List&lt;CircleItem&gt; |
| /api/vas/ | GET | 否 | List&lt;VoiceActor&gt; |
| /api/workInfo/{id} | GET | 否 | WorkInfo |

## 参数升级

| 接口 | 变更 |
|------|------|
| GET /api/tracks/{id} | v=1 → v=2 |
| GET /api/search/{keyword} | 新增 includeTranslationWorks (already implemented in code) |
| GET /api/playlist/get-playlists | 新增 filterBy, pageSize |

## 搜索语法扩展
- `$tag:标签名$` — 按标签筛选
- `$circle:社团名$` — 按社团筛选
- `$va:声优名$` — 按声优筛选
