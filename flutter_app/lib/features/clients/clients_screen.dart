import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final clientsAsync = ref.watch(clientsByOrgProvider(orgId));
    final jobsAsync = ref.watch(jobsByOrgProvider(orgId));
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: clientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading clients: $error'),
          ),
          data: (clients) => jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error loading clients: $error'),
            ),
            data: (jobs) {
              final filtered = query.isEmpty
                  ? clients
                  : clients.where((client) {
                      return client.name.toLowerCase().contains(query) ||
                          (client.phone ?? '').toLowerCase().contains(query) ||
                          (client.email ?? '').toLowerCase().contains(query);
                    }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Clients', style: AppTextStyles.h1)),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.clientCreate),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.systemBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: AppTextStyles.body,
                          decoration: InputDecoration(
                            hintText: 'Search clients...',
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
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            size: 56,
                            color: AppColors.mutedFg.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No clients found',
                            style: AppTextStyles.secondary.copyWith(
                              fontSize: 17,
                              color: AppColors.mutedFg,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add your first client',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.mutedFg.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final client in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ClientCard(
                          client: client,
                          jobs: jobs,
                        ),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.jobs,
  });

  final LocalClient client;
  final List<LocalJob> jobs;

  @override
  Widget build(BuildContext context) {
    final linkedJobs = jobs.where((job) {
      if (client.sourceLeadId != null &&
          (client.sourceLeadId as String).isNotEmpty) {
        return job.leadId == client.sourceLeadId;
      }
      return job.clientName.trim().toLowerCase() ==
          client.name.trim().toLowerCase();
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    String? lastProjectText;
    if (linkedJobs.isNotEmpty) {
      final latest = linkedJobs.first;
      final date = DateFormat('MMM yyyy').format(latest.updatedAt.toLocal());
      lastProjectText = 'Last project: ${latest.jobType} · $date';
    }

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.clientDetail.replaceFirst(':clientId', client.id),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.systemBlue.withValues(alpha: 0.2),
              ),
              alignment: Alignment.center,
              child: Text(
                client.name.isEmpty ? '?' : client.name[0].toUpperCase(),
                style: AppTextStyles.h3.copyWith(
                  fontSize: 17,
                  color: AppColors.systemBlue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.name,
                          style: AppTextStyles.h3.copyWith(fontSize: 17),
                        ),
                      ),
                      Text(
                        '${client.projectCount}',
                        style: AppTextStyles.tiny.copyWith(
                          fontSize: 12,
                          color: AppColors.mutedFg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.phone?.trim().isNotEmpty == true
                        ? client.phone!
                        : 'No phone on file',
                    style: AppTextStyles.secondary.copyWith(fontSize: 14),
                  ),
                  if (lastProjectText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      lastProjectText,
                      style: AppTextStyles.tiny.copyWith(
                        fontSize: 12,
                        color: AppColors.mutedFg.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
