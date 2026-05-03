import 'package:flutter/material.dart';
import 'package:kukuri_flutter/l10n/app_localizations.dart';

import '../foundation/app_locale_scope.dart';
import '../foundation/app_page_route.dart';
import '../theme/app_surfaces.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/SettingsPage';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _leftBarWidth = 256.0;
  static const _twoPanelWidth = 720.0;

  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _settingCategories(l10n);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      color: appContentSurface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final enableTwoViews = constraints.maxWidth > _twoPanelWidth;
          if (!enableTwoViews) {
            return _SettingsList(
              title: l10n.actionSettings,
              topPadding: topPadding,
              categories: categories,
              selectedIndex: _selectedCategory,
              onSelected: _openCategory,
            );
          }

          return Row(
            children: [
              SizedBox(
                width: _leftBarWidth,
                child: _SettingsList(
                  title: l10n.actionSettings,
                  topPadding: topPadding,
                  categories: categories,
                  selectedIndex: _selectedCategory,
                  onSelected: _selectCategory,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return LayoutBuilder(
                      builder: (context, constrains) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            final width = constrains.maxWidth;
                            final value = animation.isForwardOrCompleted
                                ? 1 - animation.value
                                : 1;
                            final left = width * value;
                            return Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: left,
                                  width: width,
                                  child: child,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  child: _SettingsDetail(
                    key: ValueKey(_selectedCategory),
                    categoryKey: categories[_selectedCategory].key,
                    showBackButton: false,
                    topPadding: topPadding,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCategory(int index) {
    _selectCategory(index);
    final l10n = AppLocalizations.of(context)!;
    final categories = _settingCategories(l10n);
    Navigator.of(context).push(
      AppPageRoute<void>(
        builder: (context) {
          return Material(
            child: _SettingsDetail(
              categoryKey: categories[index].key,
              showBackButton: true,
              topPadding: MediaQuery.paddingOf(context).top,
            ),
          );
        },
      ),
    );
  }

  void _selectCategory(int index) {
    setState(() => _selectedCategory = index);
  }
}

enum _SettingCategoryKey {
  appearance,
  reading,
  library,
  network,
  language,
  about,
}

List<_SettingCategory> _settingCategories(AppLocalizations l10n) {
  return [
    _SettingCategory(
      key: _SettingCategoryKey.appearance,
      label: l10n.settingsAppearance,
      icon: Icons.color_lens_outlined,
    ),
    _SettingCategory(
      key: _SettingCategoryKey.reading,
      label: l10n.settingsReading,
      icon: Icons.chrome_reader_mode_outlined,
    ),
    _SettingCategory(
      key: _SettingCategoryKey.library,
      label: l10n.settingsLibrary,
      icon: Icons.library_books_outlined,
    ),
    _SettingCategory(
      key: _SettingCategoryKey.network,
      label: l10n.settingsNetwork,
      icon: Icons.public_outlined,
    ),
    _SettingCategory(
      key: _SettingCategoryKey.language,
      label: l10n.settingsLanguage,
      icon: Icons.language_outlined,
    ),
    _SettingCategory(
      key: _SettingCategoryKey.about,
      label: l10n.settingsAbout,
      icon: Icons.info_outline,
    ),
  ];
}

class _SettingCategory {
  const _SettingCategory({
    required this.key,
    required this.label,
    required this.icon,
  });

  final _SettingCategoryKey key;
  final String label;
  final IconData icon;
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({
    required this.title,
    required this.topPadding,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final double topPadding;
  final List<_SettingCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appContentSurface,
      child: Column(
        children: [
          SizedBox(height: topPadding),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  tooltip: AppLocalizations.of(context)!.actionBack,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 8),
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _SettingsListItem(
                  category: categories[index],
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

class _SettingsListItem extends StatelessWidget {
  const _SettingsListItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _SettingCategory category;
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
                Icon(category.icon, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(category.label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsDetail extends StatelessWidget {
  const _SettingsDetail({
    required this.categoryKey,
    required this.showBackButton,
    required this.topPadding,
    super.key,
  });

  final _SettingCategoryKey categoryKey;
  final bool showBackButton;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final category = _settingCategories(
      l10n,
    ).firstWhere((category) => category.key == categoryKey);

    return ColoredBox(
      color: appContentSurface,
      child: Column(
        children: [
          SizedBox(height: topPadding),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                if (showBackButton)
                  Tooltip(
                    message: l10n.actionBack,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  )
                else
                  const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
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
                      Icon(category.icon, size: 40, color: colors.primary),
                      const SizedBox(height: 16),
                      Text(
                        category.label,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      if (category.key == _SettingCategoryKey.language)
                        const _LanguageSettings()
                      else
                        Text(
                          l10n.settingsDetailBody,
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

class _LanguageSettings extends StatelessWidget {
  const _LanguageSettings();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeScope = AppLocaleScope.of(context);
    final selectedLanguage = switch (localeScope.locale?.languageCode) {
      'en' => _LanguageOption.english,
      'zh' => _LanguageOption.chinese,
      _ => _LanguageOption.system,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.languageDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        SegmentedButton<_LanguageOption>(
          segments: [
            ButtonSegment(
              value: _LanguageOption.system,
              icon: const Icon(Icons.devices_outlined),
              label: Text(l10n.languageSystem),
            ),
            ButtonSegment(
              value: _LanguageOption.english,
              icon: const Text('EN'),
              label: Text(l10n.languageEnglish),
            ),
            ButtonSegment(
              value: _LanguageOption.chinese,
              icon: const Text('中'),
              label: Text(l10n.languageChinese),
            ),
          ],
          selected: {selectedLanguage},
          onSelectionChanged: (selection) {
            final option = selection.single;
            final nextLocale = switch (option) {
              _LanguageOption.system => null,
              _LanguageOption.english => const Locale('en'),
              _LanguageOption.chinese => const Locale('zh'),
            };
            localeScope.onLocaleChanged(nextLocale);
          },
        ),
      ],
    );
  }
}

enum _LanguageOption { system, english, chinese }
