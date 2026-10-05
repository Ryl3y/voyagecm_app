import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/agency_title.dart';
import '../widgets/async_view.dart';
import '../widgets/seat_grid.dart';
import 'confirmation_screen.dart';

/// Choix du siège, informations du passager et paiement (simulé).
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.trip, required this.date});

  final Trip trip;
  final DateTime date;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cni = TextEditingController();
  final _phone = TextEditingController();

  late Future<SeatMap> _seatsFuture;
  int? _seat;
  PaymentMethod _payment = PaymentMethod.mtn;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  @override
  void dispose() {
    _name.dispose();
    _cni.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _loadSeats() {
    _seatsFuture = context.read<ApiClient>().seatMap(
      widget.trip.id,
      widget.date,
    );
  }

  Future<void> _submit() async {
    if (_seat == null) {
      showError(
        context,
        const ApiException('Veuillez sélectionner un numéro de siège.'),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final booking = await context.read<ApiClient>().createBooking(
        tripId: widget.trip.id,
        date: widget.date,
        seatNumber: _seat!,
        passengerName: _name.text,
        passengerCni: _cni.text,
        passengerPhone: _phone.text,
        paymentMethod: _payment,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ConfirmationScreen(booking: booking),
        ),
        result: true,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        // Siège pris entre-temps : on recharge le plan.
        setState(() {
          _seat = null;
          _loadSeats();
        });
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Siège occupé'),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Réserver votre billet')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AgencyTitle(agency: trip.agency),
                    const SizedBox(height: 8),
                    Text(
                      '${trip.departureCity} → ${trip.arrivalCity}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${formatLongDate(widget.date)} · ${trip.departureTime} → ${trip.arrivalTime}',
                    ),
                    Text('Classe ${trip.tripClass.label}'),
                    const SizedBox(height: 8),
                    Text(
                      formatPrice(trip.price),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _section('1. Choisissez votre siège (${trip.capacity} places)'),
            FutureView<SeatMap>(
              future: _seatsFuture,
              onRetry: () => setState(_loadSeats),
              builder: (context, map) {
                if (map.occupied.length >= map.capacity) {
                  return Text(
                    "Désolé, il n'y a plus de sièges disponibles pour ce trajet.",
                    style: TextStyle(color: theme.colorScheme.error),
                  );
                }
                return SeatGrid(
                  capacity: map.capacity,
                  occupied: map.occupied,
                  selected: _seat,
                  onSelect: (s) => setState(() => _seat = s),
                );
              },
            ),
            if (_seat != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Siège sélectionné : $_seat',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            const SizedBox(height: 24),
            _section('2. Informations du passager'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Veuillez entrer le nom complet du passager.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cni,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Numéro de CNI',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => cniRegExp.hasMatch((v ?? '').trim())
                  ? null
                  : 'Numéro de CNI invalide (6 à 20 lettres ou chiffres).',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: '6XX XX XX XX',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  phoneRegExp.hasMatch(
                    (v ?? '').replaceAll(RegExp(r'[\s.-]'), ''),
                  )
                  ? null
                  : 'Numéro camerounais invalide (ex : 677123456).',
            ),
            const SizedBox(height: 24),
            _section('3. Paiement Mobile Money'),
            SegmentedButton<PaymentMethod>(
              segments: [
                for (final p in PaymentMethod.values)
                  ButtonSegment(
                    value: p,
                    label: Text(p.label),
                    icon: Icon(
                      Icons.circle,
                      color: p == PaymentMethod.mtn ? mtnYellow : orangeMoney,
                    ),
                  ),
              ],
              selected: {_payment},
              onSelectionChanged: (s) => setState(() => _payment = s.first),
            ),
            const SizedBox(height: 8),
            Text(
              'Paiement simulé dans cette version : aucun montant ne sera débité.',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),
            BusyButton(
              busy: _submitting,
              onPressed: _submit,
              label: 'Confirmer et payer ${formatPrice(trip.price)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}
