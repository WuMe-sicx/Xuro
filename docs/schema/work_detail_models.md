# 作品详情模型 Schema (已锁定)

## WorkInfo — 作品完整详情（详情页专用）
- 接口: `GET /api/workInfo/{id}`
- 响应: 单个 `WorkInfo` 对象
- 设计: 独立于 Work 模型，避免列表页null污染

| 字段 | 类型 | JSON Key | 说明 |
|------|------|----------|------|
| id | int | id | 作品ID |
| title | String | title | 标题 |
| circleId | int | circle_id | 社团ID |
| name | String | name | 社团名 |
| nsfw | bool | nsfw | 是否NSFW |
| release | String | release | 发售日期 |
| dlCount | int | dl_count | 销量 |
| price | int | price | 价格(JPY) |
| reviewCount | int | review_count | 评论数 |
| rateCount | int | rate_count | 评分人数 |
| rateAverage2dp | double | rate_average_2dp | 平均评分 |
| hasSubtitle | bool | has_subtitle | 有无字幕 |
| createDate | String | create_date | 收录日期 |
| duration | int | duration | 总时长(秒) |
| ageCategoryString | String | age_category_string | 年龄分类 |
| sourceType | String | source_type | 来源类型 |
| sourceId | String | source_id | 来源ID |
| sourceUrl | String | source_url | DLsite链接 |
| samCoverUrl | String? | samCoverUrl | 小封面URL |
| thumbnailCoverUrl | String? | thumbnailCoverUrl | 缩略图URL |
| mainCoverUrl | String? | mainCoverUrl | 主封面URL |
| rateCountDetail | List&lt;RateDetail&gt; | rate_count_detail | 评分分布 |
| rank | List&lt;RankInfo&gt; | rank | 排名信息 |
| vas | List&lt;WorkVA&gt; | vas | 声优列表 |
| tags | List&lt;WorkTag&gt; | tags | 标签(含投票) |
| circle | Circle | circle | 社团详情(复用) |
| languageEditions | List&lt;LanguageEdition&gt;? | language_editions | 语言版本 |
| translationInfo | TranslationInfo? | translation_info | 翻译信息 |
| originalWorkno | String? | original_workno | 原始作品号 |
| otherLanguageEditionsInDb | List&lt;OtherLanguageEditionsInDb&gt;? | other_language_editions_in_db | DB中其他语言版 |
| workAttributes | String? | work_attributes | 作品属性 |
| userRating | dynamic | userRating | 用户评分 |

## RateDetail — 评分分布
| 字段 | 类型 | JSON Key | 说明 |
|------|------|----------|------|
| reviewPoint | int | review_point | 星数1-5 |
| count | int | count | 数量 |
| ratio | double | ratio | 占比(0-100) |

## RankInfo — 排名信息
| 字段 | 类型 | JSON Key | 说明 |
|------|------|----------|------|
| term | String | term | "day"/"week"/"month" |
| category | String | category | "all"/"voice" |
| rank | int | rank | 排名 |
| rankDate | String | rank_date | 排名日期 |

## WorkVA — 作品声优
| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | UUID |
| name | String | 声优名 |

## WorkTag — 标签(含投票，独立模型)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 标签ID |
| name | String | 标签名 |
| i18n | I18n? | 多语言 |
| upvote | int | 赞同票 |
| downvote | int | 反对票 |
| voteRank | int | 投票排名 |
| voteStatus | int? | 用户投票状态(nullable for guest) |
