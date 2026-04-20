import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ⚠️ Cambia esta IP por la de tu computadora en la red local
  // Ejemplo: 'http://192.168.1.100:8080'
  // Para encontrar tu IP en Windows: abre CMD y escribe "ipconfig"
  // busca "Dirección IPv4" en tu adaptador de red activo
  static const String _baseUrl = 'http://192.168.8.73:8080';

  static const String _tokenKey = 'auth_token';
  static const String _nombreKey = 'user_nombre';
  static const String _correoKey = 'user_correo';

  // ── Registro ─────────────────────────────────────────────────

  Future<AuthResult> register({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': nombre,
              'correo': correo,
              'contrasena': contrasena,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        await _saveSession(body);
        return AuthResult.success(body['mensaje'] ?? 'Registro exitoso');
      } else {
        return AuthResult.error(body['error'] ?? 'Error al registrarse');
      }
    } catch (e) {
      return AuthResult.error(
          'No se pudo conectar al servidor. Verifica tu conexión.');
    }
  }

  // ── Login ─────────────────────────────────────────────────────

  Future<AuthResult> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'correo': correo,
              'contrasena': contrasena,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _saveSession(body);
        return AuthResult.success(body['mensaje'] ?? 'Bienvenido');
      } else {
        return AuthResult.error(
            body['error'] ?? 'Correo o contraseña incorrectos');
      }
    } catch (e) {
      return AuthResult.error(
          'No se pudo conectar al servidor. Verifica tu conexión.');
    }
  }

  // ── Cerrar sesión ─────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nombreKey);
    await prefs.remove(_correoKey);
  }

  // ── Verificar sesión activa ───────────────────────────────────

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nombreKey);
  }

  // ── Helpers privados ──────────────────────────────────────────

  Future<void> _saveSession(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, body['token'] ?? '');
    await prefs.setString(_nombreKey, body['nombre'] ?? '');
    await prefs.setString(_correoKey, body['correo'] ?? '');
  }
}

// ── Resultado de auth ─────────────────────────────────────────────────────────

class AuthResult {
  final bool success;
  final String message;

  AuthResult._(this.success, this.message);
  factory AuthResult.success(String msg) => AuthResult._(true, msg);
  factory AuthResult.error(String msg) => AuthResult._(false, msg);
}
