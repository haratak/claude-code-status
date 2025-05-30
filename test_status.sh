#!/bin/bash

# Claude Code Status テストスクリプト

LOG_FILE="$HOME/.claude/logs/claude.log"

echo "Claude Code Status テストスクリプト"
echo "==================================="
echo ""
echo "ログファイル: $LOG_FILE"
echo ""

# ログディレクトリが存在しない場合は作成
mkdir -p "$(dirname "$LOG_FILE")"

# 各ステータスをテスト
echo "1. アイドル状態をテスト (5秒間)"
echo "[$(date)] Claude is idle" >> "$LOG_FILE"
sleep 5

echo "2. 許可待ち状態をテスト (5秒間)"
echo "[$(date)] Waiting for user permission to edit file" >> "$LOG_FILE"
sleep 5

echo "3. 実行中状態をテスト (5秒間)"
echo "[$(date)] Executing task: Building project..." >> "$LOG_FILE"
sleep 5

echo "4. 別の実行中状態をテスト (5秒間)"
echo "[$(date)] Running tests..." >> "$LOG_FILE"
sleep 5

echo "5. アイドル状態に戻る"
echo "[$(date)] Task completed. Idle." >> "$LOG_FILE"

echo ""
echo "テスト完了！"
echo "メニューバーのアイコンが変化したか確認してください。"