import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/culture_controller.dart';
import '../controllers/progress_controller.dart';
import '../data/services/tracking/tracking_service.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.repository,
    required this.progress,
    required this.tracking,
    required super.child,
  });

  final AuthController auth;
  final CultureController repository;
  final ProgressController progress;
  final TrackingService tracking;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('AppScope not found in widget tree');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return auth != oldWidget.auth ||
        repository != oldWidget.repository ||
        progress != oldWidget.progress ||
        tracking != oldWidget.tracking;
  }
}
