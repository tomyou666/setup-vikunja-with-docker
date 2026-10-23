# Vikunja（セルフホスト）

[Vikunja](https://vikunja.io/) を Docker Compose でローカル起動するための構成です。  
公式イメージ `vikunja/vikunja` と PostgreSQL 18 を使います。

## 前提

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) がインストール済みであること
- Docker Desktop が起動していること

## 起動・停止

| ファイル | 内容 |
|---|---|
| `vikunja-up.bat` | `docker compose up -d` のあと、ブラウザで http://localhost:3456 を開く |
| `vikunja-down.bat` | `docker compose down`（`files` / `db` のデータは残る） |
| `vikunja-tag.bat` | イメージタグを入力して切り替え（pull → `.env` 更新 → 再起動） |

初回起動後は既定ユーザーはありません。画面上でアカウントを登録してください。

## アクセス

- Web UI: http://localhost:3456
- API info: http://localhost:3456/api/v1/info

## 構成ファイル

```
.
├── docker-compose.yml   # Vikunja + PostgreSQL
├── .env                 # 公開URL・秘密鍵・DBパスワード・イメージタグ（Git管理外）
├── files/               # 添付ファイルなど
├── db/                  # PostgreSQL データ
├── vikunja-up.bat
├── vikunja-down.bat
└── vikunja-tag.bat
```

### `.env`

| 変数 | 説明 |
|---|---|
| `VIKUNJA_SERVICE_PUBLICURL` | ブラウザから到達する URL（ポート含む）。例: `http://localhost:3456` |
| `VIKUNJA_SERVICE_SECRET` | セッションなどに使う秘密鍵 |
| `VIKUNJA_DATABASE_PASSWORD` | PostgreSQL パスワード（Vikunja 側と共有） |
| `VIKUNJA_IMAGE_TAG` | Docker イメージタグ。例: `latest` / `v2.7.1` |

別マシンや LAN から開く場合は、`VIKUNJA_SERVICE_PUBLICURL` をそのアドレス（ポート `3456` 付き）に変更してから、一度 `vikunja-down.bat` → `vikunja-up.bat` してください。ポートを URL に含めないと、ユーザー登録で unauthorized になることがあります。

### `docker-compose.yml`

- ポート: ホスト `3456` → コンテナ `3456`
- 永続化: `./files`、`./db`
- イメージ: `vikunja/vikunja:${VIKUNJA_IMAGE_TAG:-latest}`

## イメージタグの変更

`vikunja-tag.bat` を実行し、タグを入力します（例: `v2.7.1`）。

1. `docker pull vikunja/vikunja:<tag>`
2. `.env` の `VIKUNJA_IMAGE_TAG` を更新
3. `docker compose up -d` で反映

取得に失敗した場合は `.env` は変更しません。

## スタートへのピン留め

`.bat` は直接ピン留めできないことが多いです。ショートカットを作成し、そのショートカットを「スタートにピン留め」してください。  
スタート一覧に並べたい場合は、ショートカットを次へ置きます。

```
%AppData%\Microsoft\Windows\Start Menu\Programs
```

## 注意

- bat は UTF-8（BOM 付き）です。Cursor などで編集しやすいようにしています
- `.env`・`db/`・`files/` の中身は `.gitignore` 対象です。秘密情報をコミットしないでください
- `vikunja-down.bat` はコンテナを止めるだけで、データディレクトリは削除しません

## 参考

- [Vikunja 公式ドキュメント](https://vikunja.io/docs/)
- [Docker Walkthrough](https://vikunja.io/docs/docker-walkthrough/)
- [GitHub: go-vikunja/vikunja](https://github.com/go-vikunja/vikunja)
