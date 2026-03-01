import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/domain/job_health_status.dart';
import '../../core/domain/job_phase.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../auth/providers/auth_provider.dart';

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
    if (!_canSave) {
      return;
    }

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

      if (!mounted) {
        return;
      }
      context.go(AppRoutes.jobs);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save project: $error')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final leadsAsync = ref.watch(allLeadsProvider(orgId));

    return Scaffold(
      body: SafeArea(
        child: leadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading leads: $error'),
          ),
          data: (leads) {
            if (!_didAutoHydrateLead && _linkedLeadId != null) {
              LocalLead? linkedLead;
              for (final lead in leads) {
                if (lead.id == _linkedLeadId) {
                  linkedLead = lead;
                  break;
                }
              }
              _didAutoHydrateLead = true;
              if (linkedLead != null &&
                  _clientNameController.text.trim().isEmpty &&
                  _jobTypeController.text.trim().isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _linkLead(linkedLead!);
                  }
                });
              }
            }

            final query = _leadSearchController.text.trim().toLowerCase();
            final matchingLeads = leads
                .where(
                  (lead) => lead.clientName.toLowerCase().contains(query),
                )
                .take(5)
                .toList();

            final completionLabel = _estimatedCompletion == null
                ? 'Select estimated completion date'
                : DateFormat.yMMMMd().format(_estimatedCompletion!);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 6),
                    Text('New Project', style: theme.textTheme.headlineMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Create a job and start tracking progress.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 20),
                Text(
                  'Link to Existing Lead (optional)',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _leadSearchController,
                  onTap: () => setState(() => _showLeadSearchResults = true),
                  onChanged: (_) {
                    setState(() {
                      _showLeadSearchResults = true;
                      _linkedLeadId = null;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search lead by name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_showLeadSearchResults && matchingLeads.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTokens.glassBorder),
                      color: AppTokens.glassElevated,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: matchingLeads.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final lead = matchingLeads[index];
                        return ListTile(
                          onTap: () => _linkLead(lead),
                          leading: const Icon(Icons.link_outlined),
                          title: Text(lead.clientName),
                          subtitle: Text(
                              '${lead.phoneE164 ?? 'No phone'} · ${lead.jobType}'),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                TextField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jobTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Job Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickEstimatedCompletion,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(completionLabel),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<JobPhase>(
                  initialValue: _phase,
                  decoration: const InputDecoration(
                    labelText: 'Starting Phase',
                    border: OutlineInputBorder(),
                  ),
                  items: JobPhase.orderedValues
                      .map(
                        (phase) => DropdownMenuItem<JobPhase>(
                          value: phase,
                          child: Text(phase.displayLabel),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _phase = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<JobHealthStatus>(
                  initialValue: _healthStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: JobHealthStatus.values
                      .map(
                        (status) => DropdownMenuItem<JobHealthStatus>(
                          value: status,
                          child: Text(status.displayLabel),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _healthStatus = value);
                  },
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _canSave ? () => _saveProject(orgId) : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
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
