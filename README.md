# OpenCode JSON 設定メモ

このフォルダーには、OpenCode の設定 JSON が 3 つあります。

## ファイル一覧

1. `opencode.json`
   - メイン設定ファイルです。
   - プラグイン、プロバイダー、利用モデルの既定値を定義しています。
2. `oh-my-opencode.json`
   - `oh-my-opencode` プラグイン用の追加設定です。
   - エージェント名/カテゴリ名ごとに使うモデルを割り当てています。
3. `opencode.json.bak`
   - 旧設定の最小バックアップです。
   - `oh-my-opencode` プラグインだけを有効化した状態が保存されています。

## `opencode.json` の説明

### 1. スキーマ

- `"$schema": "https://opencode.ai/config.json"`
- OpenCode 設定としての構造を示します。

### 2. plugin

- `"oh-my-opencode@latest"`
  - エージェント/カテゴリ拡張を提供するプラグイン。
- `"opencode-antigravity-auth@1.5.1"`
  - Antigravity 系モデルを使うための認証/連携プラグイン。

### 3. provider

`provider` には 2 系統の接続先があります。

- `google`
  - Gemini/Claude 系モデル（Antigravity 名義）を定義。
  - 各モデルに `limit`（context/output 上限）、`modalities`（text/image/pdf 入力可否）、`variants`（thinking の強度や budget）を設定。
- `reallms`
  - OpenAI 互換 API 接続 (`@ai-sdk/openai-compatible`)。
  - `baseURL` と `apiKey` は環境変数参照:
    - `{env:REALLMS_SERVER_URL}`
    - `{env:REALLMS_API_KEY}`
  - 現在は `llama-4-scout` を 1 モデル定義。

### 4. 既定モデル

- `"model": "reallms/llama-4-scout"`
- OpenCode が通常利用するデフォルトモデルです。

## `oh-my-opencode.json` の説明

### 1. スキーマ

- `"$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json"`
- `oh-my-opencode` 設定の形式を指定します。

### 2. agents

- `oracle`, `metis`, `momus` などのエージェント名ごとに、`model` と必要に応じて `variant` を設定。
- 例:
  - `oracle` -> `google/gemini-3-pro` + `high`
  - `explore` -> `opencode/gpt-5-nano`
  - `librarian` -> `opencode/glm-4.7-free`

### 3. categories

- `visual-engineering`, `ultrabrain`, `quick`, `writing` などのカテゴリ単位でモデルを割り当て。
- 高負荷タスクは `gemini-3-pro`、軽量タスクは `gemini-3-flash` に分ける設計になっています。

## 環境変数の前提

`reallms` を使う場合、`.env` などで以下の値が必要です。

- `REALLMS_SERVER_URL`
- `REALLMS_API_KEY`

未設定だと `reallms` プロバイダー経由のモデル呼び出しは失敗します。

## 編集時の目安

1. 既定モデルを変える:
   - `opencode.json` の `model` を `provider/model-name` 形式で更新。
2. 新しいモデルを追加する:
   - `opencode.json` の `provider.<provider>.models` にエントリを追加。
3. エージェントごとに使い分ける:
   - `oh-my-opencode.json` の `agents` / `categories` を編集。
