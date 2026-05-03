import 'package:flutter/material.dart';
import 'package:kukuri_flutter/l10n/app_localizations.dart';

import '../theme/app_surfaces.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const routeName = '/SearchPage';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _history = ['Sparrow', 'Migration map', 'Audio samples'];

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: appContentSurface,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Tooltip(
                      message: l10n.actionBack,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    Expanded(
                      child: _SearchInput(
                        controller: _controller,
                        focusNode: _focusNode,
                        hintText: l10n.actionSearch,
                        onSubmitted: _submit,
                        clearTooltip: l10n.actionClear,
                        onClear: () {
                          setState(_controller.clear);
                          _focusNode.requestFocus();
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                child: Text(
                  l10n.searchHistory,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final value = _history[index];
                return _HistoryTile(value: value, onTap: () => _submit(value));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.searchResultMessage(text))));
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.clearTooltip,
    required this.onClear,
    required this.onSubmitted,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String clearTooltip;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Icon(Icons.search, color: colors.onSurfaceVariant, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              style: TextStyle(color: colors.onSurface, fontSize: 18),
              cursorColor: colors.primary,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Tooltip(
              message: clearTooltip,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: colors.onSurfaceVariant,
                iconSize: 20,
                onPressed: onClear,
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(Icons.history, color: colors.onSurfaceVariant, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.onSurface, fontSize: 16),
                ),
              ),
              Icon(
                Icons.north_west,
                color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                size: 18,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
