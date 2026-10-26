# Vikunja（セルフホスト構成）

**日本語** | [English](README.en.md)

オープンソースのタスク管理ツール [Vikunja](https://vikunja.io/) を、Windows 上の Docker Compose で手軽にローカル起動・運用するための構成です。  
公式イメージ（`vikunja/vikunja`）と PostgreSQL 18 を使用し、バッチファイルからワンクリックで起動・停止・バージョン切り替えを行えます。

---

## クイックスタート

初めてこのリポジトリをセットアップし、Vikunja を起動するまでの手順です。

### 前提条件

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) がインストールされ、**起動していること**

### Step 1: 環境変数ファイル（`.env`）を作成する

1. リポジトリ直下の `.env.examples` をコピーし、同じフォルダに `.env` という名前で保存します。
   ```powershell
   Copy-Item .env.examples .env
   ```
2. `.env` をテキストエディタで開き、以下の2つの値を任意のランダムな文字列に変更して保存します。
   - `VIKUNJA_SERVICE_SECRET`（セッション管理などに使う秘密鍵）
   - `VIKUNJA_DATABASE_PASSWORD`（PostgreSQL のパスワード）

### Step 2: Vikunja を起動してアカウントを登録する

1. `vikunja-up.bat` をダブルクリック（または実行）します。
2. コンテナが起動し、自動的にブラウザで `http://localhost:3456` が開きます。
   > **補足:** 初回起動時はデータベースの初期化に数十秒かかることがあります。画面が表示されない場合は、少し待ってからページを再読み込みしてください。
3. 初期状態では既定のユーザーは存在しません。画面の「アカウントを作成（Create account）」からユーザー登録を行ってください。

---

## 使い方・運用ガイド

日常の運用や環境変更の手順です。

### 起動と停止

- **起動する:** `vikunja-up.bat` を実行します（`docker compose up -d` 実行後、ブラウザで Web UI を開きます）。
- **停止する:** `vikunja-down.bat` を実行します（`docker compose down` でコンテナを停止します）。
  - 停止しても、タスクデータ（`db/`）や添付ファイル（`files/`）は削除されずそのまま保持されます。

### バージョン（イメージタグ）を切り替える

Vikunja のバージョンをアップデートまたは固定したい場合は、`vikunja-tag.bat` を使用します。

1. `vikunja-tag.bat` を実行します。
2. 現在設定されているタグが表示されるため、変更したいタグ（例: `v2.7.1` や `latest`）を入力して Enter を押します。
3. 以下の処理が順番に自動実行されます。
   - `docker pull vikunja/vikunja:<入力したタグ>` でイメージを取得
   - `.env` 内の `VIKUNJA_IMAGE_TAG` を更新
   - `docker compose up -d` でコンテナを再作成して反映

※ イメージの取得（`docker pull`）に失敗した場合は、`.env` や実行中のコンテナは変更されません。

### 別マシンや LAN 内からアクセスする

ホスト PC 以外の端末（スマートフォンや LAN 内の別 PC）からアクセスする場合は、公開 URL の変更が必要です。

1. `.env` の `VIKUNJA_SERVICE_PUBLICURL` を、ブラウザから実際にアクセスするアドレス（**ポート番号 `:3456` を含む**）に変更します。
   - 例: `VIKUNJA_SERVICE_PUBLICURL=http://192.168.1.10:3456`
2. `vikunja-down.bat` を実行して一度停止し、続けて `vikunja-up.bat` で再起動します。

> **重要:** URL にポート番号（`:3456`）を含めないと、ユーザー登録やログイン時に `unauthorized` エラーになることがあります。

### Windows のスタートメニューにピン留めする

`.bat` ファイルは Windows の仕様上、直接スタートメニューにピン留めできないことがあります。以下の手順で登録してください。

1. `vikunja-up.bat` などのショートカットを作成します。
2. 作成したショートカットを右クリックして「スタートにピン留めする」を選択するか、以下のフォルダにショートカットを配置します。
   ```text
   %AppData%\Microsoft\Windows\Start Menu\Programs
   ```

### AI エージェントから操作する（Agent Skills / MCP 連携）

Cursor などの AI エージェント環境で `user-vikunja` MCP サーバーと連携してタスク管理を行うための Agent Skill を [tomyou666/skills](https://github.com/tomyou666/skills) で公開しています。

以下のコマンドで Vikunja スキルを導入できます。

```bash
# Vikunja（user-vikunja MCP）
npx skills@latest add tomyou666/skills/skills/vikunja
```

---

## 構成・設定リファレンス

### ファイル・ディレクトリ構成

```text
.
├── docker-compose.yml   # Vikunja + PostgreSQL 18 のコンテナ定義
├── .env.examples        # 環境変数ファイルのテンプレート
├── .env                 # 環境変数設定（Git 管理外）
├── files/               # 添付ファイルなどの永続化領域（Git 管理外）
├── db/                  # PostgreSQL データの永続化領域（Git 管理外）
├── vikunja-up.bat       # 起動用バッチ（コンテナ起動＋ブラウザ表示）
├── vikunja-down.bat     # 停止用バッチ（コンテナ停止）
└── vikunja-tag.bat      # イメージタグ切り替え用バッチ
```

### 環境変数（`.env`）一覧

| 変数名 | 説明 | 設定例 |
|---|---|---|
| `VIKUNJA_SERVICE_PUBLICURL` | ブラウザから到達する URL（ポート番号を含む） | `http://localhost:3456` |
| `VIKUNJA_IMAGE_TAG` | 使用する `vikunja/vikunja` の Docker イメージタグ | `latest` / `v2.7.1` |
| `VIKUNJA_SERVICE_SECRET` | セッション署名などに使用する秘密鍵（ランダムな長文字列） | `openssl rand -base64 48` の出力値など |
| `VIKUNJA_DATABASE_PASSWORD` | PostgreSQL のパスワード（Vikunja と `db` コンテナ間で共有） | `openssl rand -base64 32` の出力値など |

### サービス仕様・エンドポイント

- **アクセス URL**
  - Web UI: `http://localhost:3456`
  - API Info: `http://localhost:3456/api/v1/info`
- **コンテナ構成（`docker-compose.yml`）**
  - **Vikunja (`vikunja`)**: イメージ `vikunja/vikunja:${VIKUNJA_IMAGE_TAG:-latest}`、ポート `3456:3456`、添付ファイル保存先 `./files:/app/vikunja/files`
  - **PostgreSQL (`db`)**: イメージ `postgres:18`、データ保存先 `./db:/var/lib/postgresql`、ヘルスチェック完了後に Vikunja を起動
- **ファイル仕様・セキュリティ**
  - 各 `.bat` ファイルは、Cursor などのエディタで文字化けせず編集しやすいよう **UTF-8（BOM 付き）** で保存しています。
  - `.env`、`db/`、`files/` の中身は `.gitignore` によって Git 管理対象外となっています。パスワードや秘密鍵を含むファイルをリポジトリにコミットしないでください。

---

## 参考リンク

- [Vikunja 公式ドキュメント](https://vikunja.io/docs/)
- [Vikunja Docker Walkthrough](https://vikunja.io/docs/docker-walkthrough/)
- [GitHub: go-vikunja/vikunja](https://github.com/go-vikunja/vikunja)
- [GitHub: tomyou666/skills（Vikunja Agent Skill）](https://github.com/tomyou666/skills)
