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

### 3. provider

`provider` には現在 1 系統の接続先があります。

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
    - `DeepSeek-R1`
    - `Qwen3-Coder-Next`
    - `Qwen3-Embedding-8B`
    - `Qwen3-Reranker-8B`
    - `embeddinggemma-300m`
    - `gpt-oss-120b`
  - 補足:
    - REALLMs のモデル ID は大文字小文字を含めて一致させる必要があります。
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

- `oracle`, `metis`, `momus` などのエージェント名ごとに `model` を設定。
- 現在の `sisyphus` は `reallms/Qwen3-Coder-Next` を使います。
- 例:
  - `oracle` -> `reallms/gpt-oss-120b`
  - `explore` -> `opencode/gpt-5-nano`
  - `librarian` -> `opencode/glm-4.7-free`

### 3. categories

- `visual-engineering`, `ultrabrain`, `quick`, `writing` などのカテゴリ単位でモデルを割り当て。
- 現在は高負荷タスクを `reallms/gpt-oss-120b`、軽量タスクを `reallms/Qwen3-Coder-Next` に寄せています。

## 環境変数の前提

`reallms` を使う場合、`.env` などで以下の値が必要です。

- `REALLMS_API_KEY`

未設定だと `reallms` プロバイダー経由のモデル呼び出しは失敗します。

## 編集時の目安

1. 既定モデルを変える:
   - `opencode.json` の `model` を `provider/model-name` 形式で更新。
   - 既定の REALLMs 利用先は現在 `reallms/Qwen3-Coder-Next`。
   - `oh-my-opencode.json` で `agents.sisyphus.model` が上書きされていないかも確認する。
2. 新しいモデルを追加する:
   - `opencode.json` の `provider.<provider>.models` にエントリを追加。
   - REALLMs 側の `/models` で返る `id` をそのまま使う。
3. エージェントごとに使い分ける:
   - `oh-my-opencode.json` の `agents` / `categories` を編集。
