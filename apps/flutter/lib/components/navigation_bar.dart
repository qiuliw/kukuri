import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_surfaces.dart';

import '../foundation/app_page_route.dart';
import '../foundation/consts.dart';
import '../foundation/platform.dart';

const _fastAnimationDuration = Duration(milliseconds: 160);

class PaneItemEntry {
  const PaneItemEntry({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class PaneActionEntry {
  const PaneActionEntry({
    required this.label,
    required this.icon,
    required this.onTap,
    this.visible = true,
    this.opacity = 1,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool visible;
  final double opacity;
}

class NaviPane extends StatefulWidget {
  const NaviPane({
    required this.paneItems,
    required this.paneActions,
    required this.pageBuilder,
    required this.navigatorKey,
    required this.observer,
    this.initialPage = 0,
    this.onPageChanged,
    this.topBarBackgroundProgress = 0,
    super.key,
  });

  final List<PaneItemEntry> paneItems;
  final List<PaneActionEntry> paneActions;
  final GlobalKey<NavigatorState> navigatorKey;
  final NaviObserver observer;
  final Widget Function(BuildContext context, int page, NaviMode mode)
  pageBuilder;
  final void Function(int index)? onPageChanged;
  final int initialPage;
  final double topBarBackgroundProgress;

  @override
  State<NaviPane> createState() => NaviPaneState();
}

enum NaviMode { mobile, sideBar, wide }

class NaviPaneState extends State<NaviPane>
    with SingleTickerProviderStateMixin {
  static const _bottomBarHeight = 58.0;
  static const _foldedSideBarWidth = 72.0;
  static const _sideBarWidth = 224.0;
  static const _topBarHeight = 48.0;

  late final AnimationController _controller;
  late int _currentPage = widget.initialPage;
  VoidCallback? _mainViewUpdateHandler;
  double? _animationTarget;
  bool _targetSyncScheduled = false;

  int get currentPage => _currentPage;

  NaviMode get mode {
    final value = _controller.value.round();
    if (value <= 1) return NaviMode.mobile;
    if (value == 2) return NaviMode.sideBar;
    return NaviMode.wide;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      lowerBound: 0,
      upperBound: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NaviPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paneActions != widget.paneActions ||
        oldWidget.paneItems != widget.paneItems) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mainViewUpdateHandler?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncNavigationTarget(context);
    final mediaQuery = MediaQuery.of(context);
    final sideInsets =
        isMobilePlatform && mediaQuery.orientation == Orientation.landscape
        ? EdgeInsets.only(
            left: math.max(
              mediaQuery.viewPadding.left,
              mediaQuery.systemGestureInsets.left,
            ),
            right: math.max(
              mediaQuery.viewPadding.right,
              mediaQuery.systemGestureInsets.right,
            ),
          )
        : EdgeInsets.zero;

    return AnimatedBuilder(
      animation: _controller,
      child: _buildMainNavigator(),
      builder: (context, child) {
        final value = _controller.value;

        final content = Stack(
          children: [
            Positioned(
              left: _foldedSideBarWidth * ((value - 2).clamp(-1.0, 0.0)),
              top: 0,
              bottom: 0,
              child: buildLeft(),
            ),
            Positioned.fill(
              left:
                  _foldedSideBarWidth * ((value - 1).clamp(0.0, 1.0)) +
                  (_sideBarWidth - _foldedSideBarWidth) *
                      ((value - 2).clamp(0.0, 1.0)),
              child: child!,
            ),
          ],
        );

        return sideInsets == EdgeInsets.zero
            ? content
            : Padding(padding: sideInsets, child: content);
      },
    );
  }

  Widget _buildMainNavigator() {
    return Navigator(
      key: widget.navigatorKey,
      observers: [widget.observer],
      onGenerateRoute: (settings) {
        return AppPageRoute<void>(
          preventRebuild: false,
          builder: (context) => _NaviMainView(state: this),
        );
      },
    );
  }

  Widget buildMainViewContent(BuildContext context) {
    return widget.pageBuilder(context, currentPage, mode);
  }

  Widget buildTop() {
    final colors = Theme.of(context).colorScheme;
    final progress = widget.topBarBackgroundProgress.clamp(0.0, 1.0).toDouble();

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28 * progress, sigmaY: 28 * progress),
        child: Material(
          color: appContentSurface.withValues(alpha: 0.86 * progress),
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            height: _topBarHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withValues(
                    alpha: 0.22 * progress,
                  ),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.paneItems[currentPage].label,
                    overflow: TextOverflow.ellipsis,
                    style: appHeaderTextStyle,
                  ),
                ),
                for (final action in widget.paneActions)
                  _TopActionWidget(entry: action, key: ValueKey(action.label)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBottom() {
    return Material(
      textStyle: Theme.of(context).textTheme.labelSmall,
      elevation: 0,
      child: Container(
        height: _bottomBarHeight,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: List<Widget>.generate(widget.paneItems.length, (index) {
            return Expanded(
              child: _SingleBottomNaviWidget(
                enabled: currentPage == index,
                entry: widget.paneItems[index],
                onTap: () => updatePage(index),
                key: ValueKey(index),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildLeft() {
    final value = _controller.value;
    const paddingHorizontal = 12.0;
    return Material(
      child: Container(
        width:
            _foldedSideBarWidth +
            (_sideBarWidth - _foldedSideBarWidth) *
                ((value - 2).clamp(0.0, 1.0)),
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(height: MediaQuery.of(context).padding.top),
            ...List<Widget>.generate(
              widget.paneItems.length,
              (index) => _SideNaviWidget(
                enabled: currentPage == index,
                entry: widget.paneItems[index],
                showTitle: value == 3,
                onTap: () => updatePage(index),
                key: ValueKey(index),
              ),
            ),
            const Spacer(),
            ...List<Widget>.generate(
              widget.paneActions.length,
              (index) => _PaneActionWidget(
                entry: widget.paneActions[index],
                showTitle: value == 3,
                key: ValueKey(widget.paneActions[index].label),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void updatePage(int index) {
    widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    if (_currentPage == index) {
      return;
    }
    setState(() => _currentPage = index);
    widget.onPageChanged?.call(index);
    _mainViewUpdateHandler?.call();
  }

  void _syncNavigationTarget(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    var target = 0.0;
    if (width > changePoint) target = 2.0;
    if (width > changePoint2) target = 3.0;

    if (_animationTarget == target && _controller.isAnimating) {
      return;
    }
    if (_controller.value == target && _animationTarget == target) {
      return;
    }

    _animationTarget = target;
    if (_targetSyncScheduled) {
      return;
    }
    _targetSyncScheduled = true;
    // Keep route construction stable during build; sync the layout animation after this frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _targetSyncScheduled = false;
      if (!mounted || _animationTarget == null) {
        return;
      }
      if (_controller.value != _animationTarget) {
        _controller.animateTo(_animationTarget!);
      }
    });
  }
}

/// Tracks the inner navigator stack so pane actions can avoid duplicate routes.
class NaviObserver extends NavigatorObserver implements Listenable {
  final routes = <Route<dynamic>>[];
  final List<VoidCallback> listeners = [];

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
    notifyListeners();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.add(route);
    notifyListeners();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
    notifyListeners();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    routes.remove(oldRoute);
    if (newRoute != null) {
      routes.add(newRoute);
    }
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in listeners) {
      listener();
    }
  }
}

class _NaviMainView extends StatefulWidget {
  const _NaviMainView({required this.state});

  final NaviPaneState state;

  @override
  State<_NaviMainView> createState() => _NaviMainViewState();
}

class _NaviMainViewState extends State<_NaviMainView> {
  NaviPaneState get state => widget.state;

  @override
  void initState() {
    super.initState();
    state._mainViewUpdateHandler = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    if (state._mainViewUpdateHandler != null) {
      state._mainViewUpdateHandler = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state._controller,
      builder: (context, child) {
        final showMobileChrome = state._controller.value < 2;
        final overlayMobileChrome = showMobileChrome && state.currentPage == 0;

        if (overlayMobileChrome) {
          final bottomPadding = MediaQuery.paddingOf(context).bottom;

          return Stack(
            children: [
              Positioned.fill(
                bottom: NaviPaneState._bottomBarHeight + bottomPadding,
                child: AnimatedSwitcher(
                  duration: _fastAnimationDuration,
                  child: state.buildMainViewContent(context),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPadding,
                child: state.buildBottom(),
              ),
            ],
          );
        }

        return Column(
          children: [
            if (showMobileChrome)
              ColoredBox(
                color: appContentSurface,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top,
                  ),
                  child: state.buildTop(),
                ),
              ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: showMobileChrome,
                child: AnimatedSwitcher(
                  duration: _fastAnimationDuration,
                  child: state.buildMainViewContent(context),
                ),
              ),
            ),
            if (showMobileChrome)
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom,
                ),
                child: state.buildBottom(),
              ),
          ],
        );
      },
    );
  }
}

class _SideNaviWidget extends StatelessWidget {
  const _SideNaviWidget({
    required this.entry,
    required this.enabled,
    required this.showTitle,
    required this.onTap,
    super.key,
  });

  final PaneItemEntry entry;
  final bool enabled;
  final bool showTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = Icon(enabled ? entry.activeIcon : entry.icon);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 38,
          decoration: BoxDecoration(
            color: enabled ? colorScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: showTitle
              ? Row(
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                )
              : Align(alignment: Alignment.centerLeft, child: icon),
        ),
      ),
    );
  }
}

class _TopActionWidget extends StatelessWidget {
  const _TopActionWidget({required this.entry, super.key});

  final PaneActionEntry entry;

  @override
  Widget build(BuildContext context) {
    final progress = entry.visible
        ? entry.opacity.clamp(0.0, 1.0).toDouble()
        : 0.0;

    return SizedBox(
      width: 48,
      height: 48,
      child: IgnorePointer(
        ignoring: progress < 0.65,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          opacity: progress,
          child: Tooltip(
            message: entry.label,
            child: IconButton(icon: Icon(entry.icon), onPressed: entry.onTap),
          ),
        ),
      ),
    );
  }
}

class _PaneActionWidget extends StatelessWidget {
  const _PaneActionWidget({
    required this.entry,
    required this.showTitle,
    super.key,
  });

  final PaneActionEntry entry;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(entry.icon);
    final progress = entry.visible
        ? entry.opacity.clamp(0.0, 1.0).toDouble()
        : 0.0;

    return SizedBox(
      height: 46,
      child: IgnorePointer(
        ignoring: progress < 0.65,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          opacity: progress,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: entry.onTap,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 38,
                child: showTitle
                    ? Row(
                        children: [
                          icon,
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Align(alignment: Alignment.centerLeft, child: icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleBottomNaviWidget extends StatefulWidget {
  const _SingleBottomNaviWidget({
    required this.entry,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final PaneItemEntry entry;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_SingleBottomNaviWidget> createState() =>
      _SingleBottomNaviWidgetState();
}

class _SingleBottomNaviWidgetState extends State<_SingleBottomNaviWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool isHovering = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SingleBottomNaviWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        controller.forward(from: 0);
      } else {
        controller.reverse(from: 1);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      value: widget.enabled ? 1 : 0,
      vsync: this,
      duration: _fastAnimationDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: controller, curve: Curves.ease),
      builder: (context, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (details) => setState(() => isHovering = true),
          onExit: (details) => setState(() => isHovering = false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onTap,
            child: buildContent(),
          ),
        );
      },
    );
  }

  Widget buildContent() {
    final value = controller.value;
    final colorScheme = Theme.of(context).colorScheme;
    final icon = Icon(
      widget.enabled ? widget.entry.activeIcon : widget.entry.icon,
    );
    return Center(
      child: Container(
        width: 64,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          color: isHovering ? colorScheme.surfaceContainer : Colors.transparent,
        ),
        child: Center(
          child: Container(
            width: 32 + value * 32,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              color: value != 0
                  ? colorScheme.secondaryContainer
                  : Colors.transparent,
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
