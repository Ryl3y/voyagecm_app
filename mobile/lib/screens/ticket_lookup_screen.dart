import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../models.dart';
import '../utils/format.dart';
import '../widgets/async_view.dart';
import '../widgets/ticket_card.dart';

/// Retrouver un billet à partir de son code de réservation.
class TicketLookupScreen extends StatefulWidget {
  const TicketLookupScreen({super.key});

  @override
  State<TicketLookupScreen> createState() => _TicketLookupScreenState();
}

class _TicketLookupScreenState extends State<TicketLookupScreen> {
  final _code = TextEditingController();
  Booking? _booking;
  bool _loading = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _booking = null;
    });
    try {
      final booking = await context.read<ApiClient>().booking(code);
      if (mounted) setState(() => _booking = booking);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon billet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _find(),
            decoration: const InputDecoration(
              labelText: 'Code de réservation',
              hintText: 'CM-123456-S12',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
          ),
          const SizedBox(height: 12),
          BusyButton(
            busy: _loading,
            onPressed: _find,
            label: 'Retrouver mon billet',
          ),
          const SizedBox(height: 16),
          if (_booking != null) TicketCard(booking: _booking!),
        ],
      ),
    );
  }
}
