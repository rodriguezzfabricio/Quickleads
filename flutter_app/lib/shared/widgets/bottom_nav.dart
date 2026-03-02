import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_card.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onCreateLead,
    required this.onCreateProject,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreateLead;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          height: 83,
          decoration: const BoxDecoration(
            color: AppColors.glassNav,
            border:
                Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 83,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavItem(
                            label: 'Home',
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home,
                            active: selectedIndex == 0,
                            onTap: () => onSelect(0),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            label: 'Leads',
                            icon: Icons.people_alt_outlined,
                            activeIcon: Icons.people_alt,
                            active: selectedIndex == 1,
                            onTap: () => onSelect(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: GestureDetector(
                        onTap: () => _showCreateSheet(context),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.systemBlue,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF0A0A0A), width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66007AFF),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavItem(
                            label: 'Clients',
                            icon: Icons.account_circle_outlined,
                            activeIcon: Icons.account_circle,
                            active: selectedIndex == 2,
                            onTap: () => onSelect(2),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            label: 'Jobs',
                            icon: Icons.work_outline,
                            activeIcon: Icons.work,
                            active: selectedIndex == 3,
                            onTap: () => onSelect(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('CREATE', style: AppTextStyles.sectionLabel),
                const SizedBox(height: 12),
                _CreateButton(
                  label: '+ New Lead',
                  icon: Icons.phone_outlined,
                  tint: AppColors.systemBlue,
                  onTap: () {
                    Navigator.of(context).pop();
                    onCreateLead();
                  },
                ),
                const SizedBox(height: 12),
                _CreateButton(
                  label: '+ New Project',
                  icon: Icons.assignment_outlined,
                  tint: AppColors.systemGreen,
                  onTap: () {
                    Navigator.of(context).pop();
                    onCreateProject();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.systemBlue : const Color(0x59EBEBF5);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 24,
              color: color,
              weight: active ? 2.2 : 1.6,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.tiny.copyWith(
                fontSize: 10,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tint.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.h3.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
