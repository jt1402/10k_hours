import 'dart:io' show Platform;

import 'package:flutter/services.dart';

// Bridge to the iOS Live Activity (Dynamic Island + Lock Screen) controller
// living in the native Runner target. Methods no-op on non-iOS or when the
// channel call throws — Live Activity is non-critical UX and must never
// crash the app.
class LiveActivityService {
  const LiveActivityService();

  static const MethodChannel _channel = MethodChannel(
    'ten_k_hours/live_activity',
  );

  bool get isSupported => Platform.isIOS;

  Future<void> start({
    required String pursuitName,
    required int pursuitColorARGB,
    required DateTime effectiveStartedAt,
    String? displayText,
    DateTime? targetEndAt,
  }) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('start', {
        'pursuitName': pursuitName,
        'pursuitColorARGB': pursuitColorARGB,
        'effectiveStartedAtMs': effectiveStartedAt.millisecondsSinceEpoch,
        'displayText': ?displayText,
        'targetEndAtMs': ?targetEndAt?.millisecondsSinceEpoch,
      });
    } on Object catch (_) {
      // intentionally swallowed — Live Activity is non-critical UX
    }
  }

  Future<void> update({
    required DateTime effectiveStartedAt,
    required bool isPaused,
    required int pausedAtFreezeSeconds,
    String? displayText,
  }) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('update', {
        'effectiveStartedAtMs': effectiveStartedAt.millisecondsSinceEpoch,
        'isPaused': isPaused,
        'pausedAtFreezeSeconds': pausedAtFreezeSeconds,
        'displayText': ?displayText,
      });
    } on Object catch (_) {
      // intentionally swallowed — Live Activity is non-critical UX
    }
  }

  // [finished] true when the pursuit's goal was reached, so the activity ends
  // with a "Finished" card that lingers on the lock screen; a manual stop
  // dismisses it immediately.
  Future<void> end({bool finished = false}) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('end', {'finished': finished});
    } on Object catch (_) {
      // intentionally swallowed — Live Activity is non-critical UX
    }
  }
}
