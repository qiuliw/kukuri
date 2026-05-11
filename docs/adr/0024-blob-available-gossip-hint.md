# ADR 0024: Blob 可用性宣告（Gossip BlobAvailable）

## Status

Accepted

## Date

2026-05-11

## Base Branch

`main`

## Related

- `docs/adr/0011-kukuri-protocol-v1-draft.md`（Hint / Blob / Topic の用語）
- `docs/adr/0018-channel-first-sidebar-and-unified-epoch-lifecycle.md`（private channel と replica）
- `crates/core/src/envelope.rs` — `GossipHint::BlobAvailable`
- `crates/app-api/src/service/hydration_support.rs` — 宣告の発火条件と `publish_hint`
- `crates/app-api/src/service/private_channels_support.rs` — 受信側の `record_blob_announcement`
- `crates/blob-service/src/lib.rs` — 宣告ピア優先のフェッチ順
- Contract: `crates/app-api/src/tests/blob_announcement.rs`

## Context

オブジェクト本文や添付が blob 参照のとき、クライアントは docs からメタデータを取れた後も、実体 blob をどのピアから先に取るかが未定であるとランダム試行になりやすい。Topic / channel に購読しているピアが「その hash をローカルに持っている」と軽量に示せれば、blob フェッチの順序付けとピア学習に使える。

本 ADR は **永続 canonical ソースではなく、gossip ヒント**としての「blob が利用可能であること」の宣告を固定する。

## Decision

1. **ヒント型**: `GossipHint::BlobAvailable { topic_id, hash, mime, bytes }` を使う（`kukuri_core::GossipHint`）。
2. **発行タイミング**: オブジェクト投影の hydrate 中に、対象 blob がローカルキャッシュで **Available** と判定されたときだけ best-effort で宣告する。インライン本文のみのオブジェクトは対象外。
3. **発行チャネル**: `HintTransport::publish_hint` に渡す論理トピックは `channel_hint_topic_for(topic_id, channel_id)`。
   - 公開チャンネル視点: `TopicId` はそのまま community `topic_id`。
   - プライベートチャンネル: `TopicId` は `private/{channel_id}`（`docs-sync::private_channel_hint_topic` と一致）。
4. **重複抑制**: 同一クライアントは同一 hash に対して一度だけ宣告する（`BlobService::mark_blob_announced` が初回 true のときのみ publish）。
5. **受信側**: hint を受け取った際、`source_peer` があれば `blob_service.record_blob_announcement(hash, peer)` で「このピアがこの hash を宣言した」を記録する（プライベート購読ループ内など）。
6. **フェッチ順**: リモート blob 取得時、`ordered_remote_fetch_peers` が宣告済みピアを先頭に並べ、残りをフォールバックとする。

セキュリティ上、この宣告は **availability のヒント**であり、取得した blob の正当性検証（hash 一致など）は既存の blob パスに任せる。

## Consequences

### Positive

- Topic / channel スコープ内で「どのピアが先に試す価値があるか」が共有される。
- プライベートチャンネルでは宣告トピックが `private/{channel_id}` に寄せられ、購読境界と整合しやすい。

### Negative / Limits

- 宣告はベストエフォート；配信失敗時も本体同期は別経路で続行する。
- 悪意あるピアの虚偽宣告は、フェッチ順を汚染しうるが、本文整合性は hash 検証で抑止する。

## Feature Data Classification（要点）

- Feature 名: blob availability gossip hint（BlobAvailable）
- Durable / Transient: transient gossip（永続 canonical ではない）
- Canonical Source: blob 実体は従来どおり blob store / P2P fetch；宣告は補助メタデータ
- Gossip Hint 必要有無: Yes — `BlobAvailable`
- 必須 contract: `blob_announcement` モジュールのターゲットトピック一致・hydrate 後 publish

## Implementation Notes（実装の単一情報源）

| 項目 | 場所 |
|------|------|
| ヒント定義 | `crates/core/src/envelope.rs` |
| 宣告 publish | `hydration_support::maybe_announce_blob` |
| ヒント購読での記録 | `private_channels_support` 内 `GossipHint::BlobAvailable` 分岐 |
| フェッチ順 | `blob-service` の `ordered_remote_fetch_peers` / `record_blob_announcement` |
