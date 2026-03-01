import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

/// Manages local push notifications for follow-up reminders.
///
/// This is a singleton service because [FlutterLocalNotificationsPlugin]
/// has imperative initialization that must run once at app start via [initialize].
///
/// Usage:
/// ```dart
/// // In main():
/// await NotificationService.instance.initialize();
///
/// // When estimate is sent:
/// await NotificationService.instance.scheduleFollowUpNotifications(
///   leadId: lead.id,
///   clientName: lead.clientName,
///   estimateSentAt: DateTime.now(),
/// );
///
/// // When sequence is paused or stopped:
/// await NotificationService.instance.cancelFollowUpNotifications(leadId: lead.id);
/// ```
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

  static const _channelId = 'followup_reminders';
  static const _channelName = 'Follow-Up Reminders';
  static const _channelDescription =
      'Reminds you to follow up with leads on Day 2, 5, and 10 after sending an estimate.';

  static const _followUpDays = [2, 5, 10];
  bool _isInitialized = false;

  // ── Lifecycle ────────────────────────────────────────────────────

  /// Initialize the notification plugin. Call once in [main] before [runApp].
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

    await _plugin.initialize(initSettings);
    await _configureLocalTimezone();

    // Create the Android notification channel.
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    await requestPermissions();
    _isInitialized = true;

    debugPrint('NotificationService: initialized');
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

  // ── Scheduling ───────────────────────────────────────────────────

  /// Schedule Day 2, 5, and 10 follow-up notifications at 9 AM local time.
  ///
  /// Cancels any previously scheduled notifications for this lead before
  /// scheduling new ones, so re-scheduling is always safe.
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
      debugPrint(
        'NotificationService: permissions denied; skipping scheduling for $leadId',
      );
      return;
    }

    // Cancel existing to avoid duplicate notifications on re-schedule.
    await cancelFollowUpNotifications(leadId: leadId);

    for (final day in _followUpDays) {
      final scheduledDate = estimateSentAt.add(Duration(days: day));
      final fireAt = _atNineAm(scheduledDate);

      // Skip dates already in the past.
      if (fireAt.isBefore(DateTime.now())) {
        debugPrint(
            'NotificationService: skipping day $day for $leadId (past date $fireAt)');
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
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
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
        payload: 'lead:$leadId',
      );

      debugPrint(
          'NotificationService: scheduled day $day for $leadId at $fireAt');
    }
  }

  /// Cancel all scheduled follow-up notifications for a specific lead.
  @override
  Future<void> cancelFollowUpNotifications({required String leadId}) async {
    for (final day in _followUpDays) {
      await _plugin.cancel(_notificationId(leadId, day));
    }
    debugPrint('NotificationService: cancelled all notifications for $leadId');
  }

  /// Returns the list of currently pending notification requests.
  ///
  /// Useful for debugging — call this to verify notifications were scheduled.
  Future<List<PendingNotificationRequest>> pendingNotifications() {
    return _plugin.pendingNotificationRequests();
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Derives a deterministic integer notification ID from [leadId] and [day].
  ///
  /// Uses a stable hash so that re-scheduling (cancel + reschedule) always
  /// targets the same slot and never leaks orphaned IDs.
  int _notificationId(String leadId, int day) {
    // Modulo 100000 keeps the value in the safe int range for Android.
    return (leadId.hashCode.abs() % 100000) * 100 + day;
  }

  /// Returns a [DateTime] representing 9:00 AM on the same calendar day as [date].
  DateTime _atNineAm(DateTime date) {
    return DateTime(date.year, date.month, date.day, 9, 0, 0);
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
