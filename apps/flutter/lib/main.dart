import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kukuri_flutter/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'components/fps_overlay.dart';
import 'foundation/app_locale_scope.dart';
import 'foundation/window_config.dart';
import 'pages/main_page.dart';
import 'src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await configureWindow();
  await RustLib.init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      locale: _locale,
      onLocaleChanged: _setLocale,
      child: MaterialApp(
        locale: _locale,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3f7f6f)),
          useMaterial3: true,
        ),
        builder: (context, child) {
          final content = child ?? const SizedBox();
          return _SystemUiProvider(
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: kDebugMode ? FpsOverlay(child: content) : content,
            ),
          );
        },
        home: const MainPage(),
      ),
    );
  }
}

class _SystemUiProvider extends StatelessWidget {
  const _SystemUiProvider({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final systemUiStyle = switch (brightness) {
      Brightness.light => SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      Brightness.dark => SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: child,
    );
  }
}
