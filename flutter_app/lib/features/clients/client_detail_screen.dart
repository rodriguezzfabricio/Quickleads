import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';

const _projectTypes = [
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

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({
    super.key,
    this.clientId,
    this.isCreateFlow = false,
    this.prefillName,
    this.prefillPhone,
  });

  final String? clientId;
  final bool isCreateFlow;
  final String? prefillName;
  final String? prefillPhone;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _addingProject = false;
  String? _draftJobType;
  DateTime? _draftCompletionDate;
  final TextEditingController _draftNotesController = TextEditingController();

  final List<_ProjectDraft> _projects = [];

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

  bool get _canSaveClient {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }

  bool get _canAddProject {
    return _draftJobType != null && _draftCompletionDate != null;
  }

  Future<void> _pickDraftDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draftCompletionDate ?? today,
      firstDate: DateTime(today.year - 20),
      lastDate: DateTime(today.year + 1),
    );

    if (picked != null && mounted) {
      setState(() => _draftCompletionDate = picked);
    }
  }

  void _addProjectDraft() {
    if (!_canAddProject) {
      return;
    }

    setState(() {
      _projects.add(
        _ProjectDraft(
          id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
          jobType: _draftJobType!,
          completedAt: _draftCompletionDate!,
          notes: _draftNotesController.text.trim(),
        ),
      );
      _addingProject = false;
      _draftJobType = null;
      _draftCompletionDate = null;
      _draftNotesController.clear();
    });
  }

  void _saveClient() {
    if (!_canSaveClient) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Client UI saved locally for this session. Persistent client storage is not wired yet.',
        ),
      ),
    );
    context.go(AppRoutes.clients);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!widget.isCreateFlow) {
      return Scaffold(
        appBar: AppBar(title: const Text('Client Detail')),
        body: Center(
          child: Text(
            widget.clientId == null
                ? 'Client not found.'
                : 'Client profile for ${widget.clientId} is not implemented yet.',
          ),
        ),
      );
    }

    final dateLabel = _draftCompletionDate == null
        ? 'Completion Date'
        : '${_draftCompletionDate!.month}/${_draftCompletionDate!.day}/${_draftCompletionDate!.year}';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.chevron_left),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.prefillName?.isNotEmpty == true
                        ? 'Convert to Client'
                        : 'New Client',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (widget.prefillName?.isNotEmpty == true)
              Text(
                'from lead: ${widget.prefillName}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Previous Projects',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),
            if (_projects.isNotEmpty)
              ..._projects.map(
                (project) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: AppTokens.glassElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTokens.glassBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppTokens.success, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(project.jobType),
                              Text(
                                '${project.completedAt.month}/${project.completedAt.day}/${project.completedAt.year}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              if (project.notes.isNotEmpty)
                                Text(
                                  project.notes,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _projects.removeWhere((p) => p.id == project.id);
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_addingProject) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTokens.glassElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTokens.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _projectTypes
                          .map(
                            (type) => ChoiceChip(
                              selected: _draftJobType == type,
                              label: Text(type),
                              onSelected: (_) {
                                setState(() => _draftJobType = type);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pickDraftDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(dateLabel),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _draftNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Project notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _canAddProject ? _addProjectDraft : null,
                            child: const Text('Add'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _addingProject = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (!_addingProject)
              OutlinedButton.icon(
                onPressed: () => setState(() => _addingProject = true),
                icon: const Icon(Icons.add),
                label: const Text('Add Previous Project'),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _canSaveClient ? _saveClient : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Save Client'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDraft {
  const _ProjectDraft({
    required this.id,
    required this.jobType,
    required this.completedAt,
    required this.notes,
  });

  final String id;
  final String jobType;
  final DateTime completedAt;
  final String notes;
}
