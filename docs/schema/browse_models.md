# 浏览列表模型 Schema (已锁定)

## TagItem — 标签列表项
- 接口: `GET /api/tags/`
- 响应: `List<TagItem>`

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 标签ID |
| name | String | 标签名 |
| count | int | 关联作品数量 |
| i18n | I18n? | 多语言翻译，复用现有 I18n |

## CircleItem — 社团列表项
- 接口: `GET /api/circles/`
- 响应: `List<CircleItem>`

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 社团ID |
| name | String | 社团名 |
| count | int | 作品数量 |
| i18n | I18n? | 多语言（当前API返回空{}，映射为null） |

## VoiceActor — 声优列表项
- 接口: `GET /api/vas/`
- 响应: `List<VoiceActor>`

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | UUID格式 |
| name | String | 声优名 |
| count | int | 出演作品数量 |
| i18n | I18n? | 多语言（当前API返回空{}，映射为null） |
