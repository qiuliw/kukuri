use super::*;
use async_trait::async_trait;
use kukuri_core::{BlobHash, EnvelopeId, ObjectStatus, ObjectVisibility, PayloadRef};
use kukuri_docs_sync::{DocRecord, value_hash};
use kukuri_transport::HintStream;
use std::sync::Arc;
use tokio::sync::Mutex as TokioMutex;

use crate::service::hydration_support::{hint_targets_topic, hydrate_object_projection_from_record};

#[derive(Clone, Default)]
struct RecordingHintTransport {
    published: Arc<TokioMutex<Vec<(TopicId, GossipHint)>>>,
}

#[async_trait]
impl HintTransport for RecordingHintTransport {
    async fn subscribe_hints(&self, _topic: &TopicId) -> Result<HintStream> {
        Ok(Box::pin(futures_util::stream::empty()))
    }

    async fn unsubscribe_hints(&self, _topic: &TopicId) -> Result<()> {
        Ok(())
    }

    async fn publish_hint(&self, topic: &TopicId, hint: GossipHint) -> Result<()> {
        self.published
            .lock()
            .await
            .push((topic.clone(), hint));
        Ok(())
    }
}

#[test]
fn blob_available_hint_targets_topic_matches() {
    let topic = "kukuri:topic:blob-hint-test";
    let hint = GossipHint::BlobAvailable {
        topic_id: TopicId::new(topic),
        hash: BlobHash::new("deadbeef"),
        mime: "image/png".into(),
        bytes: 12,
    };
    assert!(hint_targets_topic(&hint, topic));
    assert!(!hint_targets_topic(&hint, "kukuri:topic:other"));
}

#[tokio::test]
async fn hydrate_publishes_blob_available_after_successful_blob_fetch() {
    let dir = tempdir().expect("tempdir");
    let stack = TestIrohStack::new(dir.path()).await;
    let recording = Arc::new(RecordingHintTransport::default());
    let store = Arc::new(MemoryStore::default());
    let stored = stack
        .blob_service
        .put_blob(b"hello".to_vec(), "text/plain")
        .await
        .expect("put blob");

    let topic_str = "kukuri:topic:blob-announce-integration";
    let topic = TopicId::new(topic_str);
    let author = generate_keys();
    let header = CanonicalPostHeader {
        object_id: EnvelopeId("obj-announce".into()),
        envelope_id: EnvelopeId("env-announce".into()),
        object_kind: "post".into(),
        topic_id: topic.clone(),
        channel_id: None,
        author: Pubkey::from(author.public_key_hex()),
        created_at: 0,
        updated_at: 0,
        payload_ref: PayloadRef::BlobText {
            hash: stored.hash.clone(),
            mime: "text/plain".into(),
            bytes: 5,
        },
        attachments: Vec::new(),
        media_manifest_refs: Vec::new(),
        visibility: ObjectVisibility::Public,
        reply_to: None,
        root: None,
        repost_of: None,
        status: ObjectStatus::Active,
        signature: String::new(),
    };
    let value = serde_json::to_vec(&header).expect("encode header");
    let record = DocRecord {
        key: "objects/obj-announce/state".into(),
        content_hash: value_hash(&value),
        content_len: value.len() as u64,
        value,
    };
    let replica = topic_replica_id(topic_str);
    hydrate_object_projection_from_record(
        stack.blob_service.as_ref(),
        store.as_ref(),
        &replica,
        record,
        Some(recording.as_ref()),
        Some(topic_str),
        None,
    )
    .await
    .expect("hydrate object projection");

    let published = recording.published.lock().await;
    assert_eq!(published.len(), 1, "expected one BlobAvailable publish");
    let (hint_topic, hint) = &published[0];
    assert_eq!(hint_topic.as_str(), topic_str);
    match hint {
        GossipHint::BlobAvailable {
            topic_id,
            hash,
            mime,
            bytes,
        } => {
            assert_eq!(topic_id.as_str(), topic_str);
            assert_eq!(hash.as_str(), stored.hash.as_str());
            assert_eq!(mime, "text/plain");
            assert_eq!(*bytes, 5);
        }
        other => panic!("expected BlobAvailable, got {other:?}"),
    }
}
