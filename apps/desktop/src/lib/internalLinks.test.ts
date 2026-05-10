import { describe, expect, it } from 'vitest';

import {
  buildChannelAccessPreviewDeepLink,
  normalizePrivateChannelAccessTokenInput,
  parseChannelAccessPreviewDeepLink,
} from './internalLinks';

describe('parseChannelAccessPreviewDeepLink', () => {
  it('decodes base64 token query param to raw JSON (Rust preview/import)', () => {
    const rawJson = JSON.stringify({
      envelope: {
        kind: 'channel-invite',
        pubkey: 'f'.repeat(64),
        content: JSON.stringify({
          channel_id: 'channel-imported',
          topic_id: 'kukuri:topic:private-imported',
          channel_label: 'Imported',
          owner_pubkey: 'f'.repeat(64),
          epoch_id: 'epoch-imported-1',
          namespace_secret_hex: 'a'.repeat(64),
          expires_at: null,
        }),
      },
    });
    const encoded = btoa(encodeURIComponent(rawJson));
    const url = `kukuri://access-preview?token=${encodeURIComponent(encoded)}`;

    const ref = parseChannelAccessPreviewDeepLink(url);
    expect(ref?.kind).toBe('share_token');
    expect(ref?.token).toBe(rawJson);
    expect(ref?.tokenKind).toBe('invite');
  });

  it('supports legacy URLs with plain JSON in token= (no base64)', () => {
    const rawJson = JSON.stringify({
      envelope: {
        kind: 'channel-invite',
        pubkey: 'f'.repeat(64),
        content: JSON.stringify({
          channel_id: 'ch1',
          topic_id: 'kukuri:topic:t',
          channel_label: 'L',
          owner_pubkey: 'f'.repeat(64),
          epoch_id: 'e1',
        }),
      },
    });
    const url = buildChannelAccessPreviewDeepLink(rawJson);
    const ref = parseChannelAccessPreviewDeepLink(url);
    expect(ref?.token).toBe(rawJson);
    expect(ref?.tokenKind).toBe('invite');
  });

  it('supports legacy invite: shortcut tokens', () => {
    const token = 'invite:kukuri:topic:demo:channel-1';
    const url = buildChannelAccessPreviewDeepLink(token);
    const ref = parseChannelAccessPreviewDeepLink(url);
    expect(ref?.token).toBe(token);
    expect(ref?.tokenKind).toBe('invite');
  });
});

describe('normalizePrivateChannelAccessTokenInput', () => {
  it('extracts raw JSON from access-preview deep links (for Rust preview/import)', () => {
    const rawJson = JSON.stringify({
      envelope: {
        kind: 'channel-invite',
        pubkey: 'f'.repeat(64),
        content: JSON.stringify({
          channel_id: 'ch1',
          topic_id: 'kukuri:topic:t',
          channel_label: 'L',
          owner_pubkey: 'f'.repeat(64),
          epoch_id: 'e1',
        }),
      },
    });
    const encoded = btoa(encodeURIComponent(rawJson));
    const url = `kukuri://access-preview?token=${encodeURIComponent(encoded)}`;
    expect(normalizePrivateChannelAccessTokenInput(url)).toBe(rawJson);
    expect(normalizePrivateChannelAccessTokenInput(`  ${url}  `)).toBe(rawJson);
  });

  it('passes through raw JSON and legacy shortcuts unchanged', () => {
    const raw = '{"envelope":{"kind":"channel-invite"}}';
    expect(normalizePrivateChannelAccessTokenInput(raw)).toBe(raw);
    expect(normalizePrivateChannelAccessTokenInput('invite:kukuri:topic:demo:channel-1')).toBe(
      'invite:kukuri:topic:demo:channel-1'
    );
  });
});
