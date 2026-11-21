import 'dart:convert';

import 'package:http/http.dart' as http;

class LoginException implements Exception {
  final String message;

  const LoginException(this.message);

  @override
  String toString() => message;
}

class LoginResult {
  final String token;
  final Map<String, dynamic> gestor;

  const LoginResult({required this.token, required this.gestor});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'] as String,
      gestor: Map<String, dynamic>.from(json['gestor'] as Map),
    );
  }
}

class LoginService {
  final String baseUrl;
  final http.Client _client;

  LoginService({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://apigeocobranza.onrender.com',
    ),
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<LoginResult> login({
    required String usuario,
    required String clave,
  }) async {
    final trimmedUser = usuario.trim();

    if (trimmedUser.isEmpty || clave.isEmpty) {
      throw const LoginException('Ingresa el usuario y la clave');
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'usuario': trimmedUser, 'clave': clave}),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['ok'] == true &&
            data['token'] is String &&
            data['gestor'] is Map) {
          return LoginResult.fromJson(data);
        }
        throw LoginException(
          data['mensaje']?.toString() ??
              'La API devolvio una respuesta invalida',
        );
      }

      throw LoginException(
        data['mensaje']?.toString() ??
            'No se pudo iniciar sesion (${response.statusCode})',
      );
    } on LoginException {
      rethrow;
    } on FormatException {
      throw const LoginException('La API devolvio una respuesta invalida');
    } catch (_) {
      throw const LoginException(
        'No se pudo conectar con el servidor. Verifica la conexion.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
