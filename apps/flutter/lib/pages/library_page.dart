import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kukuri_flutter/l10n/app_localizations.dart';

import '../components/navigation_bar.dart';
import '../theme/app_surfaces.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({required this.mode, super.key});

  final NaviMode mode;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  static const _leftBarWidth = 256.0;
  static const _twoPanelChangeWidth = 720.0;

  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _items(l10n);
    final pageWidth = MediaQuery.sizeOf(context).width;
    final showLeftBar = pageWidth > _twoPanelChangeWidth;
    final topPadding = MediaQuery.paddingOf(context).top;
    final shouldPadDetailTop = widget.mode != NaviMode.mobile;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          left: showLeftBar ? 0 : -_leftBarWidth,
          top: 0,
          bottom: 0,
          width: _leftBarWidth,
          child: _LibraryList(
            title: l10n.navLibrary,
            items: items,
            selectedIndex: _selectedItem,
            onSelected: _selectItem,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          left: showLeftBar ? _leftBarWidth : 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: _LibraryDetail(
            title: items[_selectedItem],
            showMenuButton: !showLeftBar,
            topPadding: shouldPadDetailTop ? topPadding : 0,
            onMenuPressed: _showItemSelector,
          ),
        ),
      ],
    );
  }

  void _showItemSelector() {
    final l10n = AppLocalizations.of(context)!;
    final items = _items(l10n);

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        barrierDismissible: true,
        fullscreenDialog: true,
        opaque: false,
        barrierColor: const Color.fromRGBO(0, 0, 0, 0.36),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: math.min(300, MediaQuery.sizeOf(context).width - 16),
              height: double.infinity,
              child: _LibraryList(
                title: l10n.navLibrary,
                withCloseButton: true,
                items: items,
                selectedIndex: _selectedItem,
                onClose: () => Navigator.of(context).pop(),
                onSelected: (index) {
                  _selectItem(index);
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset = Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          );

          return SlideTransition(
            position: offset.animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _selectItem(int index) {
    setState(() => _selectedItem = index);
  }

  List<String> _items(AppLocalizations l10n) {
    return [
      l10n.libraryRecentlyOpened,
      l10n.libraryPinnedBirds,
      l10n.libraryFieldNotes,
      l10n.libraryMigrationMap,
      l10n.libraryAudioSamples,
      l10n.libraryCollectionStats,
    ];
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.withCloseButton = false,
    this.onClose,
  });

  final String title;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool withCloseButton;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      color: appContentSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topPadding),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                if (withCloseButton) ...[
                  const SizedBox(width: 4),
                  CloseButton(onPressed: onClose),
                  const SizedBox(width: 4),
                ] else
                  const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _LibraryListItem(
                  label: items[index],
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryListItem extends StatelessWidget {
  const _LibraryListItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? colors.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 3,
                  height: selected ? 24 : 0,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryDetail extends StatelessWidget {
  const _LibraryDetail({
    required this.title,
    required this.showMenuButton,
    required this.topPadding,
    required this.onMenuPressed,
  });

  final String title;
  final bool showMenuButton;
  final double topPadding;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: appContentSurface,
      child: Column(
        children: [
          SizedBox(height: topPadding),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                if (showMenuButton)
                  Tooltip(
                    message: l10n.libraryMenu,
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: onMenuPressed,
                    ),
                  )
                else
                  const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: showMenuButton ? onMenuPressed : null,
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.libraryDetailBody,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
