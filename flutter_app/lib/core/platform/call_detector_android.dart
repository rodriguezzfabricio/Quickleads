import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../notifications/notification_service.dart';
import '../storage/app_database.dart';
import '../storage/providers.dart';

const _uuid = Uuid();

class CallDetectorAndroid {
  static const MethodChannel _channel =
      MethodChannel('com.crewcommand/call_detector');

  Timer? _pollTimer;
  bool _started = false;

  Future<void> start(WidgetRef ref) async {
    if (_started || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    _started = true;
    await _poll(ref);
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _poll(ref),
    );
  }

  void dispose() {
    _pollTimer?.cancel();
    _started = false;
  }

  Future<void> _poll(WidgetRef ref) async {
    try {
      final response = await _channel.invokeMethod<List<dynamic>>(
        'consumePendingCallEvents',
      );
      if (response == null || response.isEmpty) {
        return;
      }

      for (final item in response) {
        if (item is! Map) {
          continue;
        }
        final payload = Map<String, dynamic>.from(item);
        await _handleCallEnded(ref, payload);
      }
    } catch (error) {
      debugPrint('CallDetectorAndroid poll error: $error');
    }
  }

  Future<void> _handleCallEnded(
    WidgetRef ref,
    Map<String, dynamic> payload,
  ) async {
    final authState = ref.read(authProvider).valueOrNull;
    final orgId = authState?.profile?.organizationId ?? '';
    if (orgId.isEmpty) {
      return;
    }

    final rawPhone = (payload['phoneNumber'] as String?)?.trim() ?? '';
    final phone = _normalizeToE164(rawPhone);
    if (phone == null) {
      return;
    }

    final existing = await ref.read(leadsDaoProvider).getLeadByPhone(orgId, phone);
    if (existing != null) {
      return;
    }

    final durationSec = payload['durationSec'] is int
        ? payload['durationSec'] as int
        : int.tryParse('${payload['durationSec']}') ?? 0;

    final timestampRaw = payload['timestampIso'] as String?;
    final startedAt =
        DateTime.tryParse(timestampRaw ?? '')?.toLocal() ?? DateTime.now();

    await ref.read(callLogsDaoProvider).insertCallLog(
          LocalCallLogsCompanion.insert(
            id: _uuid.v4(),
            organizationId: orgId,
            phoneE164: phone,
            platform: 'android',
            source: 'native_observer',
            startedAt: startedAt,
            durationSec: Value(durationSec),
            disposition: const Value('unknown'),
          ),
        );

    await NotificationService.instance.showCallDetectedNotification(
      phoneNumber: phone,
      callTime: startedAt,
    );
  }

  String? _normalizeToE164(String input) {
    if (input.isEmpty) {
      return null;
    }

    final cleaned = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      return null;
    }

    if (cleaned.startsWith('+') && cleaned.length >= 8) {
      return cleaned;
    }

    final digits = cleaned.replaceAll('+', '');
    if (digits.length == 10) {
      return '+1$digits';
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return '+$digits';
    }
    if (digits.length >= 8) {
      return '+$digits';
    }

    return null;
  }
}
