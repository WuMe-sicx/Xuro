# Xuro

[English](README_en.md)

一个使用 Flutter 构建的 [ASMR.ONE](https://asmr.one) 第三方客户端。

## 项目概述

Xuro 旨在通过精美的动画和现代化的用户界面，提供流畅愉悦的 ASMR 聆听体验。

## 特性

- 🎵 稳定的后台播放，再也不用担心杀后台了
- 🎨 精美的动画效果与简洁的 UI 设计
- 📝 字幕/歌词显示，支持 VTT/LRC 格式导入
- 📋 播放列表管理
- 🔍 多维度探索：标签、社团、声优浏览
- ❤️ 收藏功能
- 🔔 Android 13+ 通知权限适配
- 🖥️ 悬浮歌词窗口（Android）
- ⚙️ 完善的设置系统
  - 外观主题（浅色/深色/跟随系统）
  - 音频格式偏好
  - 屏幕常亮
  - 智能路径展开
- 💾 全方位的智能缓存机制
  - 图片智能缓存：优化封面加载速度，告别重复加载
  - 字幕本地缓存：实现快速字幕匹配与加载
  - 音频文件缓存：减少重复下载，节省流量开销
  - 统一缓存管理：一键查看和清理所有缓存
- 🌐 为服务器减轻压力
  - 智能的缓存策略确保资源高效利用
  - 懒加载机制避免无效请求
  - 合理的缓存清理机制平衡本地存储

## 环境要求

- Flutter 3.27.0+
- Dart SDK >=3.2.3 <4.0.0
- Android: minSdk 21 / targetSdk 33
- Java 17

## 安装与运行

```bash
# 克隆仓库
git clone https://github.com/WuMe-sicx/Xuro.git
cd Xuro

# 安装依赖
flutter pub get

# 代码生成（freezed + json_serializable）
dart run build_runner build --delete-conflicting-outputs

# 运行应用（调试模式）
flutter run

# 构建 Release APK
flutter build apk --release
```

## 项目结构

```
lib/
├── core/                 # 核心功能（音频、字幕、主题、缓存、平台服务）
├── data/                 # 数据层（API 服务、数据模型、仓储）
├── presentation/         # 表现层（ViewModel）
├── screens/              # 页面
├── widgets/              # 可复用 UI 组件
└── common/               # 通用功能（常量、工具）
```

## 开发准则

我们维护了一套完整的开发准则以确保代码质量和一致性：
- [开发准则](docs/guidelines_zh.md)

## 贡献指南

在提交贡献之前，请阅读我们的[开发准则](docs/guidelines_zh.md)。

## 许可证

本项目采用 Creative Commons 非商业性使用-相同方式共享许可证 (CC BY-NC-SA) - 查看 [LICENSE](LICENSE) 文件了解详细信息。

原项目作者：[asmroneapp](https://github.com/asmroneapp) | 原始仓库：[Yuro](https://github.com/asmroneapp/Yuro)
