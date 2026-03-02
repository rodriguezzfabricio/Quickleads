import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/job_health_status.dart';
import '../../core/domain/job_phase.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/phase_progress.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, this.jobId});

  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jobId == null || jobId!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No job ID provided.')),
      );
    }

    final jobAsync = ref.watch(jobByIdProvider(jobId!));

    return jobAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (job) {
        if (job == null) {
          return const Scaffold(
            body: Center(child: Text('Job not found or was deleted.')),
          );
        }
        return _JobDetailBody(job: job);
      },
    );
  }
}

class _JobDetailBody extends ConsumerStatefulWidget {
  const _JobDetailBody({required this.job});

  final LocalJob job;

  @override
  ConsumerState<_JobDetailBody> createState() => _JobDetailBodyState();
}

class _JobDetailBodyState extends ConsumerState<_JobDetailBody> {
  late JobHealthStatus _pendingHealthStatus;
  late final TextEditingController _newNoteController;
  late String _allNotes;
  DateTime? _estimatedCompletion;

  bool _updatingHealth = false;
  bool _updatingPhase = false;
  bool _addingNote = false;

  @override
  void initState() {
    super.initState();
    _pendingHealthStatus = JobHealthStatus.fromDb(widget.job.healthStatus);
    _newNoteController = TextEditingController();
    _allNotes = widget.job.notes ?? '';
    _estimatedCompletion = widget.job.estimatedCompletionDate;
  }

  @override
  void didUpdateWidget(covariant _JobDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.job.healthStatus != oldWidget.job.healthStatus &&
        !_updatingHealth) {
      _pendingHealthStatus = JobHealthStatus.fromDb(widget.job.healthStatus);
    }
    if (widget.job.notes != oldWidget.job.notes && !_addingNote) {
      _allNotes = widget.job.notes ?? '';
    }
    _estimatedCompletion = widget.job.estimatedCompletionDate;
  }

  @override
  void dispose() {
    _newNoteController.dispose();
    super.dispose();
  }

  Future<void> _changeHealthStatus(JobHealthStatus newStatus) async {
    if (_updatingHealth || newStatus.dbValue == widget.job.healthStatus) return;

    setState(() {
      _pendingHealthStatus = newStatus;
      _updatingHealth = true;
    });

    try {
      await ref.read(jobsDaoProvider).updateJobHealthStatus(
            widget.job.id,
            newStatus.dbValue,
            widget.job.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update status: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingHealth = false);
      }
    }
  }

  Future<void> _setPhase(String phaseDbValue) async {
    final currentPhase = JobPhase.fromDb(widget.job.phase);
    final nextPhase = JobPhase.fromDb(phaseDbValue);

    final currentIndex = JobPhase.orderedValues.indexOf(currentPhase);
    final nextIndex = JobPhase.orderedValues.indexOf(nextPhase);

    if (currentIndex == nextIndex || nextIndex < 0) return;

    final movingBack = nextIndex < currentIndex;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movingBack ? 'Move back a phase?' : 'Advance phase?',
                style: AppTextStyles.h2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                movingBack
                    ? 'Move this job back to ${nextPhase.displayLabel}?'
                    : 'Move this job to ${nextPhase.displayLabel}?',
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(movingBack ? 'Move Back' : 'Advance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _updatingPhase = true);

    try {
      await ref.read(jobsDaoProvider).updateJobPhase(
            widget.job.id,
            nextPhase.dbValue,
            widget.job.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update phase: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingPhase = false);
      }
    }
  }

  Future<void> _showAddPhotoSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final photoService = ref.read(photoUploadServiceProvider);
      final file = await photoService.pickPhoto(source: source);
      if (file == null) return;
      await photoService.saveJobPhoto(
        jobId: widget.job.id,
        orgId: widget.job.organizationId,
        file: file,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add photo: $error')),
      );
    }
  }

  Future<void> _addNote() async {
    final newNote = _newNoteController.text.trim();
    if (newNote.isEmpty) return;

    setState(() => _addingNote = true);
    final nextNotes =
        _allNotes.isEmpty ? newNote : '$newNote\n\n---\n\n$_allNotes';

    try {
      await ref.read(jobsDaoProvider).updateJobNotes(
            widget.job.id,
            nextNotes,
            widget.job.version,
          );
      _newNoteController.clear();
      _allNotes = nextNotes;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save notes: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _addingNote = false);
      }
    }
  }

  Future<void> _callClient(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    await launchUrl(Uri.parse('tel:$phone'));
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final photosAsync = ref.watch(photosByJobProvider(job.id));
    final leadAsync = job.leadId == null
        ? const AsyncData<LocalLead?>(null)
        : ref.watch(leadByIdProvider(job.leadId!));

    final currentPhase = JobPhase.fromDb(job.phase);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go(AppRoutes.jobs),
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.foreground, size: 24),
                ),
              ],
            ),
            Text(job.clientName, style: AppTextStyles.h1),
            const SizedBox(height: 2),
            Text(job.jobType, style: AppTextStyles.secondary),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHASE', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 12),
                  if (_updatingPhase)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    PhaseProgress(
                      currentPhase: currentPhase.dbValue,
                      interactive: true,
                      onPhaseSelected: _setPhase,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _estimatedCompletion ?? now,
                        firstDate: DateTime(now.year - 2),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) {
                        setState(() => _estimatedCompletion = picked);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Text(
                            'Est. Completion',
                            style: AppTextStyles.tiny.copyWith(fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            _estimatedCompletion == null
                                ? 'Select date'
                                : DateFormat('MMM d, yyyy')
                                    .format(_estimatedCompletion!),
                            style: AppTextStyles.secondary.copyWith(
                              fontSize: 15,
                              color: AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'Status',
                          style: AppTextStyles.tiny.copyWith(fontSize: 13),
                        ),
                        const Spacer(),
                        if (_updatingHealth)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          DropdownButtonHideUnderline(
                            child: DropdownButton<JobHealthStatus>(
                              value: _pendingHealthStatus,
                              dropdownColor: AppColors.background,
                              style: AppTextStyles.secondary.copyWith(
                                fontSize: 15,
                                color: AppColors.foreground,
                              ),
                              items: JobHealthStatus.values
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.displayLabel),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                _changeHealthStatus(value);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHOTOS', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 10),
                  photosAsync.when(
                    loading: () => const SizedBox(
                      height: 90,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (error, _) => Text(
                      'Could not load photos: $error',
                      style: AppTextStyles.secondary,
                    ),
                    data: (photos) => Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: photos.isEmpty ? 3 : photos.length,
                          itemBuilder: (context, index) {
                            if (photos.isEmpty) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.glassElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.glassBorder),
                                ),
                              );
                            }

                            final photo = photos[index];
                            final provider = _photoProvider(photo);
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: provider == null
                                  ? Container(
                                      color: AppColors.glassElevated,
                                      child: const Icon(
                                          Icons.broken_image_outlined),
                                    )
                                  : Image(image: provider, fit: BoxFit.cover),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _showAddPhotoSheet,
                          child: GlassCard(
                            borderRadius: 12,
                            color: AppColors.glassProminent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.photo_camera_outlined,
                                    color: AppColors.systemBlue, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Photo',
                                  style: AppTextStyles.h4.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOTES', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newNoteController,
                    maxLines: 3,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle:
                          AppTextStyles.body.copyWith(color: AppColors.mutedFg),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _addingNote ? null : _addNote,
                    icon: const Icon(Icons.add, size: 14),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.badge.copyWith(fontSize: 13),
                    ),
                    label: const Text('+ Add'),
                  ),
                  if (_allNotes.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GlassCard(
                      borderRadius: 12,
                      color: AppColors.glassElevated,
                      child: Text(
                        _allNotes,
                        style: AppTextStyles.secondary.copyWith(
                          fontSize: 15,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => _callClient(leadAsync.valueOrNull?.phoneE164),
              icon: const Icon(Icons.phone_outlined),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              label: Text('Call ${job.clientName}',
                  style: AppTextStyles.buttonPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

ImageProvider<Object>? _photoProvider(LocalJobPhoto photo) {
  final localPath = photo.localFilePath;
  if (localPath != null && localPath.trim().isNotEmpty) {
    final file = File(localPath);
    if (file.existsSync()) {
      return FileImage(file);
    }
  }

  final storagePath = photo.storagePath;
  if (storagePath != null && storagePath.trim().isNotEmpty) {
    final url = Supabase.instance.client.storage
        .from('job-photos')
        .getPublicUrl(storagePath);
    return NetworkImage(url);
  }

  return null;
}
