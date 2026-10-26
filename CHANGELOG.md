# Changelog

## [Unreleased]

## [1.1.0]

### 追加

- README.en.md（英語版 README）を追加

### その他

- README.md を外部向けに再構成（クイックスタート・運用ガイド・リファレンス）
  - `.env.examples` からの初期セットアップ手順を追加
  - user-vikunja MCP 向け Agent Skill の導入手順を追加
- 起動・停止・タグ切り替え bat のメッセージを英語に統一

## [1.0.0]

### 追加

- Vikunja の Docker Compose セルフホスト構成を追加
  - PostgreSQL 18 と公式イメージ `vikunja/vikunja` を利用
  - `.env` で公開URL・秘密鍵・DBパスワード・イメージタグを管理
- 起動・停止・イメージタグ切り替え用 bat を追加（`vikunja-up.bat` / `vikunja-down.bat` / `vikunja-tag.bat`）
- README.md を追加

### その他

- bat を UTF-8（BOM 付き）に統一し、`chcp 65001` を追加
