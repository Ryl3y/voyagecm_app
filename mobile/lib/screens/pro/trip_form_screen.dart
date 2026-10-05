import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../api/api_client.dart';
import '../../models.dart';
import '../../utils/format.dart';
import '../../widgets/async_view.dart';

/// Création (trip == null) ou modification d'un trajet par une agence.
class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key, this.trip});

  final Trip? trip;

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _price = TextEditingController(
    text: widget.trip?.price.toString() ?? '',
  );
  late Future<List<City>> _citiesFuture = context.read<ApiClient>().cities();

  int? _departureId;
  int? _arrivalId;
  late TimeOfDay? _departureTime = widget.trip == null
      ? null
      : parseTime(widget.trip!.departureTime);
  late TimeOfDay? _arrivalTime = widget.trip == null
      ? null
      : parseTime(widget.trip!.arrivalTime);
  late TripClass _class = widget.trip?.tripClass ?? TripClass.classique;
  bool _saving = false;

  bool get _editing => widget.trip != null;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool departure) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (departure ? _departureTime : _arrivalTime) ??
          const TimeOfDay(hour: 8, minute: 0),
      helpText: departure ? 'Heure de départ' : "Heure d'arrivée (estimée)",
    );
    if (picked == null) return;
    setState(() => departure ? _departureTime = picked : _arrivalTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureTime == null || _arrivalTime == null) {
      showError(
        context,
        const ApiException("Indiquez l'heure de départ et l'heure d'arrivée."),
      );
      return;
    }
    final data = {
      'departure_city_id': _departureId,
      'arrival_city_id': _arrivalId,
      'departure_time': formatTime(_departureTime!),
      'arrival_time': formatTime(_arrivalTime!),
      'price': int.parse(_price.text),
      'trip_class': _class.value,
    };
    setState(() => _saving = true);
    try {
      final api = context.read<ApiClient>();
      _editing
          ? await api.updateTrip(widget.trip!.id, data)
          : await api.createTrip(data);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Modifier le trajet' : 'Nouveau trajet'),
      ),
      body: FutureView<List<City>>(
        future: _citiesFuture,
        onRetry: () =>
            setState(() => _citiesFuture = context.read<ApiClient>().cities()),
        builder: (context, cities) {
          if (_editing) {
            _departureId ??= cities.idOf(widget.trip!.departureCity);
            _arrivalId ??= cities.idOf(widget.trip!.arrivalCity);
          }
          return _buildForm(cities);
        },
      ),
    );
  }

  Widget _buildForm(List<City> cities) {
    final items = [
      for (final c in cities)
        DropdownMenuItem(value: c.id, child: Text(c.name)),
    ];
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _departureId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Ville de départ'),
            items: items,
            onChanged: (v) => setState(() => _departureId = v),
            validator: (v) => v == null ? 'Sélectionnez une ville.' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _arrivalId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: "Ville d'arrivée"),
            items: items,
            onChanged: (v) => setState(() => _arrivalId = v),
            validator: (v) {
              if (v == null) return 'Sélectionnez une ville.';
              if (v == _departureId) {
                return 'Doit être différente de la ville de départ.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _timeField(
                  'Départ',
                  _departureTime,
                  () => _pickTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timeField(
                  'Arrivée (estimée)',
                  _arrivalTime,
                  () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _price,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Prix',
              suffixText: 'XAF',
            ),
            validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                ? 'Indiquez un prix valide.'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TripClass>(
            initialValue: _class,
            decoration: const InputDecoration(labelText: 'Classe'),
            items: [
              for (final c in TripClass.values)
                DropdownMenuItem(value: c, child: Text(c.label)),
            ],
            onChanged: (v) => setState(() => _class = v ?? _class),
          ),
          const SizedBox(height: 8),
          Text(
            _class == TripClass.zoom
                ? 'Bus Zoom : 50 places.'
                : 'Bus standard : 70 places.',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: 24),
          BusyButton(
            busy: _saving,
            onPressed: _submit,
            label: _editing ? 'Enregistrer' : 'Ajouter le trajet',
          ),
        ],
      ),
    );
  }

  Widget _timeField(String label, TimeOfDay? value, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.schedule),
          ),
          child: Text(value == null ? '--:--' : formatTime(value)),
        ),
      );
}
