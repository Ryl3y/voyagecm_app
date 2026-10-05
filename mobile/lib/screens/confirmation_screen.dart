import 'package:flutter/material.dart';

import '../models.dart';
import '../widgets/ticket_card.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservation confirmée'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.check,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Réservation confirmée !',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            "Conservez votre code : il vous sera demandé à l'embarquement.\n"
            'Vous pouvez retrouver ce billet dans l\'onglet « Mon billet ».',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TicketCard(booking: booking),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Retour à l'accueil"),
          ),
          const SizedBox(height: 8),
          const Text(
            'Merci d\'utiliser VoyageCM !',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
