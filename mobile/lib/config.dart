/// Adresse de l'API. À fournir au lancement :
///   flutter run --dart-define=API_URL=http://192.168.1.10:8000
/// Par défaut : l'ordinateur hôte vu depuis l'émulateur Android.
class AppConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
