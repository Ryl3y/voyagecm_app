import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_client.dart';
import '../../models.dart';
import '../../utils/format.dart';
import '../../widgets/async_view.dart';

/// Liste des passagers d'un trajet pour une date (pour l'embarquement).
class PassengersScreen extends StatefulWidget {
  const PassengersScreen({super.key, required this.trip});

  final Trip trip;

  @override
  State<PassengersScreen> createState() => _PassengersScreenState();
}

class _PassengersScreenState extends State<PassengersScreen> {
  DateTime _date = dateOnly(DateTime.now());
  late Future<List<Passenger>> _future = _load();

  Future<List<Passenger>> _load() =>
      context.read<ApiClient>().passengers(widget.trip.id, _date);

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today.add(const Duration(days: 90)),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${trip.departureCity} → ${trip.arrivalCity} · ${trip.departureTime}',
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(formatLongDate(_date)),
            trailing: TextButton(
              onPressed: _pickDate,
              child: const Text('Changer'),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureView<List<Passenger>>(
              future: _future,
              onRetry: () => setState(() => _future = _load()),
              builder: (context, passengers) {
                if (passengers.isEmpty) {
                  return const Center(
                    child: Text('Aucune réservation pour cette date.'),
                  );
                }
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${passengers.length} / ${trip.capacity} places réservées',
                      ),
                    ),
                    for (final p in passengers)
                      ListTile(
                        leading: CircleAvatar(child: Text('${p.seatNumber}')),
                        title: Text(p.name),
                        subtitle: Text('${p.code} · ${p.phone}'),
                        trailing: Text(p.paymentMethod.label),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
