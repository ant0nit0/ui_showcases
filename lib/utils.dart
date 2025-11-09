import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void postFrameCallback(void Function() postFrameCallbackMethod) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    postFrameCallbackMethod();
  });
}

/// runs [onFirstBuild] wrapped in a [postFrameCallback] to avoid providers
/// being called during widget builds
void onFirstBuild(
  void Function() onFirstBuildMethod, {
  void Function()? onDispose,
  List<Object?>? keys,
}) {
  useEffect(() {
    // run this action once
    postFrameCallback(onFirstBuildMethod);
    // run this callback on widget disposal
    return () {
      if (onDispose != null) onDispose();
    };
  }, keys ?? [true]);
}
