import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/l10n.dart';

/// 세션 종료 알림과 재방문 알림 (FR-2.3, FR-7).
/// 종료 알림은 동의 없이 예약하고, 시스템 권한이 거부되면 앱 내 진동만 남는다.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const int sessionEndId = 1001;
  static const int revisitId = 2001;

  // 채널 이름·설명은 안드로이드 설정 화면에 보이므로 문자열 테이블에서 온다.
  // BuildContext 가 없어 [L.current] 를 쓴다.
  static AndroidNotificationDetails get _sessionChannel =>
      AndroidNotificationDetails(
    'session_end',
    L.current.notificationSessionChannelName,
    channelDescription: L.current.notificationSessionChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
    playSound: false,
    enableVibration: true,
  );

  static AndroidNotificationDetails get _revisitChannel =>
      AndroidNotificationDetails(
    'revisit',
    L.current.notificationRevisitChannelName,
    channelDescription: L.current.notificationRevisitChannelDescription,
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: false,
    enableVibration: true,
  );

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('notification init failed: $e');
    }
  }

  /// 권한 거부는 실패가 아니다. 앱 내 진동으로 폴백한다 (FR-7.1).
  Future<bool> requestPermission() async {
    await init();
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, badge: false, sound: false) ??
            false;
      }
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
    } catch (e) {
      debugPrint('notification permission failed: $e');
    }
    return false;
  }

  /// 종료 예정 시각에 진동으로만 울린다. 앱을 열면 타임스탬프로 확정한다.
  /// exact alarm은 쓰지 않는다 — 알림 지연을 허용한다 (PRD 플랫폼 설정).
  Future<void> scheduleSessionEnd(DateTime at, {String? body}) async {
    await init();
    if (!_ready) return;
    await cancelSessionEnd();
    if (!at.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: sessionEndId,
        title: L.current.notificationSessionEndTitle,
        body: body ?? L.current.notificationSessionEndBody,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: NotificationDetails(
          android: _sessionChannel,
          iOS: DarwinNotificationDetails(presentSound: false),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('scheduleSessionEnd failed: $e');
    }
  }

  Future<void> cancelSessionEnd() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: sessionEndId);
    } catch (_) {}
  }

  /// 재방문 알림은 별도 동의 후 다음 날 1회, 이후 주 1회 이하 (FR-7.2).
  Future<void> scheduleRevisit(DateTime at, String body) async {
    await init();
    if (!_ready) return;
    if (!at.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: revisitId,
        title: L.current.appTitle,
        body: body,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: NotificationDetails(
          android: _revisitChannel,
          iOS: DarwinNotificationDetails(presentSound: false),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('scheduleRevisit failed: $e');
    }
  }

  Future<void> cancelRevisit() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: revisitId);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// 시작·종료 진동 1회 (FR-2.3).
  Future<void> buzz() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
