import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String tag, String message, [Object? data]) {
    if (!kDebugMode) return;
    final payload = data != null ? ' | data=$data' : '';
    dev.log('[$tag] $message$payload', name: 'SABEH-DASH.DEBUG', level: 700);
  }

  static void i(String tag, String message, [Object? data]) {
    if (!kDebugMode) return;
    final payload = data != null ? ' | data=$data' : '';
    dev.log('[$tag] $message$payload', name: 'SABEH-DASH.INFO', level: 800);
  }

  static void w(String tag, String message, [Object? data]) {
    if (!kDebugMode) return;
    final payload = data != null ? ' | data=$data' : '';
    dev.log('[$tag] WARN: $message$payload', name: 'SABEH-DASH.WARN', level: 900);
  }

  static void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    dev.log(
      '[$tag] ERROR: $message',
      name: 'SABEH-DASH.ERROR',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void state(String cubit, String from, String to) {
    if (!kDebugMode) return;
    dev.log('[$cubit] $from → $to', name: 'SABEH-DASH.STATE', level: 700);
  }

  static void net(String tag, String operation, [Object? params]) {
    if (!kDebugMode) return;
    final payload = params != null ? ' params=$params' : '';
    dev.log('[$tag] $operation$payload', name: 'SABEH-DASH.NET', level: 700);
  }
}
