import { invokeDesktop } from './invoke/desktop';

export type GuideStatus = {
  ready: boolean;
  pubkey_hex: string | null;
  secret_nsec: string | null;
};

export const getGuideStatus = () =>
  invokeDesktop<GuideStatus>('get_guide_status');

export const createIdentity = () =>
  invokeDesktop<GuideStatus>('create_identity');

export const confirmGuide = () =>
  invokeDesktop<void>('confirm_guide');

export const importIdentity = (secret: string) =>
  invokeDesktop<void>('import_identity', { secret });

export const logout = () => invokeDesktop<void>('logout');
