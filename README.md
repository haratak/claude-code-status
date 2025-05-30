# Claude Code Status

macOSメニューバーアプリでClaude Codeのステータスを表示します。

## 機能

- 🟢 アイドル状態
- 🟡 許可待ち状態
- 🔴 タスク実行中

## ビルド方法

```bash
swift build -c release
```

## 実行

```bash
./.build/release/ClaudeCodeStatus
```

## 自動起動設定

アプリをシステム環境設定のログイン項目に追加してください。