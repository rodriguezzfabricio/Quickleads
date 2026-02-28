import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../features/auth/providers/auth_provider.dart';

const _uuid = Uuid();

// ── Job-type presets ──────────────────────────────────────────────────────────

const _kJobTypes = [
  'Kitchen Remodel',
  'Bathroom Remodel',
  'Roofing',
  'Flooring',
  'Painting',
  'HVAC',
  'Electrical',
  'Plumbing',
  'Landscaping',
  'Siding',
  'Windows & Doors',
  'Deck / Patio',
  'Garage',
  'Drywall',
  'Other',
];

// ── LeadCaptureScreen ─────────────────────────────────────────────────────────

class LeadCaptureScreen extends ConsumerStatefulWidget {
  const LeadCaptureScreen({super.key});

  @override
  ConsumerState<LeadCaptureScreen> createState() => _LeadCaptureScreenState();
}

class _LeadCaptureScreenState extends ConsumerState<LeadCaptureScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedJobType;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider).valueOrNull;
    final orgId = authState?.profile?.organizationId ?? '';
    final profileId = authState?.profile?.id;

    if (orgId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated — cannot save lead.')),
      );
      return;
    }

    setState(() => _saving = true);

    final companion = LocalLeadsCompanion.insert(
      id: _uuid.v4(),
      organizationId: orgId,
      createdByProfileId: profileId != null ? Value(profileId) : const Value.absent(),
      clientName: _nameCtrl.text.trim(),
      jobType: _selectedJobType!,
      phoneE164: _phoneCtrl.text.trim().isNotEmpty
          ? Value(_phoneCtrl.text.trim())
          : const Value.absent(),
      email: _emailCtrl.text.trim().isNotEmpty
          ? Value(_emailCtrl.text.trim())
          : const Value.absent(),
      notes: _notesCtrl.text.trim().isNotEmpty
          ? Value(_notesCtrl.text.trim())
          : const Value.absent(),
    );

    await ref.read(leadsDaoProvider).createLead(companion);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Lead'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // ── Section: Contact ──────────────────────────────────────
              _SectionLabel(label: 'Contact Info', icon: Icons.person_outline),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Client Name *',
                  hintText: 'e.g. John Smith',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Client name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))],
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1 555-000-0000',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'client@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final valid =
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                  return valid ? null : 'Enter a valid email address';
                },
              ),

              const SizedBox(height: 28),
              // ── Section: Job ──────────────────────────────────────────
              _SectionLabel(label: 'Job Details', icon: Icons.construction_outlined),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedJobType,
                decoration: const InputDecoration(
                  labelText: 'Job Type *',
                  prefixIcon: Icon(Icons.build_outlined),
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select job type'),
                items: _kJobTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedJobType = v),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please select a job type' : null,
              ),

              const SizedBox(height: 28),
              // ── Section: Notes ────────────────────────────────────────
              _SectionLabel(label: 'Notes', icon: Icons.notes_outlined),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'What did the client say? Any key details…',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving…' : 'Save Lead'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widget ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(label,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}
