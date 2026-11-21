import 'package:flutter/material.dart';

import 'detalle_credito_page.dart';
import 'services/login.dart';
import 'services/socios.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key, required this.loginResult});

  final LoginResult loginResult;

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  static const _navy = Color(0xFF102E5A);
  static const _background = Color(0xFFF3F7FC);

  final _sociosService = SociosService();
  late Future<List<Socio>> _sociosFuture;

  @override
  void initState() {
    super.initState();
    _cargarSocios();
  }

  @override
  void dispose() {
    _sociosService.dispose();
    super.dispose();
  }

  void _cargarSocios() {
    _sociosFuture = _sociosService.obtenerSocios(widget.loginResult.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FutureBuilder<List<Socio>>(
                    future: _sociosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return _buildError(snapshot.error!);
                      }

                      final socios = snapshot.data ?? const <Socio>[];
                      if (socios.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay clientes asignados.',
                            style: TextStyle(color: _navy, fontSize: 14),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                            child: Text(
                              '${socios.length} clientes asignados',
                              style: const TextStyle(
                                color: Color(0xFF61748D),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: socios.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    indent: 68,
                                    color: Color(0xFFE5ECF4),
                                  ),
                              itemBuilder: (context, index) {
                                final socio = socios[index];
                                final fotoUrls = socio.fotografias
                                    .map(_sociosService.obtenerUrlFotografia)
                                    .whereType<String>()
                                    .toList(growable: false);
                                final fotoUrl = fotoUrls.isEmpty
                                    ? null
                                    : fotoUrls.first;
                                return _ClienteRow(
                                  socio: socio,
                                  fotoUrl: fotoUrl,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => DetalleCreditoPage(
                                          socio: socio,
                                          fotoUrl: fotoUrl,
                                          fotoUrls: fotoUrls,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: _navy),
              tooltip: 'Volver',
            ),
            const Expanded(
              child: Text(
                'Créditos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    final message = error is SociosException ? error.message : error.toString();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Color(0xFF7C8DA3), size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _navy, fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(_cargarSocios);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClienteRow extends StatelessWidget {
  const _ClienteRow({
    required this.socio,
    required this.fotoUrl,
    required this.onTap,
  });

  final Socio socio;
  final String? fotoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: fotoUrl == null
                      ? _buildPhotoFallback()
                      : Image.network(
                          fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPhotoFallback(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildPhotoFallback();
                          },
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      socio.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF102E5A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      socio.producto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF53677E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: _ClientesPageState._navy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoFallback() {
    return Container(
      color: const Color(0xFFE7F1FC),
      child: const Icon(Icons.person, color: Color(0xFF4386C7), size: 32),
    );
  }
}
