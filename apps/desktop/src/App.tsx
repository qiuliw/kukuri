import { useEffect, useState } from 'react';
import { HashRouter } from 'react-router-dom';

import { DesktopShellPage } from '@/shell/DesktopShellPage';
import { GuidePage } from '@/shell/GuidePage';
import {
  type AppProps,
  DesktopShellStoreContext,
  createDesktopShellStore,
} from '@/shell/store';
import {
  type DesktopTheme,
  readDesktopTheme,
  writeDesktopTheme,
} from '@/lib/theme';
import { getGuideStatus, logout as logoutApi } from '@/lib/api';

export function App(props: AppProps) {
  const [store] = useState(() => createDesktopShellStore());
  const [theme, setTheme] = useState<DesktopTheme>(() => readDesktopTheme());
  const [ready, setReady] = useState<boolean | null>(null);

  useEffect(() => {
    void getGuideStatus().then((s) => setReady(s.ready));
  }, []);

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
  }, [theme]);

  useEffect(() => {
    writeDesktopTheme(theme);
  }, [theme]);

  if (ready === null) return null;

  if (!ready) return <GuidePage />;

  return (
    <DesktopShellStoreContext.Provider value={store}>
      <HashRouter>
        <DesktopShellPage
          {...props}
          theme={theme}
          onThemeChange={setTheme}
          onLogout={() => void logoutApi()}
        />
      </HashRouter>
    </DesktopShellStoreContext.Provider>
  );
}
