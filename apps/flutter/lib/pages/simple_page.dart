import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kukuri_flutter/l10n/app_localizations.dart';

import '../components/navigation_bar.dart';
import '../src/rust/api/simple.dart';
import '../theme/app_surfaces.dart';
import 'home_chat_mock_data.dart';
import 'workspace_section.dart';

class SimplePage extends StatefulWidget {
  const SimplePage({
    required this.section,
    required this.displayTitle,
    required this.mode,
    this.onSearchPressed,
    this.onSearchBoxVisibleChanged,
    this.onSearchCollapseProgressChanged,
    super.key,
  });

  final WorkspaceSection section;
  final String displayTitle;
  final NaviMode mode;
  final VoidCallback? onSearchPressed;
  final ValueChanged<bool>? onSearchBoxVisibleChanged;
  final ValueChanged<double>? onSearchCollapseProgressChanged;

  @override
  State<SimplePage> createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> {
  static const double _toolbarHeight = 56;
  static const double _searchSectionHeight = 68;
  static const double _snapDistance = _searchSectionHeight;

  final ScrollController _scrollController = ScrollController();
  Timer? _snapTimer;
  bool _isSnappingSearch = false;
  bool _isSearchBoxVisible = true;
  double _searchCollapseProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncSearchBoxVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.section.title == 'Home') {
        widget.onSearchBoxVisibleChanged?.call(_isSearchBoxVisible);
        widget.onSearchCollapseProgressChanged?.call(_searchCollapseProgress);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SimplePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.title != widget.section.title ||
        oldWidget.onSearchBoxVisibleChanged !=
            widget.onSearchBoxVisibleChanged ||
        oldWidget.onSearchCollapseProgressChanged !=
            widget.onSearchCollapseProgressChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.section.title == 'Home') {
          widget.onSearchBoxVisibleChanged?.call(_isSearchBoxVisible);
          widget.onSearchCollapseProgressChanged?.call(_searchCollapseProgress);
        }
      });
    }
  }

  @override
  void dispose() {
    _snapTimer?.cancel();
    _scrollController
      ..removeListener(_syncSearchBoxVisibility)
      ..dispose();
    super.dispose();
  }

  void _syncSearchBoxVisibility() {
    final nextProgress = (_scrollController.offset / _snapDistance)
        .clamp(0.0, 1.0)
        .toDouble();
    if ((nextProgress - _searchCollapseProgress).abs() > 0.01) {
      setState(() => _searchCollapseProgress = nextProgress);
      widget.onSearchCollapseProgressChanged?.call(nextProgress);
    }

    final nextVisible = nextProgress < 0.92;
    if (nextVisible == _isSearchBoxVisible) {
      return;
    }

    _isSearchBoxVisible = nextVisible;
    widget.onSearchBoxVisibleChanged?.call(nextVisible);
  }

  void _scheduleSearchSnap([
    Duration delay = const Duration(milliseconds: 140),
  ]) {
    if (_isSnappingSearch) {
      return;
    }

    _snapTimer?.cancel();
    _snapTimer = Timer(delay, _snapSearchSection);
  }

  Future<void> _snapSearchSection() async {
    if (!_scrollController.hasClients) {
      return;
    }

    final offset = _scrollController.offset;
    if (offset <= 0 || offset >= _snapDistance) {
      return;
    }

    final target = offset < _snapDistance * 0.52 ? 0.0 : _snapDistance;
    _isSnappingSearch = true;
    try {
      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _isSnappingSearch = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.section.title != 'Home') {
      return _SectionPlaceholder(
        section: widget.section,
        displayTitle: widget.displayTitle,
        onSearchPressed: widget.onSearchPressed,
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final topInset = switch (widget.mode) {
      NaviMode.mobile => MediaQuery.paddingOf(context).top + 48,
      _ => MediaQuery.paddingOf(context).top,
    };
    final showInlineToolbar = widget.mode == NaviMode.mobile;

    return ColoredBox(
      color: appContentSurface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis != Axis.vertical) {
              return false;
            }

            if (notification is ScrollEndNotification) {
              _scheduleSearchSnap(Duration.zero);
            } else if (notification is UserScrollNotification &&
                notification.direction == ScrollDirection.idle) {
              _scheduleSearchSnap(Duration.zero);
            } else if (notification is ScrollUpdateNotification &&
                notification.dragDetails == null) {
              _scheduleSearchSnap();
            }

            return false;
          },
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: false,
            trackVisibility: false,
            thickness: 3,
            radius: const Radius.circular(3),
            minThumbLength: 44,
            mainAxisMargin: 10,
            crossAxisMargin: 2,
            thumbColor: colors.onSurfaceVariant.withValues(alpha: 0.34),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(
                    topInset: showInlineToolbar
                        ? MediaQuery.paddingOf(context).top
                        : topInset,
                    toolbarHeight: showInlineToolbar ? _toolbarHeight : 0,
                    searchHeight: _searchSectionHeight,
                    title: widget.displayTitle,
                    searchIconOpacity: _searchCollapseProgress,
                    searchHint: l10n.homeSearchHint,
                    onSearchPressed: widget.onSearchPressed,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chat = homeChatMocks[index];
                    return _ChatTile(chat: chat);
                  }, childCount: homeChatMocks.length),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({
    required this.section,
    required this.displayTitle,
    this.onSearchPressed,
  });

  final WorkspaceSection section;
  final String displayTitle;
  final VoidCallback? onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: appContentSurface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(section.activeIcon, size: 40, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  displayTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (onSearchPressed != null) ...[
                  const SizedBox(height: 18),
                  _HomeSearchBar(onPressed: onSearchPressed!),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.placeholderBody,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  greet(name: section.title),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SearchHeaderDelegate({
    required this.topInset,
    required this.toolbarHeight,
    required this.searchHeight,
    required this.title,
    required this.searchIconOpacity,
    required this.searchHint,
    required this.onSearchPressed,
  });

  final double topInset;
  final double toolbarHeight;
  final double searchHeight;
  final String title;
  final double searchIconOpacity;
  final String searchHint;
  final VoidCallback? onSearchPressed;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = Theme.of(context).colorScheme;
    final progress = (shrinkOffset / searchHeight).clamp(0.0, 1.0).toDouble();
    final opacity = Curves.easeOut.transform(
      (1 - progress * 1.18).clamp(0.0, 1.0).toDouble(),
    );
    final dividerOpacity = ((progress - 0.92) / 0.08)
        .clamp(0.0, 1.0)
        .toDouble();
    final searchTop = topInset + toolbarHeight + 10 - searchHeight * progress;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: appContentSurface.withValues(alpha: 0.86),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (toolbarHeight > 0)
                Positioned(
                  left: 16,
                  right: 8,
                  top: topInset,
                  height: toolbarHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: appHeaderTextStyle,
                        ),
                      ),
                      Opacity(
                        opacity: searchIconOpacity,
                        child: IgnorePointer(
                          ignoring: searchIconOpacity < 0.65,
                          child: IconButton(
                            tooltip: searchHint,
                            icon: const Icon(Icons.search),
                            onPressed: onSearchPressed,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'New chat',
                        icon: const Icon(Icons.add),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                top: searchTop,
                height: 48,
                child: IgnorePointer(
                  ignoring: opacity < 0.55,
                  child: Opacity(
                    opacity: opacity,
                    child: _SearchField(
                      hint: searchHint,
                      onPressed: onSearchPressed,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 1,
                child: ColoredBox(
                  color: colors.outlineVariant.withValues(
                    alpha: 0.22 * dividerOpacity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => topInset + toolbarHeight + searchHeight;

  @override
  double get minExtent => topInset + toolbarHeight;

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) {
    return oldDelegate.topInset != topInset ||
        oldDelegate.toolbarHeight != toolbarHeight ||
        oldDelegate.searchHeight != searchHeight ||
        oldDelegate.title != title ||
        oldDelegate.searchIconOpacity != searchIconOpacity ||
        oldDelegate.searchHint != searchHint ||
        oldDelegate.onSearchPressed != onSearchPressed;
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, this.onPressed});

  final String hint;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPressed,
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search, color: colors.onSurfaceVariant, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.mic_none, color: colors.onSurfaceVariant, size: 20),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat});

  final HomeChatMock chat;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 26,
                backgroundColor: chat.color,
                child: Text(
                  chat.name.substring(0, 1),
                  style: TextStyle(
                    color: _bestOnAvatarColor(chat.color),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          chat.time,
                          style: TextStyle(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.76,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        chat.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPressed,
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search, color: colors.onSurfaceVariant, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.placeholderSearch,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

Color _bestOnAvatarColor(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black;
}
