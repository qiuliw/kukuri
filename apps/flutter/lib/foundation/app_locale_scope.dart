import 'package:flutter/widgets.dart';

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
    super.key,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;

  static AppLocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'No AppLocaleScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppLocaleScope oldWidget) {
    return oldWidget.locale != locale ||
        oldWidget.onLocaleChanged != onLocaleChanged;
  }
}
