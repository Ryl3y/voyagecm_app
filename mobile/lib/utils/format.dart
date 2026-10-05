import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';

final _price = NumberFormat.decimalPattern('fr');

String formatPrice(int amount) => '${_price.format(amount)} XAF';

/// Ex. : « jeu. 2 oct. 2026 »
String formatDate(DateTime date) =>
    DateFormat('EEE d MMM y', 'fr').format(date);

/// Ex. : « jeudi 2 octobre 2026 »
String formatLongDate(DateTime date) =>
    DateFormat('EEEE d MMMM y', 'fr').format(date);

/// Format attendu par l'API : AAAA-MM-JJ.
String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

TimeOfDay parseTime(String hhmm) {
  final parts = hhmm.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String errorText(Object error) => error is ApiException
    ? error.message
    : 'Une erreur est survenue. Veuillez réessayer.';

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(errorText(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

/// Mêmes règles que le serveur.
final phoneRegExp = RegExp(r'^(\+?237)?[26]\d{8}$');
final cniRegExp = RegExp(r'^[A-Za-z0-9]{6,20}$');
