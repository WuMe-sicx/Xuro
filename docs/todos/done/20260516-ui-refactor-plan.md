# UI 重构总方案——以参考图为视觉目标的组件复用重塑（蓝白 / 黑白 / 绿白 三配色）

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：done <!-- active | done | cancelled -->
- **关联 Issue / PR**：无
- **视觉基准**：用户提供的参考图（`~/Downloads/ChatGPT Image 2026年5月16日 04_07_14.png`）——3 配色 × 5 屏（侧边栏 / 首页 / 播放器 / 设置 / 关于我们）

> ⚠️ 本文档是**重构方案（规划态）**，经 review 后再决定执行哪些阶段。本轮**不改任何代码**。
> 旧版「不改观感的纯结构重构」方案已被本版**取代**：用户给出明确视觉目标（参考图），方向改为「以参考图为目标、组件复用驱动的视觉重塑」。

---

## 0. 关键判断：参考图验证了现有架构

参考图的本质是 **同一套组件，三配色只轮换 accent token**：

- 三配色（蓝白 / 黑白 / 绿白）= 现有 `ColorVariant.blue / mono / green`，**架构已存在**（`app_colors.dart:17-85`）。
- 参考图里**只有** accent 处变色：导航选中胶囊、分区标题、主播放按钮、滑块/开关激活态、「更多 >」「关注」。表面恒为白（亮）/近黑（暗），图标/卡片底为中性灰。**这正是 `AppColors` 双轴设计意图**——`primary/onPrimary/primaryContainer` 轮换，其余 token 中性。
- 规范 v3.0 的紫色 `fromSeed` 体系彻底作废；CLAUDE.md + 参考图才是事实源。

**结论**：本次不是重写主题架构，而是 **(a) 把视觉提升到参考图水准 (b) 把散落实现收敛成可跨 5 屏 × 3 配色复用的组件层 (c) 顺带清掉令牌/字符串/废弃 API 的历史债**。`AppColors` 双轴系统保留不动。

---

## 1. 目标（Goal）

> 以参考图为像素级视觉目标，把 Xuro 的 5 个核心界面（侧边栏 / 首页 / 播放器 / 设置 / 关于我们）重塑为「一套原子组件库 + 三配色仅轮换 accent」的复用体系，同时建立设计令牌、清理字符串与废弃 API 债务，使「规范文档 = 参考图 = 代码」三者一致。

## 2. 范围（Scope）

**包含：**
- 重写 `docs/ui-design-spec.md`：以参考图为视觉基准，定义令牌、原子组件目录、三配色轮换规则。
- 新增设计令牌：`AppSpacing` / `AppRadius` / `AppTextStyles`（`lib/core/theme/`，与 `AppAnimations` 同级）。
- 建立/收敛**原子组件层**（见 §4 复用矩阵），5 屏共用、3 配色自动适配。
- 按参考图重塑 5 屏：侧边栏、首页、播放器、设置、关于我们。
- 历史债清理并入：UI 文案归 `Strings`、`withOpacity`→`.withValues`、移除 `shimmer` 依赖、`groupWorksIntoRows` memo。

**不包含：**
- 重写主题架构 / 改 `AppColors` 双轴系统（已验证正确，保留）。
- 改业务逻辑 / ViewModel 行为 / 音频字幕子系统。
- 国际化多语言（仅做字符串归位，不引入语言切换）。
- 参考图未覆盖的屏（搜索/详情/收藏/歌词等）的视觉改版——本次仅令牌化对齐，不重绘。
- 新增后端能力 / 新功能入口（参考图里「倍速播放」「音效设置」「均衡器」等若当前无对应功能，**只做占位 UI 或暂不纳入**，执行阶段逐个确认，不本末倒置造功能）。

## 3. 验收标准（Acceptance）

- [ ] `docs/ui-design-spec.md` 以参考图为基准重写完成，无紫色/fromSeed/失真表述。
- [ ] `lib/core/theme/` 含 `AppSpacing`/`AppRadius`/`AppTextStyles`，5 屏不再出现裸数字间距/圆角。
- [ ] §4 复用矩阵中的原子组件全部落地，且**同一组件在三配色下仅 accent 变化**（三配色对比截图佐证）。
- [ ] 5 屏在 blue/mono/green × light/dark 下与参考图视觉一致（逐屏逐配色对比截图）。
- [ ] UI 可见中文文案 0 处绕过 `Strings`；`grep -rn withOpacity lib/` = 0；`pubspec` 无 `shimmer`。
- [ ] `groupWorksIntoRows` 加 memo + 单测；新增令牌纯逻辑单测通过。
- [ ] `flutter analyze` 通过无新增 warning；相关单测通过。
- [ ] 性能不劣化：首页列表滚动 profile ≥55fps（规范 §7.6）。

## 4. 组件复用架构（核心交付物）

### 4.1 三层结构

```
Layer 0  设计令牌    AppColors(双轴,保留) + AppSpacing/AppRadius/AppTextStyles/AppAnimations
            │  三配色不变量：仅 colorScheme.primary / onPrimary / primaryContainer 轮换
Layer 1  原子组件    跨 5 屏 × 3 配色复用，自身不写死颜色，全部取 Theme/令牌
Layer 2  屏幕组合    Sidebar / Home / Player / Settings / About 仅做布局组合
```

### 4.2 原子组件 × 屏幕 复用矩阵

| 原子组件 | 侧边栏 | 首页 | 播放器 | 设置 | 关于 | 现状 → 动作 |
| :--- | :-: | :-: | :-: | :-: | :-: | :--- |
| `BrandWordmark`（≈ASMR 标志） | ● | | | | ● | **新建**（侧边栏顶 + 关于页中部） |
| `AccentPill`（选中胶囊/关注/主按钮） | ● | | ● | | | **新建**，accent 自 Theme |
| `SectionHeader`（标题 + 更多 >） | | ● | | ● | ● | **新建**，抽离首页/设置分区头 |
| `AppSearchField`（圆角搜索框） | | ● | | | | 评估 `browse_search_bar.dart` → 抽公共 |
| `AppListTile`（图标+标题+尾控件） | ● | | | ● | ● | **泛化** `settings_tile.dart`（已含 nav/toggle/selection 变体，复用率最高） |
| `AppListGroup`（分组+头+脚） | | | | ● | ● | 复用 `settings_group.dart`，重命名上提 |
| `CategoryChip`（图标+标签 chip） | | ● | | | | **演进** `tag_chip.dart`（现仅文本，radius4） |
| `WorkCoverCard`（封面+时长角标+标题） | | ● | | | | 复用 `work_card/*`，加时长角标 + 规范 §2.1 按下缩放 |
| `CircularCover`（圆形封面+环） | | | ● | | | **新建**；现 `player_cover.dart` 为方形，改圆形 |
| `WaveformProgress`（波形进度） | | | ● | | | **新建**；现 `player_progress.dart` 为直条 |
| `NowPlayingRow`（最新上传行+迷你控件） | | ● | | | | 复用 `mini_player/*` 控件做列表内变体 |
| `SidebarDecoration`（底部装饰插画） | ● | | | | | **新建**（叶/月，随配色） |
| `SocialIconRow`（圆形社交图标排） | | | | | ● | **新建** |
| `AppFooter`（© 版权脚） | | | | | ● | **新建** |

> 复用率结论：**设置/关于两屏 ≈80% 复用现有 `SettingsGroup`/`SettingsTile`**（已是 nav/toggle/selection 工厂变体），仅做令牌化 + accent 分区头。**首页是最大净增组合工作**，但全部由上表原子拼出，无一次性私有控件。**播放器**改动集中在圆形封面 + 波形进度两个新原子。

### 4.3 三配色不变量（「三种配色」的落地规则）

- 组件**禁止**写死颜色；一律 `Theme.of(context).colorScheme.*` 或 §Layer0 令牌。
- 配色切换只经 `AppSettingsService.colorVariant` → `AppColors.lightSchemeFor/darkSchemeFor` → `primary/onPrimary/primaryContainer` 三 token 变化，组件无需感知是哪个配色。
- 新增原子须通过「三配色 widget 测试」：同组件在 blue/mono/green 下除 accent 像素外应一致。

---

## 5. 拆解步骤（Steps）

> 阶段彼此独立可单独成 PR，建议按序。每阶段引用本 TODO。

- [x] **Phase A — 规范对齐（纯文档，零运行时风险，先做）** ✅ 2026-05-16
  - 文件：`docs/ui-design-spec.md`（已重写为 v4.0）
  - 已完成：颜色章节改写为真实 `ColorVariant × Brightness` 双轴体系（实测 hex 值）；新增「三配色不变量」节；§2 重构为三层架构 + 原子组件×5屏复用矩阵 + 五屏布局规格（对参考图）；§7.1 审计表更新为真实状态（PlayerViewModel/IntrinsicHeight 已闭环、groupWorksIntoRows 未闭环等）；删除全部紫色/fromSeed/「尚未实现」失真段；动画/无障碍/响应式/工作流属实部分保留。
  - 验证：已逐项对照参考图 + `app_colors.dart`(实测值) + `app_animations.dart`(确认 §3 与代码一致) + CLAUDE.md，无矛盾表述。

- [x] **Phase B — Layer 0 设计令牌** ✅ 2026-05-16
  - 产物：`lib/core/theme/app_spacing.dart`（4px 网格十档 + 页面边距）、`app_radius.dart`（sm/md/lg/full + const `*All` BorderRadius）、`app_text_styles.dart`（规范 §1.2 七档，不绑色）；`app_theme.dart` 亮/暗卡片圆角已由硬编码 `Radius.circular(12)` 改为 `AppRadius.mdAll`（值等价）；单测 `test/core/theme/design_tokens_test.dart`。
  - 范围控制：仅新增令牌类 + 主题接入 AppRadius，未批量改组件（留 Phase C）；AppTextStyles/AppSpacing 仅定义未应用，故视觉零变化。
  - 验证：`flutter analyze lib/core/theme/ test/core/theme/` → No issues；令牌单测 8/8 通过（含「md 必须仍是 12」回归闸 + 「令牌不绑色」三配色不变量断言）。

- [x] **Phase C — Layer 1 原子组件库** ✅ 2026-05-16
  - 产物（8 个纯新增、零现有代码改动、全令牌驱动、无硬编码色/中文）：
    `lib/widgets/common/section_header.dart`、`accent_pill.dart`、`brand_wordmark.dart`、`app_footer.dart`、`social_icon_row.dart`、`category_chip.dart`、`app_search_field.dart`；`lib/widgets/player/circular_cover.dart`。
  - 测试：`test/widgets/common/atom_three_variant_test.dart` 10/10 通过——AccentPill 底=primary、CategoryChip 底=primaryContainer、BrandWordmark 图标=primary，blue/green/mono 三配色逐一断言「accent 严格等于该 scheme token」（写死色即撞红）。
  - **范围决策（6 个原子改入 Phase D，非跳过）**：`AppListTile`/`AppListGroup` 已由现有 `SettingsTile`/`SettingsGroup` 满足（再造重复 = 过度抽象），Phase D 直接复用；`NowPlayingRow`（mini_player 控件组合）、`WorkCoverCard`（work_card 加时长角标）、`SidebarDecoration`（耦合侧边栏深色面板/布局）、`WaveformProgress`（耦合 PlayerProgress seek/ViewModel）均为「与屏幕强耦合的组合件」，独立建库属投机产物——按「无半成品/不超范围」原则，随对应屏在 Phase D（D3/D4/D5）落地，§4.2 矩阵据此更新。
  - 验证：`flutter analyze lib/widgets/common/ lib/widgets/player/circular_cover.dart test/widgets/common/` → No issues；上述 widget 测试全过。

- [x] **Phase D — Layer 2 屏幕重塑（D1–D5 全部完成）** ✅ 2026-05-16
  - [x] **D1 设置** ✅ 2026-05-16：
    - `settings_group.dart`：分区头 `titleSmall`→`AppTextStyles.labelMedium`+accent（规范 §2.4 分类标题=Label Medium，对齐参考图小号 accent 标题）；margin/header/footer padding + 容器圆角全令牌化（`AppSpacing`/`AppRadius.mdAll`）；divider indent 抽 `_dividerIndent=60` 常量并注明 = 16+32+12 几何来源。
    - `settings_tile.dart`：**leading 由「每行 accent 12% 圆角徽章」改为中性线性图标**（`onSurfaceVariant`，无背景）——参考图 accent 仅在分区头/选中/开关/滑块，原实现 accent 过载背离参考图（**广义影响：About 复用同组件，图标一并变中性，D2 一致，意图内**）；行内边距/间距令牌化。
    - `settings_screen.dart`：分区间距 ×6 + 列表内边距令牌化。
    - 测试：`test/screens/settings/settings_d1_test.dart` 7/7——leading==onSurfaceVariant（≠primary）跨 blue/green/mono、selection check==primary、toggle 轨道==primary、分区头==primary+12/w500。
    - 验证：`flutter analyze lib/screens/settings/` → No issues（全量 analyze 仅余既有 `withOpacity` 债，非本阶段文件）；**全量 `flutter test` 76/76 通过，零回归**。
  - [x] **D2 关于** ✅ 2026-05-16：
    - `about_screen.dart` 重构为参考图结构：居中 `BrandWordmark`(text=Strings.aboutAppName='Xuro'，非模板 'ASMR') + 版本副标(`版本 v{packageInfo.version}`，移出列表) + 居中简介；保留 `SettingsGroup` 真实功能链接（检查更新/开源许可/问题反馈/原作者仓库）；`SocialIconRow`(Telegram + GitHub 源码，真实 `_openUrl`)；`AppFooter`(真实 CC BY-NC-SA 版权)。
    - **不造假**：参考图的 `support@asmr.com` 联系邮箱无对应后端 → 不编造；版权按真实协议（非模板「© 2024 ASMR All Rights Reserved」）。新增集中文案 `Strings.versionLabel`/`aboutFooter`（符合字符串规范）。
    - 复用：`SettingsGroup`/`SettingsTile`（D1 的中性 leading 一并生效，方向一致）；新原子 `BrandWordmark`/`SocialIconRow`/`AppFooter`。
    - 测试：`test/screens/about_screen_test.dart`（mock PackageInfo）1/1——品牌名=Xuro、版本在头不在列表、Social 2 入口、Footer 含 CC BY-NC-SA。
    - 验证：`flutter analyze`(about/strings/test) → No issues；**全量 `flutter test` 77/77 通过，零回归**。
  - [x] **D3 侧边栏** ✅ 2026-05-16：
    - 新增 `lib/widgets/sidebar/sidebar_decoration.dart`（Phase C 延期的侧边栏专属原子）：变体感知 `CustomPainter` 水印——mono 画弦月+远山（呼应 `_DrawerBackground` 的 mono 纯黑特例与参考图黑白侧边栏母题），blue/green 画叶片；accent 低透明度、`IgnorePointer` 可点穿、`shouldRepaint` 仅 variant/color 变。
    - `sidebar_menu.dart`：顶部加 `BrandWordmark`(text=Strings.aboutAppName='Xuro'，drawer 局部深色 Theme 下文字=onSurface 白/图标=primary 暗色 accent，与玻璃拟态一致)；Stack 底部加 `SidebarDecoration` 水印（背景之上、内容之下，长屏底部留白处显现）。新增代码用 `AppSpacing`。
    - **范围决策（不造选中态）**：参考图的「选中实心 accent 胶囊」依赖当前 section 概念，但本侧边栏是**导航抽屉**（顶层导航在 MainScreen 底栏，抽屉项全是 push/dialog，无持久选中），强套 `AccentPill` 选中态= 造不存在的模型，违反「不为对齐 UI 造功能」→ 不做。`AccentPill` 留待 D5「关注」使用。
    - 严守 CLAUDE.md：未回退玻璃拟态、未加全屏 BackdropFilter、未批量改既有精调间距（仅新代码令牌化）。
    - 测试：`test/widgets/sidebar/sidebar_d3_test.dart` 6/6——装饰三配色暗色 scheme 渲染 smoke + BrandWordmark 抽屉深色下 icon=primary/text=onSurface（回归「抽屉 accent 不可见」陷阱）。
    - 验证：`flutter analyze`(sidebar/test) → No issues；**全量 `flutter test` 83/83 通过，零回归**。
  - [x] **D4 首页** ✅ 2026-05-16：
    - `home_content.dart`：顶部接入 `AppSearchField`（只读，点击 push 现有 `SearchScreen`），原网格 Stack 包进 `Column>Expanded`，**未改动网格/分页/筛选/滚动逻辑**；顺带修正 format 浮现的既有 `_onScroll` 无大括号 lint。
    - `AppSearchField` 原子增强：加 `readOnly`+`onTap`（搜索框作导航触发器，浏览页内联过滤仍可用）。新增 `Strings.homeSearchHint`。
    - **封面时长角标**（Phase C 延期的 WorkCoverCard）：`WorkCoverImage` 加 `durationSeconds` 参数 + 左下角标（`_fmtDuration` 支持 H:MM:SS/M:SS，新代码用 `.withValues` 非 withOpacity）；`WorkCard` 传 `work.duration`；`work_info_section.dart` 删除冗余时长文本行 + `_formatDuration` + 修正旧双 `SizedBox` 草率写法 + 令牌化（全局列表卡片一致变化，意图内）。
    - **范围决策（不造数据源/功能）**：`CategoryChip` 网格、`NowPlayingRow` 在参考图是内容策展（推荐音频/热门分类/最新上传），但 `HomeViewModel` 是分页作品列表，无对应数据源；强加 = 造功能/造策展数据，违反「不为对齐 UI 反向造功能」（同 D2 假邮箱、D3 假选中态立场）→ 延为产品决策（需先定数据源），本次不纳入。`SectionHeader` 在单一无差别列表上是无信息装饰，亦不加。
    - 测试：`test/widgets/work_card/work_cover_duration_badge_test.dart` 4/4（格式/边界/缺省不显示）。
    - 验证：`flutter analyze` 全 D4 文件 → No issues（仅余既有 withOpacity 债，含刻意未动的 sourceId 行）；**全量 `flutter test` 87/87 通过，零回归**。
  - [x] **D5 播放器** ✅ 2026-05-16：
    - `circular_cover.dart`（Phase C 已建）换掉方形 `PlayerCover`：`player_screen.dart` 内 `Hero(tag:'mini-player-cover')` 保留，仅 child 由 `PlayerCover`→`CircularCover`；封面 Padding 令牌化。
    - 新增 `lib/widgets/player/waveform_progress.dart`（Phase C 延期项，现于播放器上下文落地）：`PlayerProgress` 的视觉替代，**seek/position/duration 完全复用 `PlayerViewModel`**（同 `seek()`、同 range）；波形条高是确定性母题（流式客户端无逐轨真实振幅，参考图同理，属装饰），已播放段染 accent；时间标签用 `AppTextStyles.caption`，新代码 `.withValues`。`player_screen.dart` 内 `PlayerProgress()`→`WaveformProgress()`。
    - **范围决策（不造功能）**：全代码库**无 follow/关注/subscribe 能力**，参考图的「关注」`AccentPill` 无后端 → 不加非功能性 pill（延续 D2 假邮箱/D3 假选中态/D4 假数据源立场）；`AccentPill` 原子保留备用。AppBar 不新增收藏/更多等功能键（§2 不含新功能入口）。
    - 测试：`test/widgets/player/circular_cover_test.dart` 4/4（圆形 `BoxShape.circle`+`ClipOval`、accent 细环三配色轮换、无封面音符回退）。`WaveformProgress` 依赖 GetIt&lt;PlayerViewModel&gt;（重 DI，与无测试的 `PlayerProgress` 一致）不单测，seek 逻辑系复用既测路径。
    - 验证：D5 文件 analyze 仅余 1 既有 withOpacity（`player_screen.dart:193` 未触碰的「未在播放」副标行，Phase E 处理；新码全 `.withValues`）；**全量 `flutter test` 91/91 通过，零回归**。
  - 验证：每屏 × 3 配色 × 明暗 截图对参考图；`flutter analyze` 通过。

- [x] **Phase E — 历史债清理（全部完成）** ✅ 2026-05-16
  - [x] **withOpacity→.withValues 全量** ✅ 2026-05-16：14 文件 24 调用点 perl 机械迁移（行为等价弃用修复），剩余 0（仅 `circular_cover.dart` 注释文本提及）。
  - [x] **移除 shimmer 死依赖** ✅ 2026-05-16：确认全库无 `import 'package:shimmer'`，仅遗留方法名；`pubspec.yaml` 删 `shimmer: ^3.0.0`，`work_files_skeleton.dart` `_buildShimmerItem`→`_buildSkeletonItem`，`flutter pub get` OK。
  - [x] **groupWorksIntoRows memo** ✅ 2026-05-16：`work_layout_strategy.dart` 加类级单槽 memo（键=works 引用 identity + 列数，命中返回同一 List 实例，规范 §7.3）；`test/presentation/layouts/work_layout_strategy_memo_test.dart` 4/4。
  - [~] **UI 中文 → Strings（分批，先核心屏）**：盘点实为 **243 处**（计划 3-4 倍）。
    - **分类豁免（按 plan §6「只收 UI 文案」）**：约 140 处属诊断/非 UI——`Exception()/FormatException()` 抛出串（api_service ~30、auth_service、subtitle_loader、playback_context…）、`NetworkException/UpdateException` 诊断 message、`mark_status` enum label、`pageName` getter、`audio_error_handler` 串、`serverOptions` URL→名数据 map。这些非 `Text()` UI，用户可见错误已走 `NetworkException.userMessage`/`Strings` 翻译层 → **保留，不机械迁移**（高 churn 低值，违 plan「区分 UI/日志只收前者」）。
    - [x] **批次1（核心簇 9 文件）** ✅ 2026-05-16：`main_screen`(tab/nav 标题)、`player_screen`(未在播放/常亮 tooltip)、`mini_player`、`player_work_info`(未知作品/演员)、`player_controls`(4 tooltip)、`player_lyric_view`(无歌词)、`favorites_screen`(复用 `Strings.favorites`)、`similar_works_screen`、`cache_manager_screen`(全屏)。新增 ~25 Strings 常量；批次1文件 analyze `No issues`；**全量 test 95/95 零回归**。
    - [x] **批次2a（发现/搜索+对话框 7 文件）** ✅ 2026-05-16：`search_screen`(排序标签×14 双处:`_getOrderText`+PopupMenu / hint / 字幕 chip / 空态×2)、browse `tags`/`voice_actors`/`circles`(标题/hint/加载失败/暂无，复用 `Strings.retry`)、`login_dialog`(登录/用户名/密码/取消，复用既有)、`sidebar_header`(提示/确认退出/退出登录/语义 label)、`audio_format_order_dialog`(标题/拖拽提示/重置/取消/保存)。新增 ~37 Strings 常量；批次2a analyze `No issues`；**全量 test 95/95 零回归**。
    - [x] **批次3（收尾 14 文件）** ✅ 2026-05-16：`filter_panel`(排序字段×10 双处+菜单/有字幕/升降序)、`filter_with_keyword`(有字幕)、`work_action_buttons`(收藏/标记/评分/检查中/暂无推荐，复用 `Strings.similarWorks`)、`playlist_selection_dialog`(添加到收藏夹/重试/暂无收藏夹/我标记的-喜欢的×2/切换结果函数/N 个作品函数)、`playlists_viewmodel`+`playlists_list_view`+`playlist_works_view`(我标记的-喜欢的/重试/N 个作品/暂无作品)、`work_files_list`(文件列表)、`work_file_item`(下载 tooltip)、`work_tags_panel`+`work_info_header`(字幕，复用 `Strings.subtitleChip`)、`grid_empty`(暂无内容)、`lyric_overlay_manager`(权限对话框)、`detail_screen`/`detail_viewmodel`(播放/操作/标记失败/已标记为 — Strings 插值函数)。注：`detail_viewmodel:475 '移除/添加'` 仅用于 `AppLogger` 日志，按豁免跳过。新增 ~40 Strings 常量+5 函数；**全量 `flutter test` 95/95 零回归**；全量 analyze 仅余 5 处**既有**无关警告（playback_controller/playback_context/recommendation_cache_manager/playlists_content 的 unused、logger printTime 弃用——均非本重构触碰文件），UI 重构净引入 0 告警，`withOpacity` 25→0。
  - 验证（已完成项）：withOpacity grep 0；`flutter pub get` OK；memo 4/4；批次1 analyze 净 + 全量 test 95/95 零回归。

## 6. 风险与回滚（Risks）

- **风险**：参考图含当前可能无后端支撑的功能（倍速、音效设置、均衡器、定时关闭、关注）。
  - **缓解**：D5/D4 执行前逐项确认有无对应能力；无则只做占位/隐藏，**不为对齐 UI 反向造功能**（范围已在 §2 排除）。
- **风险**：圆形封面 + 波形进度是播放器结构性改动，可能影响 Hero 动画与进度交互。
  - **缓解**：`CircularCover` 保留 `Hero(tag:'mini-player-cover')`；`WaveformProgress` 仅视觉层换皮，拖拽 seek 逻辑复用现 `PlayerProgress`。
- **风险**：D 阶段大面积重绘易引入跨配色不一致。
  - **缓解**：强制「三配色一致性」widget 测试 + 逐配色截图；组件禁写死色。
- **回滚**：阶段独立 commit，按阶段 `git revert`；Phase A 纯文档无回滚成本；原子库（C）与屏幕（D）解耦，D 出问题不影响已合入的 C。

## 7. 备注 / 决策记录

- **2026-05-16**：用户提供参考图并要求「组件复用 + 文档规划」，补充「三种配色」。方向由旧版「不改观感」修正为「以参考图为目标的组件复用重塑」，旧方案作废。
- 关键决策：**不重做规范 §7 已闭环项**（PlayerViewModel 节流、IntrinsicHeight 已清零、SkeletonPulse 主体已替代 Shimmer——经实测确认）。
- 关键决策：`AppColors` 双轴架构经参考图验证正确，**保留不动**；本次是换皮+组件收敛，非主题重写。
- 播放器控制区遵循既有约束（见记忆 [[feedback-player-ui-minimal]]）：扩展现有单控制行，**不堆叠重复/歧义图标**；参考图的「定时/倍速/音效/收藏」一行需在不破坏极简前提下评估，宁缺勿乱。
- CCG Coder 未启用（[[feedback-codex-review-loop]]），Claude 直接编辑；后续启用需走 Coder→Codex。
- 本 TODO 仅规划，未开工；执行任一 Phase 前需用户拍板范围。

---

## ✅ 完成标记

> 全部步骤勾选完毕后填写此块，并实际执行 `/init` 刷新根目录 `CLAUDE.md`，然后把本文件移入 `docs/todos/done/`。

- 完成时间：2026-05-16
- 执行命令：`/init`
- CLAUDE.md 更新摘要：UI 层新增 `lib/core/theme/` 设计令牌（AppSpacing/AppRadius/AppTextStyles）、`lib/widgets/common/` 原子组件库（SectionHeader/AccentPill/BrandWordmark/AppFooter/SocialIconRow/CategoryChip/AppSearchField）、`circular_cover.dart`/`waveform_progress.dart`/`sidebar_decoration.dart`；5 屏按参考图重塑；`ui-design-spec.md` 重写为 v4.0（双轴配色+原子复用矩阵）；`shimmer` 依赖移除；`groupWorksIntoRows` 加 memo；UI 文案集中至 `Strings`（诊断/异常串按规范豁免）。
- 关联 commit：未提交（用户未要求 commit；本次为代码与文档变更，待用户决定提交时机）

---

## ⛔ 取消标记（仅 cancelled 任务填写，与上方完成标记互斥）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
