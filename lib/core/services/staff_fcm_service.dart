import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

class StaffFCMService {
  static const _tag = 'StaffFCMService';
  static const _channelId = 'sabeh_channel';
  static const _channelName = 'Sabeh Notifications';

  StaffFCMService._();
  static final StaffFCMService instance = StaffFCMService._();

  bool _initialized = false;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    AppLogger.d(_tag, 'init called');
    if (kIsWeb) {
      AppLogger.d(_tag, 'init → skipped (web)');
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _createAndroidChannel();
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        AppLogger.d(_tag, 'requesting iOS notification permission');
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        AppLogger.i(_tag, 'iOS permission status=${settings.authorizationStatus.name}');
      }

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _initLocalNotifications();

      FirebaseMessaging.onMessage.listen(_handleForeground);
      _messaging.onTokenRefresh.listen(_saveToken);
      _initialized = true;
      AppLogger.i(_tag, 'init complete');
    } catch (e) {
      AppLogger.e(_tag, 'init failed — Firebase likely not configured', e);
    }
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('sabeh_notification'),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> syncTokenForStaff() async {
    AppLogger.d(_tag, 'syncTokenForStaff called — initialized=$_initialized');
    if (kIsWeb) {
      AppLogger.d(_tag, 'syncTokenForStaff → skipped (web)');
      return;
    }
    if (!_initialized) {
      AppLogger.e(_tag, 'syncTokenForStaff → aborted: Firebase not initialized. Run `flutterfire configure`.');
      return;
    }
    final staffId = Supabase.instance.client.auth.currentUser?.id;
    if (staffId == null) {
      AppLogger.e(_tag, 'syncTokenForStaff → aborted: no authenticated user');
      return;
    }
    AppLogger.d(_tag, 'syncTokenForStaff → fetching token for staff=$staffId');
    try {
      final token = await _getFcmToken();
      AppLogger.d(_tag, 'syncTokenForStaff → token=${token == null ? "null" : "${token.substring(0, 20)}..."}');
      if (token != null) {
        await _saveToken(token);
      } else {
        AppLogger.e(_tag, 'syncTokenForStaff → no FCM token available');
      }
    } catch (e) {
      AppLogger.e(_tag, 'syncTokenForStaff failed', e);
    }
  }

  // On iOS, the APNs token arrives asynchronously after permission is granted.
  // We must wait for it before getToken() will succeed.
  Future<String?> _getFcmToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apns;
      for (int i = 0; i < 10; i++) {
        apns = await _messaging.getAPNSToken();
        AppLogger.d(_tag, '_getFcmToken → APNs attempt $i: ${apns ?? "null"}');
        if (apns != null) break;
        await Future.delayed(const Duration(seconds: 1));
      }
      if (apns == null) {
        AppLogger.e(_tag, '_getFcmToken → APNs token never arrived after 10s. '
            'Check: 1) Push Notifications capability in Xcode, '
            '2) APNs Auth Key uploaded in Firebase Console → Cloud Messaging.');
        return null;
      }
    }
    AppLogger.d(_tag, '_getFcmToken → calling getToken()');
    final token = await _messaging.getToken();
    AppLogger.d(_tag, '_getFcmToken → FCM token=${token ?? "null"}');
    return token;
  }

  Future<void> deleteToken() async {
    AppLogger.d(_tag, 'deleteToken called — initialized=$_initialized');
    if (kIsWeb || !_initialized) return;
    final staffId = Supabase.instance.client.auth.currentUser?.id;
    if (staffId == null) return;
    try {
      await Supabase.instance.client
          .from('staff_fcm_tokens')
          .delete()
          .eq('staff_id', staffId);
      await _messaging.deleteToken();
      AppLogger.i(_tag, 'deleteToken → token removed for staff=$staffId');
    } catch (e) {
      AppLogger.e(_tag, 'deleteToken failed', e);
    }
  }

  Future<void> _saveToken(String token) async {
    final staffId = Supabase.instance.client.auth.currentUser?.id;
    if (staffId == null) {
      AppLogger.e(_tag, '_saveToken → aborted: no authenticated user');
      return;
    }
    AppLogger.d(_tag, '_saveToken → upserting for staff=$staffId');
    try {
      await Supabase.instance.client.from('staff_fcm_tokens').upsert(
        {
          'staff_id':   staffId,
          'token':      token,
          'platform':   kIsWeb ? 'web' : defaultTargetPlatform.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'staff_id',
      );
      AppLogger.i(_tag, 'FCM token saved for staff=$staffId');
    } catch (e) {
      AppLogger.e(_tag, '_saveToken failed', e);
    }
  }

  void _handleForeground(RemoteMessage msg) {
    AppLogger.d(_tag, 'FCM foreground: ${msg.notification?.title}');
    final notification = msg.notification;
    if (notification == null) return;
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          icon: '@drawable/ic_notification',
          largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_notification_large'),
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('sabeh_notification'),
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
          sound: 'sabeh_notification.mp3',
        ),
      ),
    );
  }
}
