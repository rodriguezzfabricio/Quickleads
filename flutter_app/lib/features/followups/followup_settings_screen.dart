import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../auth/providers/auth_provider.dart';

// ── Template key constants ────────────────────────────────────────────────────

abstract final class FollowUpTemplateKeys {
  static const day2 = 'day_2_followup';
  static const day5 = 'day_5_followup';
  static const day10 = 'day_10_followup';

  static const ordered = [day2, day5, day10];

  static const defaultMessages = {
    day2:
        'Hi {client_name}, just wanted to follow up on the estimate I sent for your {job_type}. Any questions? — {contractor_name}',
    day5:
        'Hey {client_name}, checking in on the {job_type} estimate. Still interested? Happy to adjust if needed. — {contractor_name}',
    day10:
        'Hi {client_name}, last follow-up on the {job_type} estimate. Let me know if you\'d like to move forward. — {contractor_name}',
  };

  static String dayLabel(String key) => switch (key) {
        day2 => 'Day 2 Follow-Up',
        day5 => 'Day 5 Follow-Up',
        day10 => 'Day 10 Follow-Up',
        _ => key,
      };

  static int dayNumber(String key) => switch (key) {
        day2 => 2,
        day5 => 5,
        day10 => 10,
        _ => 0,
      };
}

const _uuid = Uuid();

// ── Screen ────────────────────────────────────────────────────────────────────

class FollowupSettingsScreen extends ConsumerStatefulWidget {
  const FollowupSettingsScreen({super.key});

  @override
  ConsumerState<FollowupSettingsScreen> createState() =>
      _FollowupSettingsScreenState();
}

class _FollowupSettingsScreenState
    extends ConsumerState<FollowupSettingsScreen> {
  /// One controller per template key, keyed by templateKey.
  final Map<String, TextEditingController> _controllers = {};

  /// The last-loaded smsBody per key — used to detect unsaved changes.
  final Map<String, String> _savedValues = {};

  /// Track which keys are currently saving.
  final Set<String> _saving = {};

  String? _orgId;
  bool _defaultsSeeded = false;

  @override
  void initState() {
    super.initState();
    // Seed controllers with empty strings; real values arrive from the stream.
    for (final key in FollowUpTemplateKeys.ordered) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _populateControllers(List<LocalMessageTemplate> templates) {
    String? templateBodyFor(String key) {
      final canonical =
          templates.where((t) => t.templateKey == key).firstOrNull;
      if (canonical != null) {
        return canonical.smsBody;
      }
      // Backward compatibility with old local keys.
      final legacyKey = switch (key) {
        FollowUpTemplateKeys.day2 => 'followup_day_2',
        FollowUpTemplateKeys.day5 => 'followup_day_5',
        FollowUpTemplateKeys.day10 => 'followup_day_10',
        _ => null,
      };
      final legacy = legacyKey == null
          ? null
          : templates.where((t) => t.templateKey == legacyKey).firstOrNull;
      return legacy?.smsBody;
    }

    for (final key in FollowUpTemplateKeys.ordered) {
      final body = templateBodyFor(key);
      if (body == null) {
        continue;
      }

      final controller = _controllers[key]!;
      final previousSaved = _savedValues[key];
      final hasUnsavedEdits =
          previousSaved != null && controller.text != previousSaved;

      if (previousSaved == null || !hasUnsavedEdits) {
        _savedValues[key] = body;
        controller.text = body;
      }
    }
  }

  Future<void> _seedDefaults(String orgId) async {
    if (_defaultsSeeded) return;
    _defaultsSeeded = true;

    final dao = ref.read(templatesDaoProvider);
    for (final key in FollowUpTemplateKeys.ordered) {
      await dao.upsertDefaultTemplate(
        id: _uuid.v5(Namespace.url.value, 'crewcommand/$orgId/$key'),
        orgId: orgId,
        templateKey: key,
        smsBody: FollowUpTemplateKeys.defaultMessages[key]!,
      );
    }
  }

  Future<void> _saveTemplate(
    String templateId,
    String key,
    String smsBody,
  ) async {
    setState(() => _saving.add(key));
    try {
      await ref.read(templatesDaoProvider).updateTemplate(
            id: templateId,
            smsBody: smsBody.trim(),
          );
      _savedValues[key] = smsBody.trim();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${FollowUpTemplateKeys.dayLabel(key)} saved.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    _orgId = authAsync.valueOrNull?.profile?.organizationId;

    if (_orgId == null || _orgId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Follow-Up Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final orgId = _orgId!;

    // Seed defaults once we have an orgId.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _seedDefaults(orgId);
    });

    final templatesAsync = ref.watch(activeTemplatesProvider(orgId));

    return Scaffold(
      appBar: AppBar(title: const Text('Follow-Up Settings')),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (templates) {
          _populateControllers(templates);
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // ── Info card ──────────────────────────────────────────
              Card(
                color: AppTokens.glass,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'How Follow-Ups Work',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'When you mark an estimate as sent, messages are automatically scheduled at Day 2, 5, and 10. '
                        'Use the tokens below to personalize each message.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Token chips ────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _TokenChip(label: '{client_name}'),
                    _TokenChip(label: '{job_type}'),
                    _TokenChip(label: '{contractor_name}'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Template cards ─────────────────────────────────────
              for (final key in FollowUpTemplateKeys.ordered) ...[
                _TemplateCard(
                  templateKey: key,
                  template:
                      templates.where((t) => t.templateKey == key).firstOrNull,
                  controller: _controllers[key]!,
                  savedValue: _savedValues[key] ?? '',
                  isSaving: _saving.contains(key),
                  onSave: (templateId, body) =>
                      _saveTemplate(templateId, key, body),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Template card ─────────────────────────────────────────────────────────────

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({
    required this.templateKey,
    required this.template,
    required this.controller,
    required this.savedValue,
    required this.isSaving,
    required this.onSave,
  });

  final String templateKey;
  final LocalMessageTemplate? template;
  final TextEditingController controller;
  final String savedValue;
  final bool isSaving;
  final void Function(String templateId, String body) onSave;

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  bool get _hasUnsavedChanges =>
      widget.template != null &&
      widget.controller.text.trim() != widget.savedValue.trim() &&
      widget.controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = FollowUpTemplateKeys.dayNumber(widget.templateKey);
    final label = FollowUpTemplateKeys.dayLabel(widget.templateKey);
    final template = widget.template;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      'D$day',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(label, style: theme.textTheme.titleSmall),
                const Spacer(),
                Icon(Icons.message_outlined,
                    size: 18, color: theme.colorScheme.outline),
              ],
            ),

            const SizedBox(height: 12),

            if (template == null)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else ...[
              TextField(
                controller: widget.controller,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter your Day $day message...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: widget.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : FilledButton(
                        onPressed: _hasUnsavedChanges
                            ? () => widget.onSave(
                                  template.id,
                                  widget.controller.text,
                                )
                            : null,
                        child: const Text('Save'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Token chip ────────────────────────────────────────────────────────────────

class _TokenChip extends StatelessWidget {
  const _TokenChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontFamily: 'monospace')),
      backgroundColor: AppTokens.glassElevated,
      side: const BorderSide(color: AppTokens.glassBorder),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
