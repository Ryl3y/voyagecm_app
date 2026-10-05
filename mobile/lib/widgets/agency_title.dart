import 'package:flutter/material.dart';

import '../models.dart';

/// Logo + nom de l'agence + badge « Vérifiée ».
class AgencyTitle extends StatelessWidget {
  const AgencyTitle({super.key, required this.agency});

  final Agency agency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(agency.logo, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            agency.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (agency.verified) ...[
          const SizedBox(width: 6),
          Icon(
            Icons.verified,
            size: 18,
            color: theme.colorScheme.primary,
            semanticLabel: 'Agence vérifiée',
          ),
        ],
      ],
    );
  }
}
