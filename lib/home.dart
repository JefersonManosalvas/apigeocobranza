import 'package:flutter/material.dart';

import 'clientes_page.dart';
import 'mapa_clientes_page.dart';
import 'services/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.loginResult});

  final LoginResult loginResult;

  static const Color _navy = Color(0xFF102E5A);
  static const Color _blue = Color(0xFF0784F9);
  static const Color _green = Color(0xFF16C979);
  static const Color _background = Color(0xFFF3F7FC);

  @override
  Widget build(BuildContext context) {
    final gestor = loginResult.gestor;
    final nombre =
        gestor['nombres']?.toString() ??
        gestor['usuario']?.toString() ??
        'Gestor';

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(),

                  const SizedBox(height: 24),

                  _buildProfile(nombre),

                  const SizedBox(height: 22),

                  _buildActionButtons(),

                  const SizedBox(height: 22),

                  _buildSummaryCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // BARRA SUPERIOR
  Widget _buildTopBar() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: _navy, size: 25),
            tooltip: 'Menú',
          ),

          const Expanded(
            child: Text(
              'Inicio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: _navy, size: 25),
            tooltip: 'Notificaciones',
          ),
        ],
      ),
    );
  }

  // PERFIL DEL ASESOR
  Widget _buildProfile(String nombre) {
    return Row(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF73C6FF), Color(0xFF087DDA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 46),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $nombre',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 5),

              Text(
                'Asesor de Cobranza',
                style: TextStyle(color: Color(0xFF526783), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // BOTONES PRINCIPALES CUADRADOS
  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double buttonSize = ((constraints.maxWidth - 12) / 2).clamp(
          0.0,
          180.0,
        );

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionCard(
                  size: buttonSize,
                  label: 'Créditos',
                  icon: Icons.credit_card,
                  color: _blue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ClientesPage(loginResult: loginResult),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12),

                _ActionCard(
                  size: buttonSize,
                  label: 'Mapa',
                  icon: Icons.location_on,
                  color: _green,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            MapaClientesPage(loginResult: loginResult),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /*_ActionCard(
              size: buttonSize,
              label: 'Galería',
              icon: Icons.photo_library,
              color: _purple,
              onTap: () {
                // Navegar a Galería
              },
            ),*/
          ],
        );
      },
    );
  }

  // RESUMEN DE GESTIÓN
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120C3768),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: _blue, size: 24),

              SizedBox(width: 9),

              Text(
                'Resumen de gestión',
                style: TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(color: Color(0xFFE8EEF6), height: 1),

          const SizedBox(height: 12),

          const _SummaryRow(
            icon: Icons.people,
            iconColor: Color(0xFF1680EE),
            label: 'Total de clientes por visitar',
            value: '24',
            valueColor: Color(0xFF1474F5),
          ),

          const SizedBox(height: 14),

          const _SummaryRow(
            icon: Icons.check_circle,
            iconColor: Color(0xFF12B76A),
            label: 'Clientes visitados',
            value: '8',
            valueColor: Color(0xFF12B76A),
          ),

          const SizedBox(height: 14),

          const _SummaryRow(
            icon: Icons.warning,
            iconColor: Color(0xFFFF3347),
            label: 'Créditos en mora',
            value: '16',
            valueColor: Color(0xFFFF3347),
          ),
        ],
      ),
    );
  }
}

// COMPONENTE DE BOTÓN CUADRADO
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.size,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final double size;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: color.withValues(alpha: 0.25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 42),

              const SizedBox(height: 12),

              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Icon(Icons.arrow_forward, color: Colors.white, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

// FILAS DEL RESUMEN
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 25),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF253B58),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
