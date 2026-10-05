import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_client.dart';
import '../../utils/format.dart';
import '../../widgets/async_view.dart';

/// Ajout d'une agence par l'administrateur. Retourne les identifiants générés.
class AgencyFormScreen extends StatefulWidget {
  const AgencyFormScreen({super.key});

  @override
  State<AgencyFormScreen> createState() => _AgencyFormScreenState();
}

class _AgencyFormScreenState extends State<AgencyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _logo = TextEditingController(text: '🚌');
  final _services = TextEditingController();
  final _imageUrl = TextEditingController();
  final _description = TextEditingController();
  bool _verified = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _logo, _services, _imageUrl, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final created = await context.read<ApiClient>().createAgency({
        'name': _name.text.trim(),
        'logo': _logo.text.trim().isEmpty ? '🚌' : _logo.text.trim(),
        'verified': _verified,
        'services': _services.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'image_url': _imageUrl.text.trim().isEmpty
            ? null
            : _imageUrl.text.trim(),
        'description': _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(created);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle agence')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: "Nom de l'agence"),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Nom trop court.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _logo,
              decoration: const InputDecoration(
                labelText: 'Logo (emoji ou texte court)',
              ),
              validator: (v) => (v != null && v.length > 16)
                  ? '16 caractères maximum.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _services,
              decoration: const InputDecoration(
                labelText: 'Services (séparés par des virgules)',
                hintText: 'VIP, Climatisé, Toilettes',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: "URL de l'image du bus (facultatif)",
              ),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return null;
                final uri = Uri.tryParse(value);
                return (uri != null &&
                        (uri.scheme == 'http' || uri.scheme == 'https') &&
                        uri.host.isNotEmpty)
                    ? null
                    : 'URL invalide (doit commencer par https://).';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 2,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Description (lignes desservies, points forts)',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Agence vérifiée'),
              value: _verified,
              onChanged: (v) => setState(() => _verified = v),
            ),
            const SizedBox(height: 16),
            BusyButton(
              busy: _saving,
              onPressed: _submit,
              label: "Ajouter l'agence",
            ),
          ],
        ),
      ),
    );
  }
}
