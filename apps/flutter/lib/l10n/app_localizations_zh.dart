// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Kukuri';

  @override
  String get navHome => '首页';

  @override
  String get navExplore => '探索';

  @override
  String get navLibrary => '资料库';

  @override
  String get navUser => '我的';

  @override
  String get actionSearch => '搜索';

  @override
  String get actionSettings => '设置';

  @override
  String get actionBack => '返回';

  @override
  String get actionClear => '清除';

  @override
  String get homeSearchHint => '搜索联系人、群聊或消息';

  @override
  String get placeholderSearch => '搜索';

  @override
  String get placeholderBody =>
      '这个页面没有二级菜单。和 Venera 类似，应用外壳只提供顶部、底部和侧边导航；页面自己决定是否需要更多列。';

  @override
  String get searchHistory => '搜索历史';

  @override
  String searchResultMessage(String query) {
    return '搜索：$query';
  }

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsReading => '阅读';

  @override
  String get settingsLibrary => '资料库';

  @override
  String get settingsNetwork => '网络';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsDetailBody =>
      '这个设置分区拥有自己的详情内容。窄屏时分类列表会折叠进菜单按钮，当前选中的分类会保留在标题栏中。';

  @override
  String get languageDescription => '选择应用显示语言。';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChinese => '中文';

  @override
  String get libraryRecentlyOpened => '最近打开';

  @override
  String get libraryPinnedBirds => '置顶鸟类';

  @override
  String get libraryFieldNotes => '野外笔记';

  @override
  String get libraryMigrationMap => '迁徙地图';

  @override
  String get libraryAudioSamples => '音频样本';

  @override
  String get libraryCollectionStats => '收藏统计';

  @override
  String get libraryMenu => '资料库菜单';

  @override
  String get libraryDetailBody =>
      '资料库拥有自己的二级菜单。窄屏时菜单会折叠进标题栏，当前选中的项目会显示在详情内容上方。';
}
