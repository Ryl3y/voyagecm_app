import 'package:flutter/material.dart';

import '../models.dart';
import '../utils/format.dart';
import 'agency_title.dart';

/// Carte d'un trajet dans les résultats de recherche.
class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, required this.onBook});

  final Trip trip;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seats = trip.availableSeats ?? trip.capacity;
    final full = seats <= 0;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (trip.agency.imageUrl != null)
            Image.network(
              trip.agency.imageUrl!,
              height: 110,
              fit: BoxFit.cover,
              semanticLabel: 'Bus de ${trip.agency.name}',
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AgencyTitle(agency: trip.agency),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TimeColumn(
                      time: trip.departureTime,
                      city: trip.departureCity,
                    ),
                    const Expanded(child: Icon(Icons.arrow_forward)),
                    _TimeColumn(
                      time: trip.arrivalTime,
                      city: trip.arrivalCity,
                      end: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(trip.tripClass.label),
                      visualDensity: VisualDensity.compact,
                    ),
                    for (final s in trip.agency.services)
                      Chip(
                        label: Text(s),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatPrice(trip.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      full
                          ? 'Complet'
                          : '$seats place${seats > 1 ? 's' : ''} libre${seats > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: full ? theme.colorScheme.error : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: full ? null : onBook,
                  child: Text(full ? 'Complet' : 'Réserver ce trajet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({required this.time, required this.city, this.end = false});

  final String time;
  final String city;
  final bool end;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(city),
      ],
    );
  }
}
