import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/agency_title.dart';
import '../widgets/async_view.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Découvrez VoyageCM'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pourquoi nous ?'),
              Tab(text: 'Agences partenaires'),
              Tab(text: 'Mobile Money'),
              Tab(text: 'Sécurité'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WhyUsTab(),
            _PartnersTab(),
            _PaymentTab(),
            _SecurityTab(),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {this.icon = Icons.check_circle_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: child),
            const SizedBox(height: 8),
            Text(
              'Chiffres indicatifs',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WhyUsTab extends StatelessWidget {
  const _WhyUsTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Page(
      title: 'Simplicité, transparence et confiance',
      children: [
        const Text(
          'VoyageCM simplifie vos voyages interurbains au Cameroun : nous vous connectons avec des agences '
          'vérifiées pour une réservation transparente, sécurisée et pratique.',
        ),
        const SizedBox(height: 12),
        const _Bullet(
          'Une application intuitive pour trouver et comparer les trajets.',
        ),
        const _Bullet(
          'Des informations claires sur les horaires, tarifs et services.',
        ),
        const _Bullet('Une réservation rapide, avec choix de votre siège.'),
        const _Bullet(
          "La mise en avant d'agences engagées pour la qualité et la sécurité.",
        ),
        const SizedBox(height: 12),
        const Text(
          'Le transport routier représente la grande majorité des déplacements interurbains au Cameroun. '
          'Notre application est conçue pour améliorer cette expérience essentielle.',
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Prédominance du transport routier au Cameroun',
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 36,
                    sectionsSpace: 2,
                    sections: [
                      PieChartSectionData(
                        value: 85,
                        color: brandGreen,
                        title: '85 %',
                        radius: 56,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: 15,
                        color: const Color(0xFFA7F3D0),
                        title: '15 %',
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                    color: brandGreen,
                    label: 'Transport routier',
                    textColor: scheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(
                    color: const Color(0xFFA7F3D0),
                    label: 'Autres modes',
                    textColor: scheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.textColor,
  });

  final Color color;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: textColor)),
      ],
    );
  }
}

class _PartnersTab extends StatefulWidget {
  const _PartnersTab();

  @override
  State<_PartnersTab> createState() => _PartnersTabState();
}

class _PartnersTabState extends State<_PartnersTab> {
  late Future<List<Agency>> _future = context.read<ApiClient>().agencies();

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Nos agences partenaires de confiance',
      children: [
        const Text(
          'Nous collaborons avec des agences reconnues pour leur sérieux et la qualité de leurs services. '
          'Notre processus de vérification assure que les agences listées respectent les normes de sécurité '
          'et de conformité.',
        ),
        const SizedBox(height: 16),
        FutureView<List<Agency>>(
          future: _future,
          onRetry: () =>
              setState(() => _future = context.read<ApiClient>().agencies()),
          builder: (context, agencies) => Column(
            children: [
              for (final agency in agencies)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AgencyTitle(agency: agency),
                        if (agency.description != null) ...[
                          const SizedBox(height: 4),
                          Text(agency.description!),
                        ],
                        if (agency.services.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            agency.services.join(' · '),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentTab extends StatelessWidget {
  const _PaymentTab();

  static const _years = ['2017', '2018', '2019', '2020', '2021', '2022'];
  static const _adoption = [29.9, 33.5, 37.0, 39.5, 41.0, 42.7];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Page(
      title: 'Paiement facile avec Mobile Money',
      children: [
        const Text(
          'Au Cameroun, Mobile Money est devenu un moyen de paiement incontournable, apprécié pour sa '
          'simplicité et son accessibilité. VoyageCM accepte :',
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Chip(
              label: Text('MTN MoMo'),
              backgroundColor: mtnYellow,
              labelStyle: TextStyle(color: Colors.black),
            ),
            SizedBox(width: 8),
            Chip(
              label: Text('Orange Money'),
              backgroundColor: orangeMoney,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dans cette version, le paiement est simulé : aucun montant n\'est débité.',
          style: TextStyle(color: scheme.outline),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: "Croissance de l'adoption du Mobile Money (%)",
          child: LineChart(
            LineChartData(
              minY: 25,
              maxY: 45,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 5,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= _years.length || value != i) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _years[i],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < _adoption.length; i++)
                      FlSpot(i.toDouble(), _adoption[i]),
                  ],
                  color: orangeMoney,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityTab extends StatelessWidget {
  const _SecurityTab();

  @override
  Widget build(BuildContext context) {
    return const _Page(
      title: 'Votre sécurité, notre priorité',
      children: [
        Text(
          'La sécurité est une préoccupation majeure des voyageurs. C\'est pourquoi nous nous engageons à :',
        ),
        SizedBox(height: 12),
        _Bullet(
          "Travailler avec des agences qui respectent les normes de sécurité et les réglementations en vigueur.",
          icon: Icons.verified_user_outlined,
        ),
        _Bullet(
          'Promouvoir la transparence : informations claires sur les agences et leurs services.',
          icon: Icons.visibility_outlined,
        ),
        _Bullet(
          'Protéger vos données : votre numéro de CNI est masqué sur le billet.',
          icon: Icons.lock_outline,
        ),
        _Bullet(
          "Encourager les retours d'expérience pour améliorer la qualité des services (bientôt disponible).",
          icon: Icons.reviews_outlined,
        ),
        SizedBox(height: 12),
        Text(
          'En choisissant VoyageCM, vous optez pour des déplacements fiables et sereins.',
        ),
      ],
    );
  }
}
