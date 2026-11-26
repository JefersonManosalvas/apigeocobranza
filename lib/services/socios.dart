import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class SociosException implements Exception {
  const SociosException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Socio {
  const Socio({
    required this.id,
    required this.nombre,
    required this.producto,
    required this.fotografia,
    required this.fotografias,
    required this.cedula,
    required this.telefono,
    required this.direccion,
    required this.referencia,
    this.ciudad = '',
    this.parroquia = '',
    required this.latitud,
    required this.longitud,
    required this.credito,
  });

  final String id;
  final String nombre;
  final String producto;
  final String? fotografia;
  final List<String> fotografias;
  final String cedula;
  final String telefono;
  final String direccion;
  final String referencia;
  final String ciudad;
  final String parroquia;
  final double? latitud;
  final double? longitud;
  final Credito credito;

  factory Socio.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nombre = json['nombres'];
    final credito = json['credito'];

    if (id is! String || nombre is! String || credito is! Map) {
      throw const SociosException('La API devolvió un cliente inválido');
    }

    final producto = credito['producto'];
    if (producto is! String) {
      throw const SociosException('La API devolvió un producto inválido');
    }

    final cedula = json['cedula'];
    final telefono = json['telefono'];
    final direccion = json['direccion'];
    final referencia = json['referencia'];
    if (cedula is! String ||
        telefono is! String ||
        direccion is! String ||
        referencia is! String) {
      throw const SociosException(
        'La API devolvió información incompleta del cliente',
      );
    }

    final fotografias = json['fotografias_ubicacion'];
    final fotos = fotografias is List
        ? fotografias
              .whereType<String>()
              .map((path) => path.trim())
              .where((path) => path.isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    return Socio(
      id: id,
      nombre: nombre,
      producto: producto,
      fotografia: fotos.isEmpty ? null : fotos.first,
      fotografias: fotos,
      cedula: cedula,
      telefono: telefono,
      direccion: direccion,
      referencia: referencia,
      ciudad: _asString(json['ciudad']),
      parroquia: _asString(json['parroquia']),
      latitud: _asDouble(json['lat']),
      longitud: _asDouble(json['lng']),
      credito: Credito.fromJson(Map<String, dynamic>.from(credito)),
    );
  }
}

String _asString(dynamic value) {
  return value is String ? value.trim() : '';
}

class Credito {
  const Credito({
    required this.numeroOperacion,
    required this.producto,
    required this.montoOriginal,
    required this.saldoActual,
    required this.cuotasVencidas,
    required this.diasMora,
    required this.interesMora,
    required this.montoExigibleHoy,
    required this.estado,
  });

  final String numeroOperacion;
  final String producto;
  final double? montoOriginal;
  final double? saldoActual;
  final int? cuotasVencidas;
  final int? diasMora;
  final double? interesMora;
  final double? montoExigibleHoy;
  final String estado;

  factory Credito.fromJson(Map<String, dynamic> json) {
    final numeroOperacion = json['numero_operacion'];
    final producto = json['producto'];
    final estado = json['estado'];
    if (numeroOperacion is! String ||
        producto is! String ||
        estado is! String) {
      throw const SociosException(
        'La API devolvió información inválida del crédito',
      );
    }

    return Credito(
      numeroOperacion: numeroOperacion,
      producto: producto,
      montoOriginal: _asDouble(json['monto_original']),
      saldoActual: _asDouble(json['saldo_actual']),
      cuotasVencidas: _asInt(json['cuotas_vencidas']),
      diasMora: _asInt(json['dias_mora']),
      interesMora: _asDouble(json['interes_mora']),
      montoExigibleHoy: _asDouble(json['monto_exigible_hoy']),
      estado: estado,
    );
  }
}

double? _asDouble(dynamic value) {
  return value is num ? value.toDouble() : null;
}

int? _asInt(dynamic value) {
  return value is num ? value.toInt() : null;
}

class SociosService {
  SociosService({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://apigeocobranza.onrender.com',
    ),
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<Socio>> obtenerSocios(String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/socios'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final dynamic decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SociosException(
          data['mensaje']?.toString() ??
              'No se pudieron cargar los clientes (${response.statusCode})',
        );
      }

      final rawSocios = data['socios'];
      if (data['ok'] != true || rawSocios is! List) {
        throw SociosException(
          data['mensaje']?.toString() ??
              'La API devolvió una lista de clientes inválida',
        );
      }

      return rawSocios
          .map((rawSocio) {
            if (rawSocio is! Map<String, dynamic>) {
              throw const SociosException(
                'La API devolvió un cliente inválido',
              );
            }
            return Socio.fromJson(rawSocio);
          })
          .toList(growable: false);
    } on SociosException {
      rethrow;
    } on FormatException {
      throw const SociosException('La API devolvió una respuesta inválida');
    } on TimeoutException {
      throw const SociosException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } on http.ClientException {
      throw const SociosException(
        'No se pudo conectar con el servidor. Verifica la conexión.',
      );
    }
  }

  String? obtenerUrlFotografia(String? path) {
    if (path == null || path.trim().isEmpty) return null;

    final parsedPath = Uri.tryParse(path);
    if (parsedPath != null && parsedPath.hasScheme) return path;

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/').resolve(normalizedPath).toString();
  }

  void dispose() {
    _client.close();
  }
}
