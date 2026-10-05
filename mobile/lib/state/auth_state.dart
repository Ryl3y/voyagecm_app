import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../models.dart';

/// Session admin/agence, avec jeton conservé dans le stockage sécurisé du téléphone.
class AuthState extends ChangeNotifier {
  AuthState(this._api, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage() {
    _api.onUnauthorized = () => logout();
  }

  static const _tokenKey = 'auth_token';

  final ApiClient _api;
  final FlutterSecureStorage _storage;

  UserSession? _session;
  bool _restoring = true;

  UserSession? get session => _session;
  bool get restoring => _restoring;

  /// Recharge la session enregistrée au démarrage de l'app.
  Future<void> restore() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        _api.token = token;
        _session = await _api.me();
      }
    } catch (_) {
      _api.token = null;
      _session = null;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    final (token, session) = await _api.login(username.trim(), password);
    _api.token = token;
    _session = session;
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    _api.token = null;
    _session = null;
    notifyListeners();
    await _storage.delete(key: _tokenKey);
  }
}
