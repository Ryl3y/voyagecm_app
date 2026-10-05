import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyagecm/models.dart';
import 'package:voyagecm/widgets/seat_grid.dart';

void main() {
  test('Trip.fromJson lit la réponse de recherche de l\'API', () {
    final trip = Trip.fromJson({
      'id': 31,
      'code': 'R031',
      'agency': {
        'id': 1,
        'name': 'Touristique Express',
        'logo': '🚌',
        'verified': true,
        'services': ['VIP', 'Climatisé'],
        'image_url': null,
        'description': null,
      },
      'departure_city': 'Yaoundé',
      'arrival_city': 'Douala',
      'departure_time': '16:00:00',
      'arrival_time': '20:00:00',
      'price': 7500,
      'trip_class': 'Zoom',
      'capacity': 50,
      'active': true,
      'travel_date': '2026-10-03',
      'available_seats': 49,
    });
    expect(trip.departureTime, '16:00');
    expect(trip.tripClass, TripClass.zoom);
    expect(trip.tripClass.label, 'Zoom (50 places)');
    expect(trip.availableSeats, 49);
    expect(trip.travelDate, DateTime(2026, 10, 3));
  });

  testWidgets('SeatGrid : un siège occupé ne peut pas être choisi', (
    tester,
  ) async {
    int? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SeatGrid(
              capacity: 50,
              occupied: const {2},
              selected: null,
              onSelect: (s) => chosen = s,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('1'));
    expect(chosen, 1);

    chosen = null;
    await tester.tap(find.bySemanticsLabel('Siège 2, occupé'));
    expect(chosen, isNull);

    expect(find.text('50'), findsOneWidget);
    expect(find.text('51'), findsNothing);
  });
}
