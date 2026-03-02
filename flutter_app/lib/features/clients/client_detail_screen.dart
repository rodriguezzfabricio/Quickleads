import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

const _uuid = Uuid();

const _jobTypes = [
  'Deck',
  'Kitchen',
  'Bathroom',
  'Roof',
  'Fence',
  'Basement',
  'Addition',
  'Painting',
  'Concrete',
  'Other',
];

class ClientDetailScreen extends ConsumerStatefulWidget {
  const ClientDetailScreen({
    super.key,
    this.clientId,
    this.isCreateFlow = false,
    this.prefillName,
    this.prefillPhone,
    this.prefillLeadId,
  });

  final String? clientId;
  final bool isCreateFlow;
  final String? prefillName;
  final String? prefillPhone;
  final String? prefillLeadId;

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _hydratedExisting = false;
  bool _saving = false;

  final List<_ProjectDraft> _draftProjects = [];
  bool _addingProject = false;
  String _draftJobType = '';
  DateTime? _draftDate;
  final TextEditingController _draftNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefillName ?? '');
    _phoneController = TextEditingController(text: widget.prefillPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _draftNotesController.dispose();
    super.dispose();
  }

  bool get _canSave {
    return _nameController.text.trim().isNotEmpty && !_saving;
  }

  Future<void> _saveClient({
    required String orgId,
    required LocalClient? existing,
  }) async {
    if (!_canSave) {
      return;
    }

    setState(() => _saving = true);

    try {
      final dao = ref.read(clientsDaoProvider);
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final address = _addressController.text.trim();
      final notes = _notesController.text.trim();

      if (existing == null) {
        await dao.createClient(
          LocalClientsCompanion.insert(
            id: _uuid.v4(),
            organizationId: orgId,
            name: name,
            phone: Value(phone.isEmpty ? null : phone),
            email: Value(email.isEmpty ? null : email),
            address: Value(address.isEmpty ? null : address),
            notes: Value(notes.isEmpty ? null : notes),
            sourceLeadId: Value(widget.prefillLeadId),
            projectCount: Value(_draftProjects.length),
          ),
        );
      } else {
        await dao.updateClient(
          id: existing.id,
          name: name,
          phone: phone.isEmpty ? null : phone,
          email: email.isEmpty ? null : email,
          address: address.isEmpty ? null : address,
          notes: notes.isEmpty ? null : notes,
          sourceLeadId: existing.sourceLeadId,
          projectCount: existing.projectCount,
          currentVersion: existing.version,
        );
      }

      if (!mounted) return;
      context.go(AppRoutes.clients);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save client: $error')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider).valueOrNull;
    final orgId = auth?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.isCreateFlow) {
      return _buildScaffold(
        orgId: orgId,
        existing: null,
        history: const [],
      );
    }

    final clientId = widget.clientId;
    if (clientId == null || clientId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Client not found', style: AppTextStyles.secondary),
        ),
      );
    }

    final clientAsync = ref.watch(clientByIdProvider(clientId));
    return clientAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (client) {
        if (client == null || client.deletedAt != null) {
          return Scaffold(
            body: Center(
              child: Text('Client not found', style: AppTextStyles.secondary),
            ),
          );
        }

        if (!_hydratedExisting) {
          _hydratedExisting = true;
          _nameController.text = client.name;
          _phoneController.text = client.phone ?? '';
          _emailController.text = client.email ?? '';
          _addressController.text = client.address ?? '';
          _notesController.text = client.notes ?? '';
        }

        final jobs = ref.watch(jobsByOrgProvider(orgId)).valueOrNull ??
            const <LocalJob>[];
        final history = jobs.where((job) {
          if (job.deletedAt != null) return false;
          if (client.sourceLeadId != null && client.sourceLeadId!.isNotEmpty) {
            return job.leadId == client.sourceLeadId;
          }
          return job.clientName.trim().toLowerCase() ==
              client.name.trim().toLowerCase();
        }).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return _buildScaffold(
          orgId: orgId,
          existing: client,
          history: history,
        );
      },
    );
  }

  Widget _buildScaffold({
    required String orgId,
    required LocalClient? existing,
    required List<LocalJob> history,
  }) {
    final title = existing != null
        ? existing.name
        : widget.prefillLeadId != null
            ? 'Convert to Client'
            : 'New Client';
    final subtitle = existing != null
        ? null
        : widget.prefillName != null && widget.prefillName!.isNotEmpty
            ? 'from lead: ${widget.prefillName!}'
            : 'Add an existing client manually';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.foreground, size: 24),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(title,
                      style: AppTextStyles.h1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.secondary),
            ],
            const SizedBox(height: 16),
            _FieldCard(
              controller: _nameController,
              hint: 'Name',
            ),
            const SizedBox(height: 10),
            _FieldCard(
              controller: _phoneController,
              hint: 'Phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _FieldCard(
              controller: _emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _FieldCard(
              controller: _addressController,
              hint: 'Address',
            ),
            const SizedBox(height: 10),
            _FieldCard(
              controller: _notesController,
              hint: 'Notes',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('PREVIOUS PROJECTS', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            for (final job in history)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.jobType,
                                style: AppTextStyles.h4.copyWith(fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM d, yyyy')
                                  .format(job.updatedAt.toLocal()),
                              style: AppTextStyles.tiny.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push(
                          AppRoutes.jobDetail.replaceFirst(':jobId', job.id),
                        ),
                        icon: const Icon(Icons.chevron_right,
                            color: AppColors.mutedFg),
                      ),
                    ],
                  ),
                ),
              ),
            for (var i = 0; i < _draftProjects.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _draftProjects[i].jobType,
                          style: AppTextStyles.h4.copyWith(fontSize: 15),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _draftProjects.removeAt(i));
                        },
                        icon: const Icon(Icons.close,
                            color: AppColors.mutedFg, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            if (_addingProject) ...[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in _jobTypes)
                          GestureDetector(
                            onTap: () => setState(() => _draftJobType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _draftJobType == type
                                    ? AppColors.systemBlue
                                    : AppColors.glassProminent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                type,
                                style: AppTextStyles.label.copyWith(
                                  letterSpacing: 0,
                                  color: _draftJobType == type
                                      ? Colors.white
                                      : AppColors.foreground,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _draftDate ?? now,
                          firstDate: DateTime(now.year - 10),
                          lastDate: DateTime(now.year + 10),
                        );
                        if (picked != null) {
                          setState(() => _draftDate = picked);
                        }
                      },
                      child: Text(
                        _draftDate == null
                            ? 'Select date'
                            : DateFormat('MMM d, yyyy').format(_draftDate!),
                        style: AppTextStyles.h4.copyWith(fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _draftNotesController,
                      decoration: InputDecoration(
                        hintText: 'Project notes',
                        hintStyle: AppTextStyles.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: (_draftJobType.isNotEmpty &&
                                    _draftDate != null)
                                ? () {
                                    setState(() {
                                      _draftProjects.add(
                                        _ProjectDraft(
                                          jobType: _draftJobType,
                                          date: _draftDate!,
                                          notes:
                                              _draftNotesController.text.trim(),
                                        ),
                                      );
                                      _addingProject = false;
                                      _draftJobType = '';
                                      _draftDate = null;
                                      _draftNotesController.clear();
                                    });
                                  }
                                : null,
                            child: const Text('Add'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _addingProject = false;
                                _draftJobType = '';
                                _draftDate = null;
                                _draftNotesController.clear();
                              });
                            },
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
            ] else ...[
              GestureDetector(
                onTap: () => setState(() => _addingProject = true),
                child: GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.add,
                          color: AppColors.systemBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Add Project',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 15,
                          color: AppColors.systemBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _canSave
                  ? () => _saveClient(orgId: orgId, existing: existing)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.systemBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                  : const Text('Save Client'),
            ),
          ],
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
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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

class _ProjectDraft {
  const _ProjectDraft({
    required this.jobType,
    required this.date,
    required this.notes,
  });

  final String jobType;
  final DateTime date;
  final String notes;
}
