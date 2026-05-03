import 'package:flutter/material.dart';
import 'package:kukuri_flutter/l10n/app_localizations.dart';

import '../components/navigation_bar.dart';
import '../foundation/app_page_route.dart';
import 'library_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'simple_page.dart';
import 'workspace_section.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;
  bool _homeSearchBoxVisible = true;
  double _homeSearchCollapseProgress = 0;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _observer = NaviObserver();

  late final List<WorkspaceSection> _sections = const [
    WorkspaceSection(
      title: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    WorkspaceSection(
      title: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    WorkspaceSection(
      title: 'Library',
      icon: Icons.library_books_outlined,
      activeIcon: Icons.library_books,
    ),
    WorkspaceSection(
      title: 'User',
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NaviPane(
      navigatorKey: _navigatorKey,
      observer: _observer,
      initialPage: _index,
      onPageChanged: (index) => setState(() => _index = index),
      topBarBackgroundProgress: _index == 0 ? _homeSearchCollapseProgress : 1,
      paneItems: [
        for (final section in _sections)
          PaneItemEntry(
            label: _sectionLabel(l10n, section.title),
            icon: section.icon,
            activeIcon: section.activeIcon,
          ),
      ],
      paneActions: [
        PaneActionEntry(
          label: l10n.actionSearch,
          icon: Icons.search_outlined,
          onTap: _openSearch,
          visible: _index != 0 || _homeSearchCollapseProgress > 0.01,
          opacity: _index == 0 ? _homeSearchCollapseProgress : 1,
        ),
        PaneActionEntry(
          label: l10n.actionSettings,
          icon: Icons.settings_outlined,
          onTap: _openSettings,
        ),
      ],
      pageBuilder: (context, index, mode) {
        final section = _sections[index];
        if (section.title == 'Library') {
          return LibraryPage(key: const PageStorageKey('library'), mode: mode);
        }
        return SimplePage(
          key: ValueKey(section.title),
          section: section,
          displayTitle: _sectionLabel(l10n, section.title),
          mode: mode,
          onSearchPressed: index == 0 ? _openSearch : null,
          onSearchBoxVisibleChanged: index == 0
              ? _handleHomeSearchBoxVisibleChanged
              : null,
          onSearchCollapseProgressChanged: index == 0
              ? _handleHomeSearchCollapseProgressChanged
              : null,
        );
      },
    );
  }

  String _sectionLabel(AppLocalizations l10n, String title) {
    return switch (title) {
      'Home' => l10n.navHome,
      'Explore' => l10n.navExplore,
      'Library' => l10n.navLibrary,
      'User' => l10n.navUser,
      _ => title,
    };
  }

  void _handleHomeSearchBoxVisibleChanged(bool isVisible) {
    if (_homeSearchBoxVisible == isVisible) {
      return;
    }
    setState(() => _homeSearchBoxVisible = isVisible);
  }

  void _handleHomeSearchCollapseProgressChanged(double progress) {
    if ((_homeSearchCollapseProgress - progress).abs() <= 0.01) {
      return;
    }
    setState(() => _homeSearchCollapseProgress = progress);
  }

  void _openSearch() {
    _openUniqueRoute(
      routeName: SearchPage.routeName,
      builder: (context) => const SearchPage(),
    );
  }

  void _openSettings() {
    _openUniqueRoute(
      routeName: SettingsPage.routeName,
      builder: (context) => const SettingsPage(),
    );
  }

  void _openUniqueRoute({
    required String routeName,
    required WidgetBuilder builder,
  }) {
    final settingsRoute = _observer.routes
        .where((route) => route.settings.name == routeName)
        .lastOrNull;
    if (settingsRoute != null) {
      _navigatorKey.currentState?.popUntil((route) => route == settingsRoute);
      return;
    }
    _navigatorKey.currentState?.push(
      AppPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: builder,
      ),
    );
  }
}
