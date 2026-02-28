import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../auth/providers/auth_provider.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

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

    final leadsAsync = ref.watch(allLeadsProvider(orgId));
    final jobsAsync = ref.watch(jobsByOrgProvider(orgId));
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      body: SafeArea(
        child: leadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading clients: $error'),
          ),
          data: (leads) => jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error loading clients: $error'),
            ),
            data: (jobs) {
              final clients = _buildClientSummaries(leads: leads, jobs: jobs);
              final filtered = query.isEmpty
                  ? clients
                  : clients.where((client) {
                      return client.name.toLowerCase().contains(query) ||
                          client.phone.toLowerCase().contains(query);
                    }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Clients',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.clientCreate),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppTokens.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 122, 255, 0.35),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SearchInput(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    const _EmptyState()
                  else
                    ...filtered.map(
                      (client) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ClientCard(client: client),
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

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search clients...',
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.outline,
        ),
        filled: true,
        fillColor: AppTokens.glassElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTokens.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTokens.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTokens.primary),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final _ClientSummary client;

  @override
  Widget build(BuildContext context) {
    final lastProjectLabel = client.lastProjectType == null
        ? null
        : 'Last: ${client.lastProjectType} · ${DateFormat('MMM yyyy').format(client.lastActivityAt)}';

    return Material(
      color: AppTokens.glassElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(
          AppRoutes.clientDetail.replaceFirst(':clientId', client.id),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTokens.glassBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTokens.primary.withValues(alpha: 0.25),
                ),
                child: Center(
                  child: Text(
                    client.name.isEmpty ? '?' : client.name[0].toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTokens.primary,
                        ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontSize: 30 / 2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${client.projectCount} project${client.projectCount == 1 ? '' : 's'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      client.phone,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    if (lastProjectLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lastProjectLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 46),
      child: Column(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 56,
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          Text(
            'No clients found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first client',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _ClientSummary {
  const _ClientSummary({
    required this.id,
    required this.name,
    required this.phone,
    required this.projectCount,
    required this.lastActivityAt,
    required this.lastProjectType,
  });

  final String id;
  final String name;
  final String phone;
  final int projectCount;
  final DateTime lastActivityAt;
  final String? lastProjectType;
}

class _MutableClientSummary {
  _MutableClientSummary({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
  String phone = 'No phone on file';
  int projectCount = 0;
  DateTime? lastActivityAt;
  String? lastProjectType;
}

List<_ClientSummary> _buildClientSummaries({
  required List<LocalLead> leads,
  required List<LocalJob> jobs,
}) {
  final summaries = <String, _MutableClientSummary>{};

  _MutableClientSummary readOrCreate(String name) {
    final normalizedName = name.trim().toLowerCase();
    return summaries.putIfAbsent(
      normalizedName,
      () => _MutableClientSummary(
        id: 'client-${normalizedName.replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
        name: name,
      ),
    );
  }

  for (final lead in leads) {
    final summary = readOrCreate(lead.clientName);
    if (lead.phoneE164 != null && lead.phoneE164!.trim().isNotEmpty) {
      summary.phone = lead.phoneE164!;
    }
    if (summary.lastActivityAt == null ||
        lead.updatedAt.isAfter(summary.lastActivityAt!)) {
      summary.lastActivityAt = lead.updatedAt;
      summary.lastProjectType = lead.jobType;
    }
  }

  for (final job in jobs) {
    final summary = readOrCreate(job.clientName);
    summary.projectCount++;
    if (summary.lastActivityAt == null ||
        job.updatedAt.isAfter(summary.lastActivityAt!)) {
      summary.lastActivityAt = job.updatedAt;
      summary.lastProjectType = job.jobType;
    }
  }

  return summaries.values.map((summary) {
    return _ClientSummary(
      id: summary.id,
      name: summary.name,
      phone: summary.phone,
      projectCount: summary.projectCount,
      lastActivityAt: summary.lastActivityAt ?? DateTime.now(),
      lastProjectType: summary.lastProjectType,
    );
  }).toList()
    ..sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
}
