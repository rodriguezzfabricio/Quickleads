import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/lead_status_mapper.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/glass_card.dart';

const _statusOptions = [
  (LeadStatusMapper.callbackDb, 'New / Call Back'),
  (LeadStatusMapper.wonDb, 'Won'),
  (LeadStatusMapper.coldDb, 'Cold'),
];

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, this.leadId});

  final String? leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (leadId == null || leadId!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No lead ID provided.')),
      );
    }

    final leadAsync = ref.watch(_leadByIdProvider(leadId!));

    return leadAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (lead) {
        if (lead == null) {
          return const Scaffold(
            body: Center(child: Text('Lead not found or was deleted.')),
          );
        }
        return _LeadDetailBody(lead: lead);
      },
    );
  }
}

final _leadByIdProvider = StreamProvider.family<LocalLead?, String>((ref, id) {
  return ref.watch(leadsDaoProvider).watchLeadById(id);
});

class _LeadDetailBody extends ConsumerStatefulWidget {
  const _LeadDetailBody({required this.lead});

  final LocalLead lead;

  @override
  ConsumerState<_LeadDetailBody> createState() => _LeadDetailBodyState();
}

class _LeadDetailBodyState extends ConsumerState<_LeadDetailBody> {
  late String _pendingStatus;
  bool _updatingStatus = false;
  bool _busyAction = false;

  bool _isEditing = false;
  bool _showDetails = false;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _pendingStatus = LeadStatusMapper.canonicalize(widget.lead.status);
    _nameController = TextEditingController(text: widget.lead.clientName);
    _phoneController = TextEditingController(text: widget.lead.phoneE164 ?? '');
    _emailController = TextEditingController(text: widget.lead.email ?? '');
    _addressController = TextEditingController(text: '');
    _notesController = TextEditingController(text: widget.lead.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant _LeadDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lead.status != oldWidget.lead.status && !_updatingStatus) {
      _pendingStatus = LeadStatusMapper.canonicalize(widget.lead.status);
    }
    if (!_isEditing && widget.lead.clientName != oldWidget.lead.clientName) {
      _nameController.text = widget.lead.clientName;
    }
    if (!_isEditing && widget.lead.phoneE164 != oldWidget.lead.phoneE164) {
      _phoneController.text = widget.lead.phoneE164 ?? '';
    }
    if (!_isEditing && widget.lead.notes != oldWidget.lead.notes) {
      _notesController.text = widget.lead.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _callNow() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    await launchUrl(Uri.parse('tel:$phone'));
  }

  Future<void> _sendText() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    await launchUrl(Uri.parse('sms:$phone'));
  }

  Future<void> _changeStatus(String newStatus) async {
    final normalized = LeadStatusMapper.canonicalize(newStatus);
    final current = LeadStatusMapper.canonicalize(widget.lead.status);
    if (normalized == current || _updatingStatus) return;

    if (normalized == LeadStatusMapper.coldDb) {
      final confirmed = await _confirmAction(
        title: 'Mark ${widget.lead.clientName} as cold?',
        description: 'Follow-ups will stop.',
        confirmLabel: 'Confirm',
      );
      if (!confirmed) return;
    }

    if (normalized == LeadStatusMapper.wonDb) {
      await _markAsWon();
      return;
    }

    setState(() {
      _pendingStatus = normalized;
      _updatingStatus = true;
    });

    try {
      await ref.read(leadsDaoProvider).updateLeadStatus(
            widget.lead.id,
            normalized,
            widget.lead.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update lead status: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  Future<void> _markEstimateSent() async {
    if (_busyAction) return;

    final confirmed = await _confirmAction(
      title: 'Start automatic follow-ups?',
      description: 'Start automatic follow-ups for ${widget.lead.clientName}?',
      confirmLabel: 'Yes',
      confirmColor: AppColors.systemYellow,
      confirmTextColor: Colors.black,
    );
    if (!confirmed) return;

    setState(() => _busyAction = true);
    try {
      await ref.read(leadActionsServiceProvider).markEstimateSent(widget.lead);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not mark estimate sent: $error')),
      );
    } finally {
      if (mounted) setState(() => _busyAction = false);
    }
  }

  Future<void> _markAsWon() async {
    if (_busyAction) return;

    setState(() {
      _busyAction = true;
      _updatingStatus = true;
    });

    try {
      await ref.read(leadsDaoProvider).updateLeadStatus(
            widget.lead.id,
            LeadStatusMapper.wonDb,
            widget.lead.version,
          );
      await ref.read(leadsDaoProvider).updateFollowupState(
            widget.lead.id,
            'stopped',
            widget.lead.version + 1,
          );
      if (!mounted) return;
      await _showWonCelebration();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not mark as won: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyAction = false;
          _updatingStatus = false;
        });
      }
    }
  }

  Future<void> _updateFollowupState(String nextState) async {
    if (_busyAction) return;

    final prompt = switch (nextState) {
      'paused' => ('Pause follow-ups?', 'You can resume anytime.', 'Pause'),
      'stopped' => (
          'Stop follow-ups?',
          'This will stop all scheduled follow-ups for this lead.',
          'Stop'
        ),
      _ => ('Update follow-ups?', 'Continue?', 'Confirm'),
    };

    final confirmed = await _confirmAction(
      title: prompt.$1,
      description: prompt.$2,
      confirmLabel: prompt.$3,
      confirmColor:
          nextState == 'stopped' ? AppColors.systemRed : AppColors.systemBlue,
    );
    if (!confirmed) return;

    setState(() => _busyAction = true);
    try {
      await ref.read(leadActionsServiceProvider).updateFollowupState(
            lead: widget.lead,
            nextState: nextState,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update follow-ups: $error')),
      );
    } finally {
      if (mounted) setState(() => _busyAction = false);
    }
  }

  Future<void> _deleteLead() async {
    if (_busyAction) return;

    final confirmed = await _confirmAction(
      title: 'Delete ${widget.lead.clientName} from your leads?',
      description: 'This can\'t be undone.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.systemRed,
    );
    if (!confirmed) return;

    setState(() => _busyAction = true);
    try {
      await ref.read(leadsDaoProvider).softDeleteLead(
            widget.lead.id,
            widget.lead.version,
          );
      if (!mounted) return;
      context.go(AppRoutes.leads);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete lead: $error')),
      );
      setState(() => _busyAction = false);
    }
  }

  Future<void> _openProjectCreation() async {
    final query = <String, String>{
      'leadId': widget.lead.id,
      'name': _nameController.text.trim(),
      'jobType': widget.lead.jobType,
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
    };
    final uri = Uri(path: AppRoutes.projectCreate, queryParameters: query);
    if (!mounted) return;
    context.push(uri.toString());
  }

  Future<bool> _confirmAction({
    required String title,
    required String description,
    required String confirmLabel,
    Color confirmColor = AppColors.systemBlue,
    Color confirmTextColor = Colors.white,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h2.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(description, style: AppTextStyles.secondary),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: confirmTextColor,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: AppTextStyles.h4.copyWith(
                            fontSize: 15,
                            color: confirmTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: AppColors.glassBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.h4.copyWith(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result == true;
  }

  Future<void> _showWonCelebration() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 36,
                    color: AppColors.systemGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Job Won! 🎉',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_nameController.text} — ${widget.lead.jobType}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.secondary,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _openProjectCreation();
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Set Up Project →'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.leads);
                    },
                    child: Text(
                      "I'll do this later",
                      style: AppTextStyles.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final canonicalStatus = LeadStatusMapper.canonicalize(lead.status);
    final dateFormat = DateFormat('MMM d, yyyy');
    final followupSequenceAsync =
        ref.watch(followupSequenceByLeadProvider(lead.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go(AppRoutes.leads),
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.foreground, size: 24),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  child: Text(
                    _isEditing ? 'Done' : 'Edit',
                    style: AppTextStyles.secondary
                        .copyWith(color: AppColors.systemBlue),
                  ),
                ),
              ],
            ),
            if (_isEditing)
              TextField(
                controller: _nameController,
                style: AppTextStyles.h1,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors.systemBlue.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors.systemBlue.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors.systemBlue.withValues(alpha: 0.5)),
                  ),
                ),
              )
            else
              Text(_nameController.text, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            GlassCard(
              child: _isEditing
                  ? TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        hintText: 'Phone number',
                        hintStyle: AppTextStyles.body
                            .copyWith(color: AppColors.mutedFg),
                      ),
                    )
                  : InkWell(
                      onTap: _callNow,
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              color: AppColors.systemBlue, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _phoneController.text,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.work_outline,
                          size: 16, color: AppColors.systemBlue),
                      const SizedBox(width: 8),
                      Text('PREVIOUS PROJECTS',
                          style: AppTextStyles.sectionLabel),
                      const Spacer(),
                      Text('0', style: AppTextStyles.badge),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 36,
                          color: AppColors.mutedFg.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No Project History',
                          style: AppTextStyles.secondary.copyWith(
                            fontSize: 17,
                            color: AppColors.mutedFg,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'When you complete jobs for this lead, they\'ll show up here.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.tiny.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _openProjectCreation,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A84FF), Color(0xFF34C759)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'New Project',
                      style: AppTextStyles.buttonPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text('Job Type',
                            style: AppTextStyles.tiny.copyWith(fontSize: 13)),
                        const Spacer(),
                        Text(
                          lead.jobType,
                          style: AppTextStyles.secondary.copyWith(
                            fontSize: 15,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text('Status',
                            style: AppTextStyles.tiny.copyWith(fontSize: 13)),
                        const Spacer(),
                        if (_updatingStatus)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (canonicalStatus == LeadStatusMapper.estimateDb)
                          Text(
                            'Estimate Sent',
                            style: AppTextStyles.secondary.copyWith(
                              fontSize: 15,
                              color: AppColors.systemOrange,
                            ),
                          )
                        else
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _pendingStatus,
                              dropdownColor: AppColors.background,
                              style: AppTextStyles.secondary.copyWith(
                                fontSize: 15,
                                color: AppColors.foreground,
                              ),
                              items: _statusOptions
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option.$1,
                                      child: Text(option.$2),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                _changeStatus(value);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (lead.followupState != 'none') ...[
              const SizedBox(height: 10),
              followupSequenceAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
                error: (error, _) => GlassCard(
                  child: Text('Could not load follow-up timeline: $error'),
                ),
                data: (sequence) {
                  if (sequence == null) {
                    return GlassCard(
                      child: Text(
                        'Follow-up sequence not found yet. Sync may still be in progress.',
                        style: AppTextStyles.secondary,
                      ),
                    );
                  }

                  final messagesAsync = ref
                      .watch(followupMessagesBySequenceProvider(sequence.id));

                  return GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Follow-up Active',
                              style: AppTextStyles.h4.copyWith(
                                fontSize: 15,
                                color: AppColors.systemBlue,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _busyAction
                                  ? null
                                  : () => _updateFollowupState('paused'),
                              child: Text(
                                'Pause',
                                style: AppTextStyles.secondary.copyWith(
                                  fontSize: 15,
                                  color: AppColors.systemBlue,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _busyAction
                                  ? null
                                  : () => _updateFollowupState('stopped'),
                              child: Text(
                                'Stop',
                                style: AppTextStyles.secondary.copyWith(
                                  fontSize: 15,
                                  color: AppColors.systemRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        messagesAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          error: (error, _) => Text(
                            'Could not load follow-up messages: $error',
                            style: AppTextStyles.tiny
                                .copyWith(color: AppColors.systemRed),
                          ),
                          data: (messages) {
                            final timeline = <({int day, bool sent})>[];
                            for (final day in const [2, 5, 10]) {
                              final stepMessage = messages
                                  .where((m) => m.stepNumber == day)
                                  .firstOrNull;
                              timeline.add((
                                day: day,
                                sent:
                                    stepMessage?.status.toLowerCase() == 'sent',
                              ));
                            }

                            return Column(
                              children: timeline
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            item.sent
                                                ? Icons.check_circle
                                                : Icons.schedule,
                                            size: 14,
                                            color: item.sent
                                                ? AppColors.systemGreen
                                                : AppColors.mutedFg,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Day ${item.day} ${item.sent ? '✓ Sent' : '⏳ Scheduled'}',
                                            style: AppTextStyles.secondary
                                                .copyWith(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _showDetails = !_showDetails),
                    child: Row(
                      children: [
                        Text(
                          'Details',
                          style: AppTextStyles.h3.copyWith(fontSize: 17),
                        ),
                        const Spacer(),
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.mutedFg,
                        ),
                      ],
                    ),
                  ),
                  if (_showDetails) ...[
                    const SizedBox(height: 10),
                    _DetailField(
                      controller: _emailController,
                      label: 'Email',
                    ),
                    const SizedBox(height: 8),
                    _DetailField(
                      controller: _addressController,
                      label: 'Address',
                    ),
                    const SizedBox(height: 8),
                    _DetailField(
                      controller: _notesController,
                      label: 'Notes',
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _callNow,
              icon: const Icon(Icons.phone_outlined),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              label: const Text('Call Now'),
            ),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 16,
              color: AppColors.glassProminent,
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _sendText,
                  icon: const Icon(Icons.message_outlined,
                      color: AppColors.foreground),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: AppColors.foreground,
                  ),
                  label: Text(
                    'Send Text',
                    style: AppTextStyles.h3.copyWith(fontSize: 17),
                  ),
                ),
              ),
            ),
            if (canonicalStatus == LeadStatusMapper.callbackDb) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busyAction ? null : _markEstimateSent,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.systemYellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _busyAction
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        'Estimate Sent?',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
              ),
            ],
            if (canonicalStatus == LeadStatusMapper.estimateDb) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busyAction ? null : _markAsWon,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.systemGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Mark as Won'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busyAction
                  ? null
                  : () => _changeStatus(LeadStatusMapper.coldDb),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.glassBorder),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Mark as Cold',
                style: AppTextStyles.secondary.copyWith(
                  color: AppColors.mutedFg,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busyAction ? null : _deleteLead,
              icon: const Icon(Icons.delete_outline, size: 16),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.systemRed,
                side: BorderSide(
                    color: AppColors.systemRed.withValues(alpha: 0.3)),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              label: Text(
                'Delete Lead',
                style: AppTextStyles.h4.copyWith(
                  fontSize: 15,
                  color: AppColors.systemRed,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Created ${dateFormat.format(lead.createdAt.toLocal())}',
              style: AppTextStyles.tiny.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.sectionLabel),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedFg),
            filled: false,
            border: InputBorder.none,
            isCollapsed: true,
          ),
        ),
      ],
    );
  }
}
