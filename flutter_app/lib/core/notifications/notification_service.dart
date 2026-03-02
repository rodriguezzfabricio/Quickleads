import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class FollowupNotificationScheduler {
  Future<void> scheduleFollowUpNotifications({
    required String leadId,
    required String clientName,
    required DateTime estimateSentAt,
  });

  Future<void> cancelFollowUpNotifications({required String leadId});
}

class NotificationService implements FollowupNotificationScheduler {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _tapPayloadController = StreamController<String>.broadcast();

  Stream<String> get tapPayloadStream => _tapPayloadController.stream;

  static const _followupChannelId = 'followup_reminders';
  static const _followupChannelName = 'Follow-Up Reminders';
  static const _followupChannelDescription =
      'Reminds you to follow up with leads on Day 2, 5, and 10 after sending an estimate.';

  static const _callChannelId = 'call_detection';
  static const _callChannelName = 'Call Detection';
  static const _callChannelDescription =
      'Alerts for unknown callers and daily call review reminders.';

  static const _dailySweepNotificationId = 909901;
  static const _followUpDays = [2, 5, 10];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _tapPayloadController.add(payload);
        }
      },
    );
    await _configureLocalTimezone();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _followupChannelId,
        _followupChannelName,
        description: _followupChannelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _callChannelId,
        _callChannelName,
        description: _callChannelDescription,
        importance: Importance.high,
      ),
    );

    await requestPermissions();
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final macosPlugin = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final iosGranted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final macosGranted = await macosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final androidGranted =
        await androidPlugin?.requestNotificationsPermission() ?? true;

    return iosGranted && macosGranted && androidGranted;
  }

  @override
  Future<void> scheduleFollowUpNotifications({
    required String leadId,
    required String clientName,
    required DateTime estimateSentAt,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return;
    }

    await cancelFollowUpNotifications(leadId: leadId);

    for (final day in _followUpDays) {
      final scheduledDate = estimateSentAt.add(Duration(days: day));
      final fireAt = _atNineAm(scheduledDate);

      if (fireAt.isBefore(DateTime.now())) {
        continue;
      }

      final id = _notificationId(leadId, day);

      await _plugin.zonedSchedule(
        id,
        'Follow-up: $clientName',
        'Day $day check-in — tap to view lead.',
        tz.TZDateTime.from(fireAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _followupChannelId,
            _followupChannelName,
            channelDescription: _followupChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'route:/leads/$leadId',
      );
    }
  }

  @override
  Future<void> cancelFollowUpNotifications({required String leadId}) async {
    for (final day in _followUpDays) {
      await _plugin.cancel(_notificationId(leadId, day));
    }
  }

  Future<void> showCallDetectedNotification({
    required String phoneNumber,
    required DateTime callTime,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final payload =
        'route:/lead-capture?phone=${Uri.encodeQueryComponent(phoneNumber)}';
    await _plugin.show(
      callTime.millisecondsSinceEpoch % 1000000,
      'Unknown call detected',
      '$phoneNumber — Save as lead?',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _callChannelId,
          _callChannelName,
          channelDescription: _callChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> scheduleDailySweepReminder() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _plugin.zonedSchedule(
      _dailySweepNotificationId,
      'Review today\'s calls',
      'Open daily sweep to save unknown callers as leads.',
      _nextSixPm(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _callChannelId,
          _callChannelName,
          channelDescription: _callChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'route:/daily-sweep-review',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() {
    return _plugin.pendingNotificationRequests();
  }

  int _notificationId(String leadId, int day) {
    return (leadId.hashCode.abs() % 100000) * 100 + day;
  }

  DateTime _atNineAm(DateTime date) {
    return DateTime(date.year, date.month, date.day, 9, 0, 0);
  }

  tz.TZDateTime _nextSixPm() {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'NotificationService: could not configure local timezone: $error',
        );
      }
    }
  }
}
