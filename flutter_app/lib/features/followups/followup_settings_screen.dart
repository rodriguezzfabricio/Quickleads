import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/glass_card.dart';
import '../auth/providers/auth_provider.dart';

abstract final class FollowUpTemplateKeys {
  static const day2 = 'day_2_followup';
  static const day5 = 'day_5_followup';
  static const day10 = 'day_10_followup';
  static const estimateQuickSend = 'estimate_quick_send';

  static const ordered = [day2, day5, day10];

  static const defaultMessages = {
    day2:
        'Hi {client_name}, just wanted to follow up on the estimate I sent for your {job_type}. Any questions? — {contractor_name}',
    day5:
        'Hey {client_name}, checking in on the {job_type} estimate. Still interested? Happy to adjust if needed. — {contractor_name}',
    day10:
        'Hi {client_name}, last follow-up on the {job_type} estimate. Let me know if you\'d like to move forward. — {contractor_name}',
    estimateQuickSend:
        'Hi {client_name}, here\'s my estimate for your {job_type}: {amount}. Let me know if you\'d like to proceed! — {contractor_name}, {business_name}',
  };

  static int dayNumber(String key) => switch (key) {
        day2 => 2,
        day5 => 5,
        day10 => 10,
        _ => 0,
      };
}

const _uuid = Uuid();

class FollowupSettingsScreen extends ConsumerStatefulWidget {
  const FollowupSettingsScreen({super.key});

  @override
  ConsumerState<FollowupSettingsScreen> createState() =>
      _FollowupSettingsScreenState();
}

class _FollowupSettingsScreenState
    extends ConsumerState<FollowupSettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _savedValues = {};
  final Set<String> _saving = {};

  String? _orgId;
  bool _defaultsSeeded = false;
  bool _autoFollowup = true;
  String _sendVia = 'sms';
  int? _editingDay;

  @override
  void initState() {
    super.initState();
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
      if (canonical != null) return canonical.smsBody;
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
      if (body == null) continue;

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
    await dao.upsertDefaultTemplate(
      id: _uuid.v5(
        Namespace.url.value,
        'crewcommand/$orgId/${FollowUpTemplateKeys.estimateQuickSend}',
      ),
      orgId: orgId,
      templateKey: FollowUpTemplateKeys.estimateQuickSend,
      smsBody: FollowUpTemplateKeys
          .defaultMessages[FollowUpTemplateKeys.estimateQuickSend]!,
    );
  }

  Future<void> _saveTemplate(
      String templateId, String key, String smsBody) async {
    setState(() => _saving.add(key));
    try {
      await ref.read(templatesDaoProvider).updateTemplate(
            id: templateId,
            smsBody: smsBody.trim(),
          );
      _savedValues[key] = smsBody.trim();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving.remove(key));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    _orgId = authAsync.valueOrNull?.profile?.organizationId;

    if (_orgId == null || _orgId!.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final orgId = _orgId!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _seedDefaults(orgId);
    });

    final templatesAsync = ref.watch(activeTemplatesProvider(orgId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (templates) {
            _populateControllers(templates);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.foreground,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text('Follow-up', style: AppTextStyles.h1),
                  ],
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Follow-up',
                              style: AppTextStyles.h3.copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Send follow-ups automatically',
                              style: AppTextStyles.secondary,
                            ),
                          ],
                        ),
                      ),
                      _IosToggle(
                        value: _autoFollowup,
                        onChanged: (value) {
                          setState(() => _autoFollowup = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('SEND VIA', style: AppTextStyles.sectionLabel),
                const SizedBox(height: 8),
                _MethodSegmented(
                  value: _sendVia,
                  onChanged: (value) => setState(() => _sendVia = value),
                ),
                const SizedBox(height: 16),
                Text('TEMPLATES', style: AppTextStyles.sectionLabel),
                const SizedBox(height: 8),
                for (final key in FollowUpTemplateKeys.ordered) ...[
                  _TemplateCard(
                    templateKey: key,
                    template: templates
                        .where((t) => t.templateKey == key)
                        .firstOrNull,
                    controller: _controllers[key]!,
                    savedValue: _savedValues[key] ?? '',
                    isSaving: _saving.contains(key),
                    isEditing:
                        _editingDay == FollowUpTemplateKeys.dayNumber(key),
                    onToggleEdit: () {
                      final day = FollowUpTemplateKeys.dayNumber(key);
                      setState(
                          () => _editingDay = _editingDay == day ? null : day);
                    },
                    onSave: (templateId, body) =>
                        _saveTemplate(templateId, key, body),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 6),
                GlassCard(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Note: ',
                          style: AppTextStyles.tiny.copyWith(
                            fontSize: 13,
                            color: AppColors.systemBlue,
                          ),
                        ),
                        TextSpan(
                          text: 'Messages sent 9 AM – 6 PM only',
                          style: AppTextStyles.tiny.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MethodSegmented extends StatelessWidget {
  const _MethodSegmented({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const methods = [('sms', 'SMS'), ('email', 'Email'), ('both', 'Both')];

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.glassElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          for (final method in methods)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(method.$1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: value == method.$1
                        ? AppColors.glassProminent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    method.$2,
                    style: AppTextStyles.label.copyWith(
                      letterSpacing: 0,
                      fontSize: 13,
                      color: value == method.$1
                          ? AppColors.foreground
                          : AppColors.mutedFg,
                      fontWeight: value == method.$1
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.templateKey,
    required this.template,
    required this.controller,
    required this.savedValue,
    required this.isSaving,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onSave,
  });

  final String templateKey;
  final LocalMessageTemplate? template;
  final TextEditingController controller;
  final String savedValue;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final void Function(String templateId, String body) onSave;

  @override
  Widget build(BuildContext context) {
    final day = FollowUpTemplateKeys.dayNumber(templateKey);
    final hasUnsaved =
        template != null && controller.text.trim() != savedValue.trim();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Day $day',
                style: AppTextStyles.h4.copyWith(
                  fontSize: 15,
                  color: AppColors.systemBlue,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onToggleEdit,
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: Text(
                  'Edit',
                  style: AppTextStyles.tiny.copyWith(
                    fontSize: 13,
                    color: AppColors.systemBlue,
                  ),
                ),
              ),
            ],
          ),
          if (template == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isEditing) ...[
            GlassCard(
              borderRadius: 12,
              color: AppColors.glassBase,
              child: Focus(
                onFocusChange: (focused) {
                  if (!focused && hasUnsaved) {
                    onSave(template!.id, controller.text);
                  }
                },
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  style: AppTextStyles.secondary.copyWith(
                    fontSize: 15,
                    color: AppColors.foreground.withValues(alpha: 0.8),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Template text',
                    hintStyle: AppTextStyles.secondary,
                    filled: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: hasUnsaved
                          ? () => onSave(template!.id, controller.text)
                          : null,
                      child: Text(
                        'Save',
                        style: AppTextStyles.tiny.copyWith(
                          fontSize: 13,
                          color: AppColors.systemBlue,
                        ),
                      ),
                    ),
            ),
          ] else
            Text(
              controller.text,
              style: AppTextStyles.secondary.copyWith(
                fontSize: 15,
                color: AppColors.foreground.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _IosToggle extends StatelessWidget {
  const _IosToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          color: value ? AppColors.systemGreen : const Color(0x52787880),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 27,
                height: 27,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
