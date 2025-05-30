# Claude Code ステータス検出の仕組み

このドキュメントでは、Claude Code Statusアプリがどのようにしてclaude codeのステータスを検出しているかを説明します。

## 概要

Claude Code Statusは以下の2つの方法を組み合わせてステータスを検出します：

1. **ログファイルの監視** - `~/.claude/logs/claude.log`を読み取り、特定のキーワードを検索
2. **プロセスの確認** - `claude`プロセスが実行中かどうかをチェック

## ステータスの種類

```swift
enum ClaudeStatus {
    case idle              // アイドル状態
    case waitingForPermission  // 許可待ち状態
    case executing         // タスク実行中
}
```

## 検出ロジック

### 1. ログファイルの場所

```swift
init() {
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
    self.claudeLogPath = homeDirectory.appendingPathComponent(".claude/logs/claude.log").path
}
```

ログファイルは`~/.claude/logs/claude.log`に保存されています。

### 2. ステータス検出の流れ

```swift
private func detectClaudeStatus() -> ClaudeStatus {
    // 1. ログファイルの存在確認
    guard FileManager.default.fileExists(atPath: claudeLogPath) else {
        return .idle
    }
    
    // 2. ログファイルの最新50行を読み取り
    let logContent = try String(contentsOfFile: claudeLogPath, encoding: .utf8)
    let lines = logContent.components(separatedBy: .newlines)
    let recentLines = lines.suffix(50)
    
    // 3. 新しい行から順にキーワードを検索
    for line in recentLines.reversed() {
        // 許可待ちのキーワード
        if line.contains("Waiting for user permission") || 
           line.contains("requires approval") ||
           line.contains("confirm") {
            return .waitingForPermission
        }
        
        // 実行中のキーワード
        if line.contains("Executing") || 
           line.contains("Running") ||
           line.contains("Processing") ||
           line.contains("Working on") {
            return .executing
        }
    }
    
    // 4. プロセスが実行中ならアイドル状態
    if isClaudeProcessRunning() {
        return .idle
    }
    
    return .idle
}
```

### 3. キーワード検出

#### 許可待ち状態を示すキーワード：
- `"Waiting for user permission"`
- `"requires approval"`
- `"confirm"`

#### タスク実行中を示すキーワード：
- `"Executing"`
- `"Running"`
- `"Processing"`
- `"Working on"`

### 4. プロセスチェック

```swift
private func isClaudeProcessRunning() -> Bool {
    let task = Process()
    task.arguments = ["-c", "pgrep -x claude"]
    task.launchPath = "/bin/bash"
    
    // pgrepコマンドでclaudeプロセスを検索
    // プロセスが見つかればtrue、見つからなければfalse
}
```

`pgrep -x claude`コマンドを使用して、`claude`という名前のプロセスが実行中かどうかを確認します。

## 更新頻度

```swift
func start() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.checkStatus()
    }
}
```

ステータスは**1秒ごと**にチェックされます。

## 制限事項

1. **ログファイル依存** - Claude Codeがログを出力しない場合、ステータスを正確に検出できません
2. **キーワード依存** - ログのフォーマットが変更された場合、キーワードの更新が必要です
3. **遅延** - 最大1秒の遅延が発生する可能性があります

## 今後の改善案

1. Claude Code APIが提供された場合、直接APIを使用する
2. ファイルシステムイベントを監視してリアルタイム更新を実現
3. より多くのステータス（エラー状態など）の検出
4. ログファイルのローテーションへの対応