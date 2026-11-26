import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocobranza/mapa_clientes_page.dart';
import 'package:geocobranza/detalle_credito_page.dart';
import 'package:geocobranza/home.dart';
import 'package:geocobranza/services/login.dart';
import 'package:geocobranza/services/socios.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('Home muestra el nombre del gestor autenticado', (
    WidgetTester tester,
  ) async {
    const loginResult = LoginResult(
      token: 'test-token',
      gestor: {'nombres': 'Maria Lopez', 'usuario': 'mlopez'},
    );

    await tester.pumpWidget(
      const MaterialApp(home: HomePage(loginResult: loginResult)),
    );

    expect(find.text('Hola, Maria Lopez'), findsOneWidget);
    expect(find.text('Asesor de Cobranza'), findsOneWidget);
  });

  testWidgets('Notificar ofrece compromiso y notificación con una foto', (
    WidgetTester tester,
  ) async {
    const socio = Socio(
      id: 'socio-1',
      nombre: 'Maria Lopez',
      producto: 'Crédito',
      fotografia: null,
      fotografias: [],
      cedula: '1234567890',
      telefono: '0999999999',
      direccion: 'Quito',
      referencia: '',
      latitud: null,
      longitud: null,
      credito: Credito(
        numeroOperacion: 'op-1',
        producto: 'Crédito',
        montoOriginal: null,
        saldoActual: null,
        cuotasVencidas: null,
        diasMora: null,
        interesMora: null,
        montoExigibleHoy: null,
        estado: 'AL_DIA',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DetalleCreditoPage(socio: socio, fotoUrl: null, fotoUrls: []),
      ),
    );

    expect(find.text('0/3 fotos'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsNWidgets(3));

    await tester.tap(find.text('Notificar'));
    await tester.pumpAndSettle();
    expect(find.text('Añadir compromiso'), findsOneWidget);
    expect(find.text('Notificar'), findsOneWidget);

    await tester.tap(find.text('Notificar').last);
    await tester.pumpAndSettle();
    expect(find.text('Foto (máximo 1)'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    expect(find.text('Subir foto'), findsOneWidget);
    expect(find.text('Tomar foto'), findsOneWidget);
    expect(find.text('Obtener ubicación'), findsOneWidget);
  });

  testWidgets('Mapa agrupa por ciudad y parroquia y filtra sus marcadores', (
    WidgetTester tester,
  ) async {
    final service = SociosService(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': true,
            'socios': [
              _apiSocio(
                id: '1',
                name: 'Cliente uno',
                city: 'Quito',
                parish: 'Centro',
                latitude: -0.18,
                longitude: -78.48,
              ),
              _apiSocio(
                id: '2',
                name: 'Cliente dos',
                city: 'Quito',
                parish: 'Centro',
                latitude: -0.19,
                longitude: -78.49,
              ),
              _apiSocio(
                id: '3',
                name: 'Cliente tres',
                city: 'Quito',
                parish: 'Norte',
                latitude: -0.15,
                longitude: -78.46,
              ),
            ],
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapaClientesPage(
          loginResult: const LoginResult(token: 'token', gestor: {}),
          sociosService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quito · Centro (2)'), findsOneWidget);
    expect(find.text('Quito · Norte (1)'), findsOneWidget);
    expect(find.byIcon(Icons.location_pin), findsNWidgets(3));

    await tester.tap(find.text('Quito · Centro (2)'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_pin), findsNWidgets(2));
  });
}

Map<String, dynamic> _apiSocio({
  required String id,
  required String name,
  required String city,
  required String parish,
  required double latitude,
  required double longitude,
}) {
  return {
    'id': id,
    'nombres': name,
    'credito': {
      'producto': 'Crédito',
      'numero_operacion': 'op-$id',
      'estado': 'AL_DIA',
    },
    'cedula': '000$id',
    'telefono': '0999999999',
    'direccion': 'Quito',
    'referencia': '',
    'ciudad': city,
    'parroquia': parish,
    'lat': latitude,
    'lng': longitude,
  };
}
