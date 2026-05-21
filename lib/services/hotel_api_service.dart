import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habitacion.dart';
import '../models/reserva.dart';
import 'api_config.dart';
import 'auth_service.dart';

class HotelApiException implements Exception {
  final String message;
  HotelApiException(this.message);
  @override
  String toString() => message;
}

class HotelApiService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _auth.getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final body = _decode(response);
      if (body is Map && body['error'] != null) return body['error'].toString();
    } catch (_) {}
    return fallback;
  }

  Future<List<Habitacion>> listarDisponibles() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/habitaciones/disponibles'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudieron cargar las habitaciones'));
    }
    return (_decode(response) as List)
        .map((e) => Habitacion.fromJson(e))
        .toList();
  }

  Future<List<Habitacion>> listarTodasHabitaciones() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/habitaciones'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudieron cargar las habitaciones'));
    }
    return (_decode(response) as List)
        .map((e) => Habitacion.fromJson(e))
        .toList();
  }

  Future<Habitacion> crearHabitacion({
    required String numero,
    required String tipo,
    required String descripcion,
    required double precio,
    required bool disponible,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/habitaciones'),
      headers: await _headers(),
      body: jsonEncode({
        'numero': numero,
        'tipo': tipo,
        'descripcion': descripcion,
        'precio': precio,
        'disponible': disponible,
      }),
    );
    if (response.statusCode != 201) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudo crear la habitaciĆ³n'));
    }
    return Habitacion.fromJson(_decode(response));
  }

  Future<void> eliminarHabitacion(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/habitaciones/$id'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 204) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudo eliminar la habitaciĆ³n'));
    }
  }

  Future<Reserva> crearReserva({
    required int habitacionId,
    required DateTime fechaEntrada,
    required DateTime fechaSalida,
    required int adultos,
    required int ninos,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/reservas'),
      headers: await _headers(),
      body: jsonEncode({
        'habitacionId': habitacionId,
        'fechaEntrada': _date(fechaEntrada),
        'fechaSalida': _date(fechaSalida),
        'adultos': adultos,
        'ninos': ninos,
      }),
    );
    if (response.statusCode != 201) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudo crear la reserva'));
    }
    return Reserva.fromJson(_decode(response));
  }

  Future<List<Reserva>> misReservas() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reservas/mis-reservas'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudieron cargar tus reservas'));
    }
    return (_decode(response) as List).map((e) => Reserva.fromJson(e)).toList();
  }

  Future<List<Reserva>> listarTodasReservas() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reservas'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudieron cargar las reservas'));
    }
    return (_decode(response) as List).map((e) => Reserva.fromJson(e)).toList();
  }

  Future<Reserva> cancelarReserva(int id) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/reservas/$id/cancelar'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudo cancelar la reserva'));
    }
    return Reserva.fromJson(_decode(response));
  }

  Future<Reserva> confirmarReserva(int id) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/reservas/$id/confirmar'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) {
      throw HotelApiException(
          _errorMessage(response, 'No se pudo confirmar la reserva'));
    }
    return Reserva.fromJson(_decode(response));
  }

  String _date(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
