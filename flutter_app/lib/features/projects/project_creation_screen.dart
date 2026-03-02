import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/job_health_status.dart';
import '../../core/domain/job_phase.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

const _uuid = Uuid();

class ProjectCreationScreen extends ConsumerStatefulWidget {
  const ProjectCreationScreen({
    super.key,
    this.prefilledLeadId,
    this.prefillName,
    this.prefillPhone,
    this.prefillJobType,
  });

  final String? prefilledLeadId;
  final String? prefillName;
  final String? prefillPhone;
  final String? prefillJobType;

  @override
  ConsumerState<ProjectCreationScreen> createState() =>
      _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends ConsumerState<ProjectCreationScreen> {
  late final TextEditingController _leadSearchController;
  late final TextEditingController _clientNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTypeController;

  String? _linkedLeadId;
  bool _showLeadSearchResults = false;
  bool _didAutoHydrateLead = false;
  bool _saving = false;

  DateTime? _estimatedCompletion;
  JobPhase _phase = JobPhase.demo;
  JobHealthStatus _healthStatus = JobHealthStatus.onTrack;

  @override
  void initState() {
    super.initState();
    _linkedLeadId = widget.prefilledLeadId;
    _leadSearchController =
        TextEditingController(text: widget.prefillName ?? '');
    _clientNameController =
        TextEditingController(text: widget.prefillName ?? '');
    _phoneController = TextEditingController(text: widget.prefillPhone ?? '');
    _jobTypeController =
        TextEditingController(text: widget.prefillJobType ?? '');
  }

  @override
  void dispose() {
    _leadSearchController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _jobTypeController.dispose();
    super.dispose();
  }

  bool get _canSave {
    return _clientNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _jobTypeController.text.trim().isNotEmpty &&
        _estimatedCompletion != null &&
        !_saving;
  }

  Future<void> _pickEstimatedCompletion() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _estimatedCompletion ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => _estimatedCompletion = picked);
    }
  }

  void _linkLead(LocalLead lead) {
    setState(() {
      _linkedLeadId = lead.id;
      _leadSearchController.text = lead.clientName;
      _clientNameController.text = lead.clientName;
      _phoneController.text = lead.phoneE164 ?? '';
      _jobTypeController.text = lead.jobType;
      _showLeadSearchResults = false;
    });
  }

  Future<void> _saveProject(String orgId) async {
    if (!_canSave) return;

    setState(() => _saving = true);

    try {
      final selectedDate = _estimatedCompletion!;
      final normalizedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      final companion = LocalJobsCompanion.insert(
        id: _uuid.v4(),
        organizationId: orgId,
        leadId:
            _linkedLeadId != null ? Value(_linkedLeadId) : const Value.absent(),
        clientName: _clientNameController.text.trim(),
        jobType: _jobTypeController.text.trim(),
        phase: Value(_phase.dbValue),
        healthStatus: Value(_healthStatus.dbValue),
        estimatedCompletionDate: Value(normalizedDate),
      );

      await ref.read(jobsDaoProvider).createJob(companion);

      if (!mounted) return;
      context.go(AppRoutes.jobs);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save project: $error')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final leadsAsync = ref.watch(allLeadsProvider(orgId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: leadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading leads: $error'),
          ),
          data: (leads) {
            if (!_didAutoHydrateLead && _linkedLeadId != null) {
              final linkedLead =
                  leads.where((lead) => lead.id == _linkedLeadId).firstOrNull;
              _didAutoHydrateLead = true;
              if (linkedLead != null &&
                  _clientNameController.text.trim().isEmpty &&
                  _jobTypeController.text.trim().isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _linkLead(linkedLead);
                });
              }
            }

            final query = _leadSearchController.text.trim().toLowerCase();
            final matchingLeads = leads
                .where((lead) => lead.clientName.toLowerCase().contains(query))
                .take(5)
                .toList();

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
                    Text('New Project', style: AppTextStyles.h1),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a job and start tracking progress.',
                  style: AppTextStyles.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'LINK TO EXISTING LEAD (optional)',
                  style: AppTextStyles.sectionLabel,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 12,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      const Positioned(
                        left: 12,
                        child: Icon(
                          Icons.search,
                          size: 16,
                          color: AppColors.mutedFg,
                        ),
                      ),
                      TextField(
                        controller: _leadSearchController,
                        onTap: () =>
                            setState(() => _showLeadSearchResults = true),
                        onChanged: (_) {
                          setState(() {
                            _showLeadSearchResults = true;
                            _linkedLeadId = null;
                          });
                        },
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: 'Search lead by name',
                          hintStyle: AppTextStyles.body
                              .copyWith(color: AppColors.mutedFg),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(40, 12, 16, 12),
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showLeadSearchResults && matchingLeads.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    child: Column(
                      children: [
                        for (var i = 0; i < matchingLeads.length; i++) ...[
                          if (i > 0)
                            const Divider(
                                height: 1, color: AppColors.glassBorder),
                          InkWell(
                            onTap: () => _linkLead(matchingLeads[i]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link,
                                      size: 16, color: AppColors.systemBlue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          matchingLeads[i].clientName,
                                          style: AppTextStyles.h4.copyWith(
                                            fontSize: 15,
                                            color: AppColors.foreground,
                                          ),
                                        ),
                                        Text(
                                          '${matchingLeads[i].phoneE164 ?? 'No phone'} · ${matchingLeads[i].jobType}',
                                          style: AppTextStyles.tiny
                                              .copyWith(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _FieldCard(
                  controller: _clientNameController,
                  hint: 'Client Name',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                _FieldCard(
                  controller: _phoneController,
                  hint: 'Phone',
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                _FieldCard(
                  controller: _jobTypeController,
                  hint: 'Job Type',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                _PickerCard(
                  label: _estimatedCompletion == null
                      ? 'Est. Completion'
                      : DateFormat('MMM d, yyyy').format(_estimatedCompletion!),
                  onTap: _pickEstimatedCompletion,
                ),
                const SizedBox(height: 10),
                _DropdownCard<JobPhase>(
                  label: 'Starting Phase',
                  value: _phase,
                  items: JobPhase.orderedValues
                      .map((phase) => DropdownMenuItem(
                            value: phase,
                            child: Text(phase.displayLabel),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _phase = value);
                  },
                ),
                const SizedBox(height: 10),
                _DropdownCard<JobHealthStatus>(
                  label: 'Status',
                  value: _healthStatus,
                  items: JobHealthStatus.values
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayLabel),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _healthStatus = value);
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _canSave ? () => _saveProject(orgId) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.systemBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    disabledBackgroundColor:
                        AppColors.systemBlue.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: AppTextStyles.buttonPrimary,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Project'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedFg),
          border: InputBorder.none,
          isCollapsed: true,
          filled: false,
        ),
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Text(
          label,
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}

class _DropdownCard<T> extends StatelessWidget {
  const _DropdownCard({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.background,
          style: AppTextStyles.body,
          hint: Text(label, style: AppTextStyles.secondary),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
