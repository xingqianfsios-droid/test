# 🪖 Xiangqi Pro - Flutter 开发规范

## 1. 项目命令 (Commands)
- **运行应用**: `flutter run -d chrome` (Web) 或 `flutter run` (Mobile)
- **生成代码**: `flutter pub run build_runner build --delete-conflicting-outputs` (针对 Freezed/JsonSerializable)
- **运行测试**: `flutter test`
- **清理缓存**: `flutter clean && flutter pub get`
- **代码检查**: `flutter analyze`

## 2. 架构规范 (Architecture)
- **状态管理**: 必须使用 **GetX**。
  - 控制器命名: `xxx_controller.dart`
  - 视图命名: `xxx_view.dart`
  - 逻辑与 UI 完全分离，UI 只负责监听 `Obx`。
- **目录结构**:
  - `lib/models`: 存放棋子、棋盘状态数据模型（使用 Freezed）。
  - `lib/controllers`: 存放游戏引擎逻辑、状态管理。
  - `lib/views`: 存放棋盘、棋子、菜单等 UI 组件。
  - `lib/core`: 存放核心算法（如 FEN 码解析、走法验证）。

## 3. 代码风格 (Code Style)
- **命名**: 类名使用 `UpperCamelCase`，变量名使用 `lowerCamelCase`。
- **UI 组件**: 尽量拆分细小的组件（如 `ChessPiece`），避免巨大的 `build` 方法。
- **国际化**: 使用 GetX 自带的 `Translations`。

## 4. 象棋核心规则 (Core Logic)
- **坐标系**: 采用 9x10 坐标系，左上角为 (0,0)。
- **棋谱协议**: 支持 **FEN (Forsyth-Edwards Notation)** 字符串导入导出。
