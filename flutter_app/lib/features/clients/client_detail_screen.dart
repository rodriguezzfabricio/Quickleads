import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_scaffold.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({
    super.key,
    this.clientId,
    this.isCreateFlow = false,
  });

  final String? clientId;
  final bool isCreateFlow;

  @override
  Widget build(BuildContext context) {
    final title = isCreateFlow ? 'New Client' : 'Client Detail';
    final subtitle = isCreateFlow
        ? 'Phase 2 placeholder: add/convert client form and previous-project draft controls land here.'
        : (clientId == null || clientId!.isEmpty)
            ? 'Phase 2 placeholder: client profile actions and project history land here.'
            : 'Phase 2 placeholder: client profile actions for $clientId land here.';

    return PlaceholderScaffold(
      title: title,
      subtitle: subtitle,
    );
  }
}
