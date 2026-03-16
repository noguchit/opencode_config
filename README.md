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

- `"oh-my-opencode@3.5.3"`
  - エージェント/カテゴリ拡張を提供するプラグイン。
- `"opencode-antigravity-auth@latest"`
  - Antigravity 系モデルを使うための認証/連携プラグイン。
  - 初回は `opencode auth login antigravity` の実行が必要。

### 3. provider

`provider` には 2 系統の接続先があります。

- `google`
  - Gemini/Claude 系モデル（Antigravity 名義 + Gemini CLI 名義）を定義。
  - 各モデルに `limit`（context/output 上限）、`modalities`（text/image/pdf 入力可否）、`variants`（thinking の強度や budget）を設定。
  - 現在のモデル ID:
    - `antigravity-gemini-3-pro`
    - `antigravity-gemini-3-flash`
    - `antigravity-claude-sonnet-4-5`
    - `antigravity-claude-sonnet-4-5-thinking`
    - `antigravity-claude-opus-4-5-thinking`
    - `antigravity-claude-opus-4-6-thinking`
    - `gemini-2.5-flash`
    - `gemini-2.5-pro`
    - `gemini-3-flash-preview`
    - `gemini-3-pro-preview`
- `reallms`
  - OpenAI 互換 API 接続 (`@ai-sdk/openai-compatible`)。
  - `baseURL` は固定値:
    - `https://reallms.rescloud.iu.edu/direct/v1/`
  - 利用可能モデル一覧は以下のエンドポイントで確認できます:
    - `https://reallms.rescloud.iu.edu/direct/v1/models`
  - `apiKey` は環境変数参照:
    - `{env:REALLMS_API_KEY}`
  - 現在のモデル:
    - `llama-4-scout`
    - `Qwen3-Coder-Next`
    - `gpt-oss-120b`
  - 補足:
    - RealLMS のモデル ID は大文字小文字を含めて一致させる必要があります。
    - そのため設定上は `qwen3-coder-next` ではなく `Qwen3-Coder-Next` を使います。

### 4. 既定モデル

- `"model": "reallms/Qwen3-Coder-Next"`
- OpenCode が通常利用するデフォルトモデルです。
- `"small_model": "reallms/Qwen3-Coder-Next"`
- 軽量用途の既定モデルです。

### 5. agent

- `"agent.sisyphus.model": "reallms/Qwen3-Coder-Next"`
- `"agent.title.model": "reallms/Qwen3-Coder-Next"`
- 役割別エージェントのモデル既定値です。

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

- `REALLMS_API_KEY`

未設定だと `reallms` プロバイダー経由のモデル呼び出しは失敗します。

## 編集時の目安

1. 既定モデルを変える:
   - `opencode.json` の `model` を `provider/model-name` 形式で更新。
   - 既定の RealLMS 利用先は現在 `reallms/Qwen3-Coder-Next`。
2. 新しいモデルを追加する:
   - `opencode.json` の `provider.<provider>.models` にエントリを追加。
   - RealLMS 側の `/models` で返る `id` をそのまま使う。
3. エージェントごとに使い分ける:
   - `oh-my-opencode.json` の `agents` / `categories` を編集。
