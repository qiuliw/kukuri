import 'package:flutter/foundation.dart';

bool get isMobilePlatform {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}
