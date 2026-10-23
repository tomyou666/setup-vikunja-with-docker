# Changelog

## [1.0.0]

### 追加

- Vikunja の Docker Compose セルフホスト構成を追加
  - PostgreSQL 18 と公式イメージ `vikunja/vikunja` を利用
  - `.env` で公開URL・秘密鍵・DBパスワード・イメージタグを管理
- 起動・停止・イメージタグ切り替え用 bat を追加（`vikunja-up.bat` / `vikunja-down.bat` / `vikunja-tag.bat`）
- README.md を追加

### その他

- bat を UTF-8（BOM 付き）に統一し、`chcp 65001` を追加
