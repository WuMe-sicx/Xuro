# ASMR One App 开发准则

[English Version](guidelines_en.md)

> 🚦 **开工前请先读**：[`dev_workflow.md`](dev_workflow.md) —— 任何跨文件改动 _或_ 对运行时 / 构建 / 外部行为有可观察变化的任务，必须先在 [`docs/todos/`](todos/) 建立 TODO 文档，功能完成时在文档底部标注并实际执行 `/init`。本文档约束「怎么写」，dev_workflow 约束「怎么走流程」。

## 重要说明

本准则是一个动态文档，会随项目发展而演进。实践中的任何变更都必须更新到本准则中，特别是架构部分必须与实际项目结构保持一致。

## 1. 架构设计准则

### 1.1 解耦原则
- 严格遵循 SOLID 原则
- 使用依赖注入管理组件依赖
- 采用 BLoC 模式分离业务逻辑和UI
- 使用接口定义模块间通信契约

### 1.2 模块化原则
- 按功能划分模块
- 遵循单一职责原则
- 模块间通过清晰的接口通信
- 共享组件放置在 common/shared 目录下

### 1.3 代码组织
<pre>
lib/
├── core/                 # 核心功能
│   ├── di/              # 依赖注入
│   ├── theme/           # 主题配置
│   └── utils/           # 工具类
├── data/                # 数据层
│   ├── models/          # 数据模型
│   ├── repositories/    # 数据仓库
│   └── services/        # 服务实现
├── domain/              # 领域层
│   ├── entities/        # 业务实体
│   └── repositories/    # 仓库接口
├── presentation/        # 表现层
│   ├── blocs/          # 状态管理
│   ├── screens/        # 页面
│   └── widgets/        # 组件
└── common/             # 通用功能
    ├── constants/      # 常量定义
    └── extensions/     # 扩展方法
</pre>

### 1.4 字符串管理
- 所有文本字符串必须在 `lib/common/constants/strings.dart` 中集中定义
- 禁止在代码中使用硬编码的字符串
- 字符串常量按功能模块分组管理
- 为后续国际化做好准备
- 字符串命名应清晰表达其用途

示例：
```dart
class Strings {
  // App
  static const String appName = 'asmr.one';
  
  // Common
  static const String loading = '加载中...';
  
  // Feature specific
  static const String search = '搜索';
}
```

## 2. UI/UX 设计准则

### 2.1 界面设计
- 遵循 Material Design 3 设计规范
- 使用一致的颜色主题和字体
- 保持视觉层次感和空间布局的平衡
- 注重细节，保持像素级别的对齐

### 2.2 动画效果
- 使用 Flutter 内置动画系统
- 所有动画持续时间保持在 200-300ms 之间
- 使用曲线动画（推荐 Curves.easeInOut）
- 实现平滑的页面转场效果
- 添加有意义的微交互动画

### 2.3 性能优化
- 使用 const 构造器
- 合理使用 StatelessWidget
- 避免在 build 方法中进行复杂计算
- 使用 ListView.builder 处理长列表
- 图片资源进行适当压缩和缓存

## 3. 代码质量准则

### 3.1 代码风格
- 遵循 Dart 官方代码风格指南
- 使用 dartfmt 格式化代码
- 类型安全，避免使用 dynamic
- 添加必要的注释，特别是复杂业务逻辑

### 3.2 测试规范
- 单元测试覆盖率要求 > 80%
- 编写 Widget 测试验证UI行为
- 集成测试覆盖关键业务流程
- 使用 mock 进行依赖隔离

## 4. 版本控制准则

### 4.1 Git 规范
- 使用 Feature Branch 工作流
- commit 信息遵循 Angular 规范
- 定期进行代码审查
- 保持 main 分支稳定可用

### 4.2 发布规范
- 遵循语义化版本控制
- 每次发布都要有清晰的更新日志
- 重要版本发布前进行完整测试
- 保留���个版本的文档更新

## 5. 项目管理准则

### 5.1 文档管理
- 及时更新 API 文档
- 维护清晰的 README
- 记录重要的设计决策
- 编写用户指南和开发指南

### 5.2 问题追踪
- 使用 Issue 跟踪 bug 和新功能
- 为每个 Issue 添加适当的标签
- 保持任务的可追踪性
- 定期回顾和更新任务状态 