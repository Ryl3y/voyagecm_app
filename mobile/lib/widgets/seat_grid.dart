import 'package:flutter/material.dart';

/// Plan du bus : rangées de 2 + 2 sièges séparées par l'allée.
class SeatGrid extends StatelessWidget {
  const SeatGrid({
    super.key,
    required this.capacity,
    required this.occupied,
    required this.selected,
    required this.onSelect,
  });

  final int capacity;
  final Set<int> occupied;
  final int? selected;
  final ValueChanged<int> onSelect;

  static const _perRow = 4;

  @override
  Widget build(BuildContext context) {
    final rows = (capacity / _perRow).ceil();
    return Column(
      children: [
        const _Legend(),
        const SizedBox(height: 12),
        for (var r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var c = 0; c < _perRow; c++) ...[
                  if (c == 2) const SizedBox(width: 28), // allée
                  _seatAt(context, r * _perRow + c + 1),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _seatAt(BuildContext context, int number) {
    if (number > capacity) return const SizedBox(width: 50, height: 44);
    return _Seat(
      number: number,
      occupied: occupied.contains(number),
      selected: selected == number,
      onTap: () => onSelect(number),
    );
  }
}

class _Seat extends StatelessWidget {
  const _Seat({
    required this.number,
    required this.occupied,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool occupied;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = occupied
        ? (scheme.errorContainer, scheme.onErrorContainer)
        : selected
        ? (scheme.primary, scheme.onPrimary)
        : (scheme.primaryContainer, scheme.onPrimaryContainer);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Semantics(
        button: true,
        selected: selected,
        enabled: !occupied,
        label: 'Siège $number, ${occupied ? 'occupé' : 'disponible'}',
        excludeSemantics: true,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: occupied ? null : onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: occupied
                    ? Icon(Icons.close, size: 18, color: fg)
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        item(scheme.primaryContainer, 'Disponible'),
        item(scheme.primary, 'Votre choix'),
        item(scheme.errorContainer, 'Occupé'),
      ],
    );
  }
}
