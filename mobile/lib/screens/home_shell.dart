import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'pro/pro_screen.dart';
import 'search_screen.dart';
import 'ticket_lookup_screen.dart';

/// Navigation principale par onglets.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    SearchScreen(),
    TicketLookupScreen(),
    AboutScreen(),
    ProScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Rechercher'),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Mon billet',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            label: 'À propos',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            label: 'Espace pro',
          ),
        ],
      ),
    );
  }
}
