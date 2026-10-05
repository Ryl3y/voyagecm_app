import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../api/api_client.dart';
import '../../models.dart';
import '../../utils/format.dart';
import '../../widgets/async_view.dart';
import 'agency_form_screen.dart';
import 'pro_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<(AdminStats, List<Trip>)> _future = _load();

  Future<(AdminStats, List<Trip>)> _load() async {
    final api = context.read<ApiClient>();
    final results = await Future.wait([api.adminStats(), api.adminTrips()]);
    return (results[0] as AdminStats, results[1] as List<Trip>);
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  Future<void> _addAgency() async {
    final created = await Navigator.of(context).push<AgencyCredentials>(
      MaterialPageRoute(builder: (_) => const AgencyFormScreen()),
    );
    if (created == null || !mounted) return;
    _refresh();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Agence ajoutée !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '« ${created.agency.name} » a été ajoutée. Transmettez ces identifiants à l\'agence :',
            ),
            const SizedBox(height: 12),
            SelectableText(
              "Nom d'utilisateur : ${created.username}\nMot de passe : ${created.password}",
            ),
            const SizedBox(height: 12),
            const Text(
              'Ce mot de passe ne sera plus affiché.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: '${created.username} / ${created.password}',
                ),
              );
              showInfo(context, 'Identifiants copiés');
            },
            child: const Text('Copier'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: const [LogoutButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAgency,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Ajouter une agence'),
      ),
      body: FutureView<(AdminStats, List<Trip>)>(
        future: _future,
        onRetry: _refresh,
        builder: (context, data) {
          final (stats, trips) = data;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Text(
                  "Vue d'ensemble",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.7,
                  children: [
                    _StatTile(
                      label: 'Trajets actifs',
                      value: '${stats.totalTrips}',
                      icon: Icons.route,
                    ),
                    _StatTile(
                      label: 'Agences',
                      value: '${stats.totalAgencies}',
                      icon: Icons.business,
                    ),
                    _StatTile(
                      label: "Réservations aujourd'hui",
                      value: '${stats.bookingsToday}',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    _StatTile(
                      label: "Places libres aujourd'hui",
                      value: '${stats.availableSeatsToday}',
                      icon: Icons.event_seat_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _StatTile(
                  label: 'Recettes du jour (simulation)',
                  value: formatPrice(stats.revenueToday),
                  icon: Icons.payments_outlined,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tous les trajets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final trip in trips)
                  Card(
                    child: ListTile(
                      leading: Text(
                        trip.agency.logo,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        '${trip.departureCity} → ${trip.arrivalCity}',
                      ),
                      subtitle: Text(
                        '${trip.code ?? '#${trip.id}'} · ${trip.agency.name}\n'
                        '${trip.departureTime} → ${trip.arrivalTime} · ${trip.tripClass.value} · ${trip.capacity} places',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        formatPrice(trip.price),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
