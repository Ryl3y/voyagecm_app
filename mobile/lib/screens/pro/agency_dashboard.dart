import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_client.dart';
import '../../models.dart';
import '../../utils/format.dart';
import '../../widgets/async_view.dart';
import 'passengers_screen.dart';
import 'pro_screen.dart';
import 'trip_form_screen.dart';

class AgencyDashboard extends StatefulWidget {
  const AgencyDashboard({super.key, required this.agencyName});

  final String agencyName;

  @override
  State<AgencyDashboard> createState() => _AgencyDashboardState();
}

class _AgencyDashboardState extends State<AgencyDashboard> {
  late Future<List<Trip>> _future = context.read<ApiClient>().agencyTrips();

  Future<void> _refresh() async {
    final future = context.read<ApiClient>().agencyTrips();
    setState(() => _future = future);
    await future;
  }

  Future<void> _openForm([Trip? trip]) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => TripFormScreen(trip: trip)));
    if (saved == true && mounted) {
      showInfo(context, trip == null ? 'Trajet ajouté !' : 'Trajet modifié.');
      _refresh();
    }
  }

  void _openPassengers(Trip trip) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => PassengersScreen(trip: trip)));

  Future<void> _delete(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce trajet ?'),
        content: Text(
          '${trip.departureCity} → ${trip.arrivalCity} à ${trip.departureTime}.\n'
          'Il ne sera plus proposé à la réservation. Les billets déjà vendus restent valables.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: Size.zero,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ApiClient>().deleteTrip(trip.id);
      if (!mounted) return;
      showInfo(context, 'Trajet supprimé.');
      _refresh();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agencyName),
        actions: const [LogoutButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau trajet'),
      ),
      body: FutureView<List<Trip>>(
        future: _future,
        onRetry: _refresh,
        builder: (context, trips) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: trips.isEmpty
                ? ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Aucun trajet pour le moment.\nAppuyez sur « Nouveau trajet » pour commencer.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      Text(
                        'Vos trajets (${trips.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final trip in trips)
                        Card(
                          child: ListTile(
                            title: Text(
                              '${trip.departureCity} → ${trip.arrivalCity}',
                            ),
                            subtitle: Text(
                              '${trip.code ?? ''} · ${trip.departureTime} → ${trip.arrivalTime}\n'
                              '${trip.tripClass.label} · ${trip.capacity} places · ${formatPrice(trip.price)}',
                            ),
                            isThreeLine: true,
                            onTap: () => _openPassengers(trip),
                            trailing: PopupMenuButton<String>(
                              tooltip: 'Actions',
                              onSelected: (action) => switch (action) {
                                'edit' => _openForm(trip),
                                'delete' => _delete(trip),
                                _ => _openPassengers(trip),
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'passengers',
                                  child: Text('Passagers'),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Modifier'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Supprimer'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
