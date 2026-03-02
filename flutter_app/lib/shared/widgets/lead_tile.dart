import 'package:flutter/material.dart';

import '../../core/storage/app_database.dart';
import 'lead_card.dart';

class LeadTile extends StatelessWidget {
  const LeadTile({
    super.key,
    required this.lead,
    this.onTap,
  });

  final LocalLead lead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LeadCard(
      lead: lead,
      onTap: onTap,
    );
  }
}
