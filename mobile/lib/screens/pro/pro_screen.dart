import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import '../../state/auth_state.dart';
import 'admin_dashboard.dart';
import 'agency_dashboard.dart';
import 'login_view.dart';

/// Onglet « Espace pro » : connexion puis tableau de bord selon le rôle.
class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (auth.restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final session = auth.session;
    if (session == null) return const LoginView();
    return switch (session.role) {
      UserRole.admin => const AdminDashboard(),
      UserRole.agency => AgencyDashboard(
        agencyName: session.agencyName ?? 'Agence',
      ),
    };
  }
}

/// Bouton de déconnexion commun aux deux tableaux de bord.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Déconnexion',
      icon: const Icon(Icons.logout),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Voulez-vous vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await context.read<AuthState>().logout();
        }
      },
    );
  }
}
