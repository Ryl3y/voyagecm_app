import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../models.dart';
import '../utils/format.dart';
import '../widgets/async_view.dart';
import '../widgets/trip_card.dart';
import 'booking_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<City>> _citiesFuture;
  int? _departureId;
  int? _arrivalId;
  DateTime _date = dateOnly(DateTime.now());

  List<Trip>? _results; // null = aucune recherche encore faite
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() {
    _citiesFuture = context.read<ApiClient>().cities().then((cities) {
      // Valeurs par défaut : Yaoundé → Douala, comme sur la version web.
      _departureId ??= cities.idOf('Yaoundé') ?? cities.first.id;
      _arrivalId ??= cities.idOf('Douala') ?? cities.last.id;
      return cities;
    });
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      helpText: 'Date de voyage',
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _swap() => setState(() {
    final departure = _departureId;
    _departureId = _arrivalId;
    _arrivalId = departure;
  });

  Future<void> _search() async {
    if (_departureId == null || _arrivalId == null) return;
    if (_departureId == _arrivalId) {
      showError(
        context,
        const ApiException(
          "La ville de départ et la ville d'arrivée ne peuvent pas être identiques.",
        ),
      );
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final trips = await context.read<ApiClient>().searchTrips(
        departureCityId: _departureId!,
        arrivalCityId: _arrivalId!,
        date: _date,
      );
      if (mounted) setState(() => _results = trips);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _book(Trip trip) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookingScreen(trip: trip, date: _date),
      ),
    );
    // Rafraîchir le nombre de places (réservation faite, ou sièges pris entre-temps).
    if (mounted) _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VoyageCM')),
      body: FutureView<List<City>>(
        future: _citiesFuture,
        onRetry: () => setState(_loadCities),
        builder: (context, cities) => RefreshIndicator(
          onRefresh: _results == null ? () async {} : _search,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildForm(cities),
              const SizedBox(height: 16),
              ..._buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(List<City> cities) {
    final theme = Theme.of(context);
    DropdownButtonFormField<int> cityField(
      String label,
      int? value,
      ValueChanged<int?> onChanged,
      IconData icon,
    ) => DropdownButtonFormField<int>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: [
        for (final c in cities)
          DropdownMenuItem(value: c.id, child: Text(c.name)),
      ],
      onChanged: onChanged,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Trouvez votre prochain voyage',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Comparez les agences vérifiées et réservez votre place en quelques secondes.',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            cityField(
              'Ville de départ',
              _departureId,
              (v) => setState(() => _departureId = v),
              Icons.trip_origin,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Inverser départ et arrivée',
                icon: const Icon(Icons.swap_vert),
                onPressed: _swap,
              ),
            ),
            cityField(
              "Ville d'arrivée",
              _arrivalId,
              (v) => setState(() => _arrivalId = v),
              Icons.place_outlined,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de voyage',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatLongDate(_date)),
              ),
            ),
            const SizedBox(height: 16),
            BusyButton(
              busy: _searching,
              onPressed: _search,
              icon: Icons.search,
              label: 'Rechercher les voyages',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResults() {
    if (_error != null) {
      return [ErrorRetry(message: _error!, onRetry: _search)];
    }
    final results = _results;
    if (results == null) {
      return const [
        _EmptyState(
          icon: Icons.directions_bus_outlined,
          text: 'Choisissez votre trajet puis lancez la recherche.',
        ),
      ];
    }
    if (results.isEmpty) {
      return const [
        _EmptyState(
          icon: Icons.search_off,
          text: 'Aucun trajet disponible pour cet itinéraire à cette date.',
        ),
      ];
    }
    return [
      Text(
        '${results.length} trajet${results.length > 1 ? 's' : ''} · ${formatDate(_date)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      for (final trip in results)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TripCard(trip: trip, onBook: () => _book(trip)),
        ),
    ];
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
