import 'dart:io' show Platform;

import 'package:flutter/services.dart';

// Bridge to the native AlarmKit controller (iOS 26+) living in the Runner
// target. Schedules a one-shot system alarm that fires at the pursuit's goal
// time even while the app is suspended — the only no-push way to alert the
// user "live" at the exact moment the goal is reached.
//
// All methods no-op on non-iOS, on iOS < 26, when authorization is denied, or
// when the channel call throws — the goal alarm is an enhancement and must
// never crash the app.
class AlarmService {
  const AlarmService();

  static const MethodChannel _channel = MethodChannel('ten_k_hours/goal_alarm');

  bool get isSupported => Platform.isIOS;

  // Schedule (or replace) the goal alarm to fire at [at]. Any previously
  // scheduled alarm is cancelled natively first, so callers can simply
  // reschedule on resume/target changes.
  Future<void> schedule({
    required DateTime at,
    required String pursuitName,
    required int pursuitColorARGB,
  }) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('schedule', {
        'fireAtMs': at.millisecondsSinceEpoch,
        'pursuitName': pursuitName,
        'pursuitColorARGB': pursuitColorARGB,
      });
    } on Object catch (_) {
      // intentionally swallowed — goal alarm is non-critical
    }
  }

  Future<void> cancel() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('cancel');
    } on Object catch (_) {
      // intentionally swallowed — goal alarm is non-critical
    }
  }
}
