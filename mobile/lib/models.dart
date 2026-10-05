/// Modèles de données échangés avec l'API.
library;

String _hhmm(String value) => value.length >= 5 ? value.substring(0, 5) : value;

class City {
  const City({required this.id, required this.name});

  final int id;
  final String name;

  factory City.fromJson(Map<String, dynamic> json) =>
      City(id: json['id'] as int, name: json['name'] as String);
}

extension CityList on List<City> {
  int? idOf(String name) => where((c) => c.name == name).firstOrNull?.id;
}

class Agency {
  const Agency({
    required this.id,
    required this.name,
    required this.logo,
    required this.verified,
    required this.services,
    this.imageUrl,
    this.description,
  });

  final int id;
  final String name;
  final String logo;
  final bool verified;
  final List<String> services;
  final String? imageUrl;
  final String? description;

  factory Agency.fromJson(Map<String, dynamic> json) => Agency(
    id: json['id'] as int,
    name: json['name'] as String,
    logo: json['logo'] as String,
    verified: json['verified'] as bool,
    services: (json['services'] as List).cast<String>(),
    imageUrl: json['image_url'] as String?,
    description: json['description'] as String?,
  );
}

enum TripClass {
  classique('Classique', null),
  confort('Confort', 'Toilettes'),
  vip('VIP', 'Climatisé'),
  zoom('Zoom', '50 places');

  const TripClass(this.value, this.feature);

  /// Valeur envoyée à l'API.
  final String value;

  /// Particularité affichée à côté de la classe.
  final String? feature;

  String get label => feature == null ? value : '$value ($feature)';

  static TripClass fromValue(String value) =>
      TripClass.values.firstWhere((c) => c.value == value);
}

class Trip {
  const Trip({
    required this.id,
    required this.code,
    required this.agency,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.tripClass,
    required this.capacity,
    this.travelDate,
    this.availableSeats,
  });

  final int id;
  final String? code;
  final Agency agency;
  final String departureCity;
  final String arrivalCity;

  /// Heures au format HH:mm.
  final String departureTime;
  final String arrivalTime;
  final int price;
  final TripClass tripClass;
  final int capacity;

  /// Renseignés seulement dans les résultats de recherche.
  final DateTime? travelDate;
  final int? availableSeats;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as int,
    code: json['code'] as String?,
    agency: Agency.fromJson(json['agency'] as Map<String, dynamic>),
    departureCity: json['departure_city'] as String,
    arrivalCity: json['arrival_city'] as String,
    departureTime: _hhmm(json['departure_time'] as String),
    arrivalTime: _hhmm(json['arrival_time'] as String),
    price: json['price'] as int,
    tripClass: TripClass.fromValue(json['trip_class'] as String),
    capacity: json['capacity'] as int,
    travelDate: json['travel_date'] == null
        ? null
        : DateTime.parse(json['travel_date'] as String),
    availableSeats: json['available_seats'] as int?,
  );
}

class SeatMap {
  const SeatMap({required this.capacity, required this.occupied});

  final int capacity;
  final Set<int> occupied;

  factory SeatMap.fromJson(Map<String, dynamic> json) => SeatMap(
    capacity: json['capacity'] as int,
    occupied: (json['occupied'] as List).cast<int>().toSet(),
  );
}

enum PaymentMethod {
  mtn('mtn', 'MTN MoMo'),
  orange('orange', 'Orange Money');

  const PaymentMethod(this.value, this.label);

  final String value;
  final String label;

  static PaymentMethod fromValue(String value) =>
      PaymentMethod.values.firstWhere((p) => p.value == value);
}

class Booking {
  const Booking({
    required this.code,
    required this.trip,
    required this.travelDate,
    required this.seatNumber,
    required this.passengerName,
    required this.passengerCniMasked,
    required this.passengerPhone,
    required this.paymentMethod,
    required this.amount,
  });

  final String code;
  final Trip trip;
  final DateTime travelDate;
  final int seatNumber;
  final String passengerName;
  final String passengerCniMasked;
  final String passengerPhone;
  final PaymentMethod paymentMethod;
  final int amount;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    code: json['code'] as String,
    trip: Trip.fromJson(json['trip'] as Map<String, dynamic>),
    travelDate: DateTime.parse(json['travel_date'] as String),
    seatNumber: json['seat_number'] as int,
    passengerName: json['passenger_name'] as String,
    passengerCniMasked: json['passenger_cni_masked'] as String,
    passengerPhone: json['passenger_phone'] as String,
    paymentMethod: PaymentMethod.fromValue(json['payment_method'] as String),
    amount: json['amount'] as int,
  );
}

class Passenger {
  const Passenger({
    required this.code,
    required this.seatNumber,
    required this.name,
    required this.phone,
    required this.paymentMethod,
  });

  final String code;
  final int seatNumber;
  final String name;
  final String phone;
  final PaymentMethod paymentMethod;

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
    code: json['code'] as String,
    seatNumber: json['seat_number'] as int,
    name: json['passenger_name'] as String,
    phone: json['passenger_phone'] as String,
    paymentMethod: PaymentMethod.fromValue(json['payment_method'] as String),
  );
}

enum UserRole { admin, agency }

class UserSession {
  const UserSession({
    required this.username,
    required this.role,
    this.agencyId,
    this.agencyName,
  });

  final String username;
  final UserRole role;
  final int? agencyId;
  final String? agencyName;

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    username: json['username'] as String,
    role: UserRole.values.byName(json['role'] as String),
    agencyId: json['agency_id'] as int?,
    agencyName: json['agency_name'] as String?,
  );
}

class AdminStats {
  const AdminStats({
    required this.totalTrips,
    required this.totalAgencies,
    required this.bookingsToday,
    required this.availableSeatsToday,
    required this.revenueToday,
  });

  final int totalTrips;
  final int totalAgencies;
  final int bookingsToday;
  final int availableSeatsToday;
  final int revenueToday;

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalTrips: json['total_trips'] as int,
    totalAgencies: json['total_agencies'] as int,
    bookingsToday: json['bookings_today'] as int,
    availableSeatsToday: json['available_seats_today'] as int,
    revenueToday: json['revenue_today'] as int,
  );
}

class AgencyCredentials {
  const AgencyCredentials({
    required this.agency,
    required this.username,
    required this.password,
  });

  final Agency agency;
  final String username;
  final String password;

  factory AgencyCredentials.fromJson(Map<String, dynamic> json) =>
      AgencyCredentials(
        agency: Agency.fromJson(json['agency'] as Map<String, dynamic>),
        username: json['username'] as String,
        password: json['password'] as String,
      );
}
