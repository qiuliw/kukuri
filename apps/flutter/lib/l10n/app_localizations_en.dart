// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kukuri';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navLibrary => 'Library';

  @override
  String get navUser => 'User';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionSettings => 'Settings';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClear => 'Clear';

  @override
  String get homeSearchHint => 'Search contacts, groups, or messages';

  @override
  String get placeholderSearch => 'Search';

  @override
  String get placeholderBody =>
      'This page has no secondary menu. Like Venera, the app shell only provides the top, bottom, and side navigation surfaces; the page decides whether it needs more columns.';

  @override
  String get searchHistory => 'Search History';

  @override
  String searchResultMessage(String query) {
    return 'Search: $query';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsReading => 'Reading';

  @override
  String get settingsLibrary => 'Library';

  @override
  String get settingsNetwork => 'Network';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsDetailBody =>
      'This settings section owns its detail content. On narrow screens the category list collapses into the menu button, with the selected category kept in the header.';

  @override
  String get languageDescription => 'Choose the app display language.';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get libraryRecentlyOpened => 'Recently opened';

  @override
  String get libraryPinnedBirds => 'Pinned birds';

  @override
  String get libraryFieldNotes => 'Field notes';

  @override
  String get libraryMigrationMap => 'Migration map';

  @override
  String get libraryAudioSamples => 'Audio samples';

  @override
  String get libraryCollectionStats => 'Collection stats';

  @override
  String get libraryMenu => 'Library menu';

  @override
  String get libraryDetailBody =>
      'Library owns this secondary menu. On narrow screens the menu collapses into the header, and the selected item remains visible above the detail content.';
}
