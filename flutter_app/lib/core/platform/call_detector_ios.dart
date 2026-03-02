import 'package:flutter/widgets.dart';

class CallDetectorIos with WidgetsBindingObserver {
  CallDetectorIos({required this.onLikelyCallDetected});

  final Future<void> Function() onLikelyCallDetected;
  // TODO(phase5): Add iOS Share Extension target that accepts shared phone
  // numbers and opens CrewCommand lead capture with prefilled phone.

  DateTime? _backgroundedAt;
  DateTime? _lastPromptedAt;
  bool _started = false;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    if (!_started) {
      return;
    }
    WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt = DateTime.now();
      return;
    }

    if (state != AppLifecycleState.resumed) {
      return;
    }

    final now = DateTime.now();
    final backgroundedAt = _backgroundedAt;
    if (backgroundedAt == null) {
      return;
    }

    final awayFor = now.difference(backgroundedAt);
    if (awayFor.inSeconds < 10) {
      return;
    }

    final lastPromptedAt = _lastPromptedAt;
    if (lastPromptedAt != null &&
        now.difference(lastPromptedAt).inMinutes < 5) {
      return;
    }

    _lastPromptedAt = now;
    onLikelyCallDetected();
  }
}
