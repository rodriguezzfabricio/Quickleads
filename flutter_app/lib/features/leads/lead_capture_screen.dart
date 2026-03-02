import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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

class LeadCaptureScreen extends ConsumerStatefulWidget {
  const LeadCaptureScreen({
    super.key,
    this.initialPhone,
  });

  final String? initialPhone;

  @override
  ConsumerState<LeadCaptureScreen> createState() => _LeadCaptureScreenState();
}

class _LeadCaptureScreenState extends ConsumerState<LeadCaptureScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _quickTextCtrl = TextEditingController();
  final _otherJobCtrl = TextEditingController();

  String _selectedJobType = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initialPhone = widget.initialPhone?.trim();
    if (initialPhone != null && initialPhone.isNotEmpty) {
      _phoneCtrl.text = initialPhone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _quickTextCtrl.dispose();
    _otherJobCtrl.dispose();
    super.dispose();
  }

  String get _resolvedJobType {
    if (_selectedJobType == 'Other') {
      return _otherJobCtrl.text.trim();
    }
    return _selectedJobType;
  }

  bool get _hasStructuredInput {
    return _nameCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty &&
        _resolvedJobType.isNotEmpty;
  }

  bool get _hasQuickText {
    return _quickTextCtrl.text.trim().isNotEmpty;
  }

  bool get _canSave => (_hasStructuredInput || _hasQuickText) && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;

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

    final name = _hasStructuredInput ? _nameCtrl.text.trim() : 'Quick Lead';
    final phone = _hasStructuredInput ? _phoneCtrl.text.trim() : '';
    final jobType = _hasStructuredInput ? _resolvedJobType : 'Other';
    final notes = _hasQuickText ? _quickTextCtrl.text.trim() : null;

    final companion = LocalLeadsCompanion.insert(
      id: _uuid.v4(),
      organizationId: orgId,
      createdByProfileId:
          profileId != null ? Value(profileId) : const Value.absent(),
      clientName: name,
      phoneE164: phone.isNotEmpty ? Value(phone) : const Value.absent(),
      jobType: jobType,
      notes: notes != null ? Value(notes) : const Value.absent(),
    );

    await ref.read(leadsDaoProvider).createLead(companion);

    if (!mounted) return;
    context.go('/leads');
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.foreground,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 2),
                Text('New Lead', style: AppTextStyles.h1),
              ],
            ),
            const SizedBox(height: 18),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle:
                      AppTextStyles.body.copyWith(color: AppColors.mutedFg),
                  border: InputBorder.none,
                  isCollapsed: true,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Phone',
                  hintStyle:
                      AppTextStyles.body.copyWith(color: AppColors.mutedFg),
                  border: InputBorder.none,
                  isCollapsed: true,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('WHAT THEY NEED', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final jobType in _jobTypes)
                  _JobTypeChip(
                    label: jobType,
                    active: _selectedJobType == jobType,
                    onTap: () {
                      setState(() => _selectedJobType = jobType);
                    },
                  ),
              ],
            ),
            if (_selectedJobType == 'Other') ...[
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _otherJobCtrl,
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Describe...',
                    hintStyle:
                        AppTextStyles.body.copyWith(color: AppColors.mutedFg),
                    border: InputBorder.none,
                    isCollapsed: true,
                    filled: false,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.glassBorder,
                  ),
                ),
                const SizedBox(width: 10),
                Text('OR',
                    style:
                        AppTextStyles.badge.copyWith(color: AppColors.mutedFg)),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.glassBorder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('QUICK TEXT', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            Stack(
              children: [
                GlassCard(
                  child: TextField(
                    controller: _quickTextCtrl,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText:
                          "Or just type it: 'John 301-555-2847 deck rebuild'",
                      hintStyle:
                          AppTextStyles.body.copyWith(color: AppColors.mutedFg),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const Positioned(
                  right: 16,
                  bottom: 16,
                  child: Icon(
                    Icons.send,
                    size: 20,
                    color: Color(0xCC007AFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
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
                    : const Text('Save Lead'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobTypeChip extends StatefulWidget {
  const _JobTypeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_JobTypeChip> createState() => _JobTypeChipState();
}

class _JobTypeChipState extends State<_JobTypeChip> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.95),
        onTapCancel: () => setState(() => _scale = 1),
        onTapUp: (_) => setState(() => _scale = 1),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:
                widget.active ? AppColors.systemBlue : AppColors.glassElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.h4.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: widget.active ? Colors.white : AppColors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
