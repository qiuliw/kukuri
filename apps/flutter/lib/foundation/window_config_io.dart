import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'consts.dart';

Future<void> configureWindow() async {
  if (!_isDesktop) {
    return;
  }

  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(
    const Size(minWindowWidth, minWindowHeight),
  );
}

bool get _isDesktop {
  return switch (defaultTargetPlatform) {
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => true,
    _ => false,
  };
}
