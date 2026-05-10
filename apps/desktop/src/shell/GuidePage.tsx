import { useState } from 'react';
import { useTranslation } from 'react-i18next';

import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Notice } from '@/components/ui/notice';
import { confirmGuide, createIdentity, importIdentity } from '@/lib/api';

type Step = 'choice' | 'backup' | 'import';

export function GuidePage() {
  const { t } = useTranslation('guide');
  const [step, setStep] = useState<Step>('choice');
  const [pubkey, setPubkey] = useState('');
  const [nsec, setNsec] = useState('');
  const [importInput, setImportInput] = useState('');
  const [importError, setImportError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [copied, setCopied] = useState(false);
  const [busy, setBusy] = useState(false);

  async function handleCreate() {
    setBusy(true);
    try {
      const result = await createIdentity();
      setPubkey(result.pubkey_hex ?? '');
      setNsec(result.secret_nsec ?? '');
      setSaved(false);
      setStep('backup');
    } finally {
      setBusy(false);
    }
  }

  async function handleConfirm() {
    setBusy(true);
    await confirmGuide(); // app.restart()
  }

  async function handleImport() {
    const secret = importInput.trim();
    const valid =
      secret.startsWith('nsec1') || /^[0-9a-f]{64}$/i.test(secret);
    if (!valid) {
      setImportError(t('import.invalidFormat'));
      return;
    }
    setImportError(null);
    setBusy(true);
    try {
      await importIdentity(secret); // app.restart()
    } catch (e) {
      setImportError(String(e));
      setBusy(false);
    }
  }

  function handleCopy() {
    navigator.clipboard.writeText(nsec).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  }

  // ── 选择页 ──────────────────────────────────────────────
  if (step === 'choice') {
    return (
      <div className='guide-root'>
        <div className='guide-container'>
          <h1>{t('choice.title')}</h1>
          <p className='lede'>{t('choice.subtitle')}</p>
          <div className='guide-actions'>
            <Button
              disabled={busy}
              onClick={() => void handleCreate()}
            >
              {t('choice.createAction')}
            </Button>
            <Button
              variant='secondary'
              disabled={busy}
              onClick={() => setStep('import')}
            >
              {t('choice.importAction')}
            </Button>
          </div>
        </div>
      </div>
    );
  }

  // ── 备份页 ──────────────────────────────────────────────
  if (step === 'backup') {
    const short = `${pubkey.slice(0, 12)}…${pubkey.slice(-8)}`;
    return (
      <div className='guide-root'>
        <div className='guide-container'>
          <h1>{t('backup.title')}</h1>
          <p className='lede'>
            {t('backup.pubkeyLabel')}: <code>{short}</code>
          </p>
          <Notice tone='destructive'>{t('backup.warning')}</Notice>
          <label className='guide-label'>{t('backup.nsecLabel')}</label>
          <Textarea readOnly value={nsec} rows={3} />
          <Button variant='secondary' onClick={handleCopy}>
            {copied ? t('backup.copied') : t('backup.copy')}
          </Button>
          <label className='guide-checkbox'>
            <input
              type='checkbox'
              checked={saved}
              onChange={e => setSaved(e.target.checked)}
            />
            {t('backup.savedCheckbox')}
          </label>
          <div className='guide-actions'>
            <Button
              disabled={!saved || busy}
              onClick={() => void handleConfirm()}
            >
              {busy ? t('backup.loading') : t('backup.continue')}
            </Button>
            <Button
              variant='secondary'
              disabled={busy}
              onClick={() => setStep('choice')}
            >
              {t('common.back')}
            </Button>
          </div>
        </div>
      </div>
    );
  }

  // ── 导入页 ──────────────────────────────────────────────
  return (
    <div className='guide-root'>
      <div className='guide-container'>
        <h1>{t('import.title')}</h1>
        <p className='lede'>{t('import.desc')}</p>
        <Textarea
          value={importInput}
          onChange={e => {
            setImportInput(e.target.value);
            setImportError(null);
          }}
          placeholder='nsec1… or hex'
          rows={3}
        />
        {importError ? (
          <Notice tone='destructive'>{importError}</Notice>
        ) : null}
        <div className='guide-actions'>
          <Button
            disabled={busy || !importInput.trim()}
            onClick={() => void handleImport()}
          >
            {busy ? t('import.loading') : t('import.action')}
          </Button>
          <Button
            variant='secondary'
            disabled={busy}
            onClick={() => setStep('choice')}
          >
            {t('common.back')}
          </Button>
        </div>
      </div>
    </div>
  );
}
