import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models.dart';
import '../utils/format.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Client HTTP de l'API VoyageCM.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  /// Jeton JWT de la session admin/agence en cours.
  String? token;

  /// Appelé quand le serveur refuse le jeton (session expirée).
  void Function()? onUnauthorized;

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(const Duration(seconds: 20)),
      );
    } on TimeoutException {
      throw const ApiException(
        'Le serveur ne répond pas. Réessayez dans un instant.',
      );
    } on Exception {
      throw const ApiException(
        'Impossible de joindre le serveur. Vérifiez votre connexion Internet.',
      );
    }

    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    if (response.statusCode == 401 && token != null) onUnauthorized?.call();
    throw ApiException(
      _errorMessage(text) ?? 'Erreur inattendue (${response.statusCode}).',
      response.statusCode,
    );
  }

  /// Extrait le message lisible d'une erreur FastAPI.
  static String? _errorMessage(String text) {
    try {
      final detail = (jsonDecode(text) as Map<String, dynamic>)['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final msg =
            (detail.first as Map<String, dynamic>)['msg'] as String? ?? '';
        return msg.replaceFirst('Value error, ', '');
      }
    } catch (_) {}
    return null;
  }

  Future<List<dynamic>> _list(
    String path, {
    Map<String, String>? query,
  }) async => (await _send('GET', path, query: query)) as List<dynamic>;

  Future<Map<String, dynamic>> _object(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async =>
      (await _send(method, path, query: query, body: body))
          as Map<String, dynamic>;

  // --- Public -----------------------------------------------------------------

  Future<List<City>> cities() async => (await _list(
    '/cities',
  )).map((e) => City.fromJson(e as Map<String, dynamic>)).toList();

  Future<List<Agency>> agencies() async => (await _list(
    '/agencies',
  )).map((e) => Agency.fromJson(e as Map<String, dynamic>)).toList();

  Future<List<Trip>> searchTrips({
    required int departureCityId,
    required int arrivalCityId,
    required DateTime date,
  }) async {
    final rows = await _list(
      '/trips/search',
      query: {
        'departure_city_id': '$departureCityId',
        'arrival_city_id': '$arrivalCityId',
        'travel_date': apiDate(date),
      },
    );
    return rows.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SeatMap> seatMap(int tripId, DateTime date) async => SeatMap.fromJson(
    await _object(
      'GET',
      '/trips/$tripId/seats',
      query: {'travel_date': apiDate(date)},
    ),
  );

  Future<Booking> createBooking({
    required int tripId,
    required DateTime date,
    required int seatNumber,
    required String passengerName,
    required String passengerCni,
    required String passengerPhone,
    required PaymentMethod paymentMethod,
  }) async => Booking.fromJson(
    await _object(
      'POST',
      '/bookings',
      body: {
        'trip_id': tripId,
        'travel_date': apiDate(date),
        'seat_number': seatNumber,
        'passenger_name': passengerName,
        'passenger_cni': passengerCni,
        'passenger_phone': passengerPhone,
        'payment_method': paymentMethod.value,
      },
    ),
  );

  Future<Booking> booking(String code) async => Booking.fromJson(
    await _object('GET', '/bookings/${Uri.encodeComponent(code.trim())}'),
  );

  // --- Authentification ---------------------------------------------------------

  /// Retourne le jeton et la session.
  Future<(String, UserSession)> login(String username, String password) async {
    final json = await _object(
      'POST',
      '/auth/login',
      body: {'username': username, 'password': password},
    );
    return (json['access_token'] as String, UserSession.fromJson(json));
  }

  Future<UserSession> me() async =>
      UserSession.fromJson(await _object('GET', '/auth/me'));

  // --- Espace agence -------------------------------------------------------------

  Future<List<Trip>> agencyTrips() async => (await _list(
    '/agency/trips',
  )).map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();

  Future<Trip> createTrip(Map<String, dynamic> data) async =>
      Trip.fromJson(await _object('POST', '/agency/trips', body: data));

  Future<Trip> updateTrip(int id, Map<String, dynamic> data) async =>
      Trip.fromJson(await _object('PUT', '/agency/trips/$id', body: data));

  Future<void> deleteTrip(int id) => _send('DELETE', '/agency/trips/$id');

  Future<List<Passenger>> passengers(int tripId, DateTime date) async =>
      (await _list(
        '/agency/trips/$tripId/passengers',
        query: {'travel_date': apiDate(date)},
      )).map((e) => Passenger.fromJson(e as Map<String, dynamic>)).toList();

  // --- Administration ------------------------------------------------------------

  Future<AdminStats> adminStats() async =>
      AdminStats.fromJson(await _object('GET', '/admin/stats'));

  Future<List<Trip>> adminTrips() async => (await _list(
    '/admin/trips',
  )).map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();

  Future<AgencyCredentials> createAgency(Map<String, dynamic> data) async =>
      AgencyCredentials.fromJson(
        await _object('POST', '/admin/agencies', body: data),
      );
}
