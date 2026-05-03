import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRoute<T> {
  AppPageRoute({
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    this.preventRebuild = true,
  }) {
    assert(opaque);
  }

  final WidgetBuilder builder;
  final bool preventRebuild;
  Widget? _child;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is PageRoute && !nextRoute.fullscreenDialog;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final result = preventRebuild
        ? _child ??= builder(context)
        : builder(context);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final builder = defaultTargetPlatform == TargetPlatform.android
        ? const PredictiveBackPageTransitionsBuilder()
        : const SlidePageTransitionBuilder();

    return builder.buildTransitions(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

class SlidePageTransitionBuilder extends PageTransitionsBuilder {
  const SlidePageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final primaryAnimation = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => animation,
      _ => CurvedAnimation(parent: animation, curve: Curves.ease),
    };
    final secondaryCurve = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => secondaryAnimation,
      _ => CurvedAnimation(parent: secondaryAnimation, curve: Curves.ease),
    };

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(primaryAnimation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.4, 0),
        ).animate(secondaryCurve),
        child: PhysicalModel(
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
          clipBehavior: Clip.hardEdge,
          elevation: 6,
          child: Material(child: child),
        ),
      ),
    );
  }
}
