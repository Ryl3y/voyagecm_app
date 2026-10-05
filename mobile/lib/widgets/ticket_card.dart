import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../utils/format.dart';
import 'agency_title.dart';

/// Billet : code de réservation + détails du voyage.
class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = booking.trip;

    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Code de réservation',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  booking.code,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'Copier le code',
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: booking.code));
                    showInfo(context, 'Code copié');
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            AgencyTitle(agency: trip.agency),
            const SizedBox(height: 8),
            line('Trajet', '${trip.departureCity} → ${trip.arrivalCity}'),
            line('Date', formatLongDate(booking.travelDate)),
            line(
              'Horaires',
              'Départ ${trip.departureTime} · Arrivée ${trip.arrivalTime}',
            ),
            line('Classe', trip.tripClass.label),
            line('Siège', '${booking.seatNumber}'),
            line('Passager', booking.passengerName),
            line('CNI', booking.passengerCniMasked),
            line('Téléphone', booking.passengerPhone),
            line('Paiement', '${booking.paymentMethod.label} (simulation)'),
            line('Montant', formatPrice(booking.amount)),
          ],
        ),
      ),
    );
  }
}
