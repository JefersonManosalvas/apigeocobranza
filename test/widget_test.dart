import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocobranza/home.dart';
import 'package:geocobranza/services/login.dart';

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
}
