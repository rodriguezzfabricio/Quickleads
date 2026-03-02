import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/glass_card.dart';
import '../auth/providers/auth_provider.dart';

const _uuid = Uuid();

class DataImportScreen extends ConsumerStatefulWidget {
  const DataImportScreen({super.key});

  @override
  ConsumerState<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends ConsumerState<DataImportScreen> {
  bool _importing = false;
  bool _imported = false;
  int _importedLeads = 0;
  int _importedJobs = 0;

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  Future<void> _finishToHome() async {
    await _markOnboardingComplete();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Future<void> _uploadSpreadsheet() async {
    final auth = ref.read(authProvider).valueOrNull;
    final orgId = auth?.profile?.organizationId ?? '';
    final profileId = auth?.profile?.id;

    if (orgId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated — cannot import.')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    setState(() => _importing = true);

    int importedLeads = 0;

    try {
      final raw = utf8.decode(bytes);
      final rows = const CsvToListConverter(shouldParseNumbers: false)
          .convert(raw)
          .map((row) => row.map((cell) => '${cell ?? ''}'.trim()).toList())
          .where((row) => row.any((cell) => cell.isNotEmpty))
          .toList();

      if (rows.isNotEmpty) {
        final header = rows.first.map((e) => e.toLowerCase()).toList();
        final nameIdx = _findColumn(header, ['name']);
        final phoneIdx = _findColumn(header, ['phone', 'mobile']);
        final jobIdx = _findColumn(header, ['job', 'type']);
        final emailIdx = _findColumn(header, ['email']);

        for (var i = 1; i < rows.length; i++) {
          final row = rows[i];
          final name = _cell(row, nameIdx);
          final phone = _cell(row, phoneIdx);
          final jobType = _cell(row, jobIdx);
          final email = _cell(row, emailIdx);

          if (name.isEmpty || phone.isEmpty) continue;

          await ref.read(leadsDaoProvider).createLead(
                LocalLeadsCompanion.insert(
                  id: _uuid.v4(),
                  organizationId: orgId,
                  createdByProfileId: profileId != null
                      ? Value(profileId)
                      : const Value.absent(),
                  clientName: name,
                  phoneE164: Value(phone),
                  email: email.isNotEmpty ? Value(email) : const Value.absent(),
                  jobType: jobType.isNotEmpty ? jobType : 'General Project',
                  status: const Value('new_callback'),
                ),
              );
          importedLeads += 1;
        }
      }

      if (!mounted) return;
      setState(() {
        _imported = true;
        _importedLeads = importedLeads;
        _importedJobs = 0;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imported) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.systemGreen.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.systemGreen,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Import Successful!',
                        style: AppTextStyles.h1.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_importedLeads leads and $_importedJobs jobs imported.',
                        style: AppTextStyles.secondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _finishToHome,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Go to Dashboard'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to CrewCommand',
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Import your leads and jobs to get started.',
                    style: AppTextStyles.secondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _importing ? null : _uploadSpreadsheet,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.systemBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.upload,
                              color: AppColors.systemBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload Spreadsheet',
                                  style:
                                      AppTextStyles.h3.copyWith(fontSize: 17),
                                ),
                                Text(
                                  'CSV or Excel',
                                  style:
                                      AppTextStyles.tiny.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (_importing)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _finishToHome,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("I'm Starting Fresh"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Import later from Settings',
                    style: AppTextStyles.tiny.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _findColumn(List<String> header, List<String> keywords) {
    for (var i = 0; i < header.length; i++) {
      for (final keyword in keywords) {
        if (header[i].contains(keyword)) {
          return i;
        }
      }
    }
    return -1;
  }

  String _cell(List<String> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return row[index].trim();
  }
}
