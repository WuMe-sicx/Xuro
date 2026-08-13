class Strings {
  // App
  static const String appName = 'asmr.one';

  // Common
  static const String loading = '加载中...';
  static const String error = '出错了';
  static const String retry = '重试';
  static const String cancel = '取消';
  static const String confirm = '确认';

  // Error prompts — connection & login state
  static const String networkVpnHint = '请先连接 VPN 服务';
  static const String loginRequired = '请先登录';
  static const String goLogin = '去登录';

  // Home
  static const String search = '搜索';
  static const String homeSearchHint = '搜索你喜欢的声音...';
  static const String musicList = '音乐列表将在这里显示';

  // Player
  static const String nowPlaying = '正在播放';
  static const String playerPlaceholder = '播放器控件将在这里显示';
  static const String notPlaying = '未在播放';
  static const String unknownWork = '未知作品';
  static const String unknownArtist = '未知演员';
  static const String noLyrics = '无歌词';
  static const String screenAwakeOn = '开启屏幕常亮';
  static const String screenAwakeOff = '关闭屏幕常亮';
  static const String playerSeekBack10 = '快退 10 秒';
  static const String playerPrevTrack = '上一曲';
  static const String playerNextTrack = '下一曲';
  static const String playerSeekForward10 = '快进 10 秒';

  // Main tabs / navigation
  static const String navRecommend = '推荐';
  static const String navPopular = '热门';
  static const String tabFavorites = '收藏';
  static const String homeTitleRecommend = '为你推荐';
  static const String homeTitlePopular = '热门作品';

  // Similar works
  static const String similarWorks = '相关推荐';

  // Cache manager
  static const String audioCache = '音频缓存';
  static const String subtitleCache = '字幕缓存';
  static const String imageCache = '图片缓存';
  static const String totalCacheSize = '总缓存大小';
  static const String cacheClean = '清理';
  static const String cacheCleanAll = '清理全部';
  static const String cacheExplainTitle = '缓存说明';
  static const String cacheExplainBody = '缓存用于存储最近播放的音频文件、字幕文件和图片，以提高加载速度。'
      '清理全部会同时清除所有类型的缓存数据。';

  // Search — sort labels & states
  static const String sortLatest = '最新收录';
  static const String sortOldest = '最早收录';
  static const String sortReleaseDesc = '发售日期倒序';
  static const String sortReleaseAsc = '发售日期顺序';
  static const String sortSalesDesc = '销量倒序';
  static const String sortSalesAsc = '销量顺序';
  static const String sortPriceDesc = '价格倒序';
  static const String sortPriceAsc = '价格顺序';
  static const String sortRatingDesc = '评价倒序';
  static const String sortReviewDesc = '评论数量倒序';
  static const String sortRjDesc = 'RJ号倒序';
  static const String sortRjAsc = 'RJ号顺序';
  static const String sortRandom = '随机排序';
  static const String sortLabel = '排序';
  static const String searchInputHint = '搜索...';
  static const String searchEmptyPrompt = '输入关键词开始搜索';
  static const String searchNoResults = '没有找到相关结果';
  static const String subtitleChip = '字幕';

  // Browse — tags / voice actors / circles
  static const String browseAllTags = '全部标签';
  static const String browseAllVoiceActors = '全部声优';
  static const String browseAllCircles = '全部社团';
  static const String browseSearchTagsHint = '搜索标签...';
  static const String browseSearchVoiceActorsHint = '搜索声优...';
  static const String browseSearchCirclesHint = '搜索社团...';
  static const String loadFailed = '加载失败';
  static const String browseEmptyTags = '暂无标签';
  static const String browseEmptyVoiceActors = '暂无声优';
  static const String browseEmptyCircles = '暂无社团';
  // 分类屏编号列表行右侧的作品数计数，接口返回 null 时不展示（见 BrowseListItem）
  static String browseItemCountLabel(int n) => '$n 条';

  // Auth / dialogs
  static const String loginAction = '登录';
  static const String dialogHint = '提示';
  static const String confirmLogout = '确认退出登录？';
  static const String logout = '退出登录';
  static const String a11yUserAccount = '用户账户';

  // Audio format order dialog
  static const String audioFormatHint = '拖拽调整优先级，排在前面的格式优先播放';
  static const String reset = '重置';
  static const String save = '保存';

  // Filter panel — order fields & direction
  static const String filterOrderCreateDate = '收录时间';
  static const String filterOrderRelease = '发售日期';
  static const String filterOrderSales = '销量';
  static const String filterOrderPrice = '价格';
  static const String filterOrderRating = '评价';
  static const String filterOrderReview = '评论数量';
  static const String filterOrderRj = 'RJ号';
  static const String filterOrderMyRating = '我的评价';
  static const String filterOrderAllAges = '全年龄';
  static const String filterOrderRandom = '随机';
  static const String filterOrderDefault = '排序';
  static const String hasSubtitle = '有字幕';
  static const String sortDescending = '降序';
  static const String sortAscending = '升序';

  // Work action buttons
  static const String actionFavorite = '收藏';
  static const String actionMark = '标记';
  static const String actionRate = '评分';
  static const String actionChecking = '检查中';
  static const String actionNoRecommend = '暂无推荐';

  // Detail / files
  static const String fileList = '文件列表';
  static const String downloadToLocalTooltip = '下载到本地（离线播放）';
  static const String gridEmpty = '暂无内容';
  static const String noWorks = '暂无作品';

  // Playlist
  static const String addToPlaylist = '添加到收藏夹';
  static const String playlistEmpty = '暂无收藏夹';
  static const String playlistMarked = '我标记的';
  static const String playlistLiked = '我喜欢的';
  static String worksCountLabel(int n) => '$n 个作品';
  static String playlistToggleResult(bool added, String name) =>
      '${added ? '添加成功' : '移除成功'}: $name';

  // Lyric overlay permission dialog
  static const String lyricOverlayPermTitle = '开启悬浮歌词';
  static const String lyricOverlayPermContent = '需要悬浮窗权限来显示歌词，是否授予权限？';
  static const String dialogConfirm = '确定';

  // Detail SnackBars (interpolated)
  static String playFailed(Object e) => '播放失败: $e';
  static String operationFailed(Object e) => '操作失败: $e';
  static String markedAs(String label) => '已标记为$label';
  static String markFailed(Object e) => '标记失败: $e';

  // Detail
  static const String detail = '音乐详情';
  static const String detailPlaceholder = '音乐详细信息将在这里显示';

  // Subtitle Import
  static const String importSubtitle = '导入字幕文件';
  static const String removeImportedSubtitle = '移除导入字幕';
  static const String importSuccess = '字幕导入成功';
  static const String importInvalidFormat = '不支持的字幕格式（仅支持 .vtt/.lrc）';
  static const String importFileTooLarge = '文件过大（最大 5MB）';
  static const String importParseFailed = '字幕解析失败，请检查文件内容';
  static const String importIoError = '文件读取失败';
  static const String subtitleRemoved = '已移除导入字幕';

  // Batch / folder download
  static const String downloadAllTooltip = '下载全部（含字幕）';
  static const String batchDownloadTitle = '批量下载';
  static const String batchDownloadEmpty = '该目录下没有可下载的音频';
  static const String batchDownloadCancelled = '已取消批量下载';
  static String batchDownloadConfirm(int audioCount) =>
      '将顺序下载 $audioCount 个音频（含匹配字幕），是否继续？';
  static String batchDownloadProgress(int index, int total, String name) =>
      '正在下载 $index/$total：$name';
  static String batchDownloadSummary(int ok, int skipped, int failed) =>
      '下载完成：成功 $ok，已存在 $skipped，失败 $failed';

  // Subtitle preview
  static const String subtitlePreviewTitle = '字幕预览';
  static const String subtitlePreviewLoading = '正在加载字幕...';
  static const String subtitlePreviewEmpty = '该字幕没有可显示的内容';
  static const String subtitlePreviewError = '字幕加载失败';
  static const String subtitlePreviewRawNotice = '无法按时间轴解析，显示原始内容';

  // Drawer
  static const String home = '主页';
  static const String favorites = '我的收藏';
  static const String settings = '设置';
  static const String drawerSectionContent = '内容';
  static const String drawerSectionDiscover = '发现';
  static const String drawerSectionSystem = '系统';
  static const String recentPlay = '最近播放';
  static const String tags = '标签';
  static const String circles = '社团';
  static const String voiceActors = '声优';
  static const String ranking = '排行榜';
  static const String darkModeMenu = '深色模式';
  static const String aboutUs = '关于我们';
  static const String comingSoon = '敬请期待';
  static const String loginCta = '立即登录';
  static const String loginCtaSubtitle = '同步收藏与记录';
  static const String loggedInFallback = '已登录';
  static const String loggedInSubtitle = '点击管理账户';
  static const String themeModeLight = '浅色';
  static const String themeModeDark = '深色';
  static const String themeModeSystem = '系统';

  // Settings sections
  static const String appearance = '外观';
  static const String network = '网络';
  static const String content = '内容';
  static const String playback = '播放';
  static const String storage = '存储';
  static const String about = '关于';

  // Settings items
  static const String followSystem = '跟随系统';
  static const String lightMode = '浅色模式';
  static const String darkMode = '深色模式';
  static const String smartPath = '智能路径';
  static const String smartPathDesc = '打开作品后，自动展开包含音频的文件夹';
  static const String audioFormatPreference = '音频格式偏好';
  static const String screenKeepAwake = '屏幕常亮';
  static const String screenKeepAwakeDesc = '播放时保持屏幕开启';
  static const String sleepTimer = '睡眠定时';
  static const String sleepTimerOff = '关闭';
  static String sleepTimerMinutes(int m) => '$m 分钟';
  static const String backgroundPlay = '后台播放';
  static const String backgroundPlayDesc = '关闭后切到后台自动暂停播放';
  static const String cacheManager = '缓存管理';
  static const String themeAutoDesc = '自动切换深浅色模式';

  // About section
  static const String aboutAppName = 'Xuro';
  static const String aboutAppDescription =
      'Xuro 是一个第三方 ASMR.ONE 客户端，支持后台播放、字幕/悬浮歌词、播放列表与缓存。基于 CC BY-NC-SA 协议开源。';
  static const String versionLabel = '版本';
  static const String aboutFooter = '© Xuro · 基于 CC BY-NC-SA 4.0 开源';
  static const String versionInfo = '版本信息';
  static const String openSourceLicenses = '开源许可';
  static const String feedback = '问题反馈';
  static const String sourceCode = '源代码';
  static const String cannotOpenLink = '无法打开链接';
  static const String feedbackUrl = 'https://github.com/WuMe-sicx/Xuro/issues';
  static const String repoUrl = 'https://github.com/WuMe-sicx/Xuro';
  static const String originalRepo = '原作者仓库';
  static const String originalRepoUrl = 'https://github.com/asmroneapp/Yuro';
  static const String telegramChannel = 'Telegram 频道';
  static const String telegramChannelUrl = 'https://t.me/XuroAsmr';

  // Update checking
  static const String checkForUpdates = '检查更新';
  static const String updateChecking = '正在检查更新...';
  static const String updateUpToDate = '已是最新版本';
  static const String updateNewVersionTitle = '发现新版本';
  static const String updateDownload = '立即下载';
  static const String updateLater = '稍后';
  static const String updateOk = '好的';
  static const String updateCurrentVersionLabel = '当前版本';
  static const String updateErrorNetwork = '网络连接失败，请检查网络后重试';
  static const String updateErrorRateLimited = 'GitHub 请求过于频繁，请稍后再试';
  static const String updateErrorNotFound = '未找到发布信息';
  static const String updateErrorNoRelease = '暂无可用发布';
  static const String updateErrorInvalidPayload = '发布信息解析失败';
  static const String updateErrorUnknown = '检查更新失败，请稍后再试';

  // Auth — register
  static const String register = '注册';
  static const String registerTitle = '注册账号';
  static const String registerCta = '没有账号？去注册';
  static const String haveAccountCta = '已有账号？去登录';
  static const String username = '用户名';
  static const String password = '密码';
  static const String passwordConfirm = '确认密码';
  static const String nameTooShort = '用户名至少 5 位';
  static const String passwordTooShort = '密码至少 5 位';
  static const String passwordMismatch = '两次输入的密码不一致';
  static const String registerSuccess = '注册成功，已自动登录';
  static const String registerOkButLoginFailed = '注册成功，但自动登录失败，请用刚才的账号密码登录';

  // Settings — color variant
  static const String colorVariantTitle = '主色调';
  static const String colorVariantDesc = '切换 App 主色，深色 / 浅色模式独立生效';
  static const String colorVariantBlue = '蓝';
  static const String colorVariantMono = '黑';
  static const String colorVariantGreen = '绿';
  static const String colorVariantStill = '红';

  // Settings — floating lyric overlay
  static const String lyricOverlaySection = '悬浮歌词';
  static const String lyricOverlayUnlockTitle = '解锁悬浮歌词位置';
  static const String lyricOverlayUnlockDesc =
      '开启后可在悬浮歌词显示时上下拖动调整位置；关闭则锁定并点穿下层界面';

  // Floating lyric overlay
  static const String lyricOverlayTooltipEnable = '开启悬浮歌词';
  static const String lyricOverlayTooltipLongPressHint = '长按调整悬浮歌词位置';
  static const String lyricOverlayTooltipExitEdit = '退出调整模式';
  static const String lyricOverlayEnterFirstHint = '请先开启悬浮歌词，再长按此按钮调整位置';
  static const String lyricOverlayEditEntered = '已进入调整模式：上下拖动悬浮歌词；再次长按退出';
  static const String lyricOverlayEditExited = '已退出调整模式，悬浮歌词恢复点穿';

  // 本地下载 / 离线 / 视频
  static const String videoNeedsDownloadTitle = '播放视频';
  static const String videoNeedsDownloadPrompt = '打开该视频需要下载到本地磁盘，是否同意？';
  static const String downloadConfirm = '下载';
  static const String downloadCancel = '取消';
  static const String downloading = '正在下载...';
  static const String downloadSuccess = '下载完成';
  static const String downloadOpenFailed = '无法打开文件，请确认已安装可播放的应用';
  static const String downloadCancelled = '已取消下载';
  static const String downloadNetworkError = '下载失败，请检查网络（asmr.one 需连接 VPN）';
  static const String downloadIoError = '下载失败，文件写入错误';
  static const String unsupportedFileType = '暂不支持的文件类型';
  static const String audioDownloadTitle = '下载音频';
  static const String audioDownloadPrompt = '将该音频下载到本地磁盘以便离线播放？';

  // Player — Modernist 改版：顶栏在线/本地角标、底部睡眠定时行
  static const String playerOnline = '在线';
  static const String playerLocal = '本地';
  static const String playerSleepTimerChange = '更改';
  static const String playerSleepTimerInactive = '定时 · 未开启';
  static String playerSleepTimerActive(int minutes) => '定时 · $minutes 分钟后停止';

  // Home — Modernist 发现首页：时段问候（纯客户端计算，无数据源）与分区文案
  static const String continuePlaying = '继续播放';
  static const String todaysPicks = '今晚精选';
  static const String dayPeriodMorning = '早';
  static const String dayPeriodAfternoon = '午';
  static const String dayPeriodEvening = '晚';
  static const String dayPeriodLateNight = '深夜';
  static const String greetingMorning = '早上好，';
  static const String greetingAfternoon = '下午好，';
  static const String greetingEvening = '晚上好，';
  static const String greetingLateNight = '深夜好，';
  static const String greetingPromptDefault = '今天想听点什么？';
  static const String greetingPromptEvening = '今晚想听点什么？';
  static const String greetingPromptLateNight = '想睡前听点什么？';
  static String salesCountLabel(int n) => '销量 $n';
}
