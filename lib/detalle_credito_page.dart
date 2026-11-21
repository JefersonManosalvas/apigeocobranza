import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'services/socios.dart';

class DetalleCreditoPage extends StatelessWidget {
  const DetalleCreditoPage({
    super.key,
    required this.socio,
    required this.fotoUrl,
    required this.fotoUrls,
  });

  final Socio socio;
  final String? fotoUrl;
  final List<String> fotoUrls;

  static const _navy = Color(0xFF102E5A);
  static const _blue = Color(0xFF087DFA);
  static const _green = Color(0xFF16B979);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildClientCard(),
                        const SizedBox(height: 12),
                        _buildCreditCard(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                label: 'Notificar',
                                icon: Icons.notifications_active,
                                color: _blue,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                label: 'Tomar foto',
                                icon: Icons.camera_alt,
                                color: _green,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildObservations(),
                        const SizedBox(height: 14),
                        _buildLocationMap(),
                        const SizedBox(height: 14),
                        _buildGallery(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                'Detalle de crédito',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
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

  Widget _buildClientCard() {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: fotoUrl == null
                      ? _buildPhotoFallback()
                      : Image.network(
                          fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPhotoFallback(),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      socio.nombre,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'C.I. ${socio.cedula}',
                      style: const TextStyle(
                        color: Color(0xFF53677E),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      socio.telefono,
                      style: const TextStyle(
                        color: Color(0xFF53677E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE7EDF5)),
          const SizedBox(height: 8),
          _DetailLine(icon: Icons.location_on_outlined, label: socio.direccion),
          if (socio.referencia.isNotEmpty) ...[
            const SizedBox(height: 6),
            _DetailLine(icon: Icons.info_outline, label: socio.referencia),
          ],
        ],
      ),
    );
  }

  Widget _buildCreditCard() {
    final isCurrent = socio.credito.estado.toUpperCase() == 'AL_DIA';

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del crédito',
            style: TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Producto', value: socio.credito.producto),
          _InfoRow(
            label: 'N.º de operación',
            value: socio.credito.numeroOperacion,
          ),
          _InfoRow(
            label: 'Estado',
            value: socio.credito.estado,
            valueColor: isCurrent
                ? const Color(0xFF11945B)
                : const Color(0xFFFF3347),
          ),
          _InfoRow(
            label: 'Monto original',
            value: _formatMoney(socio.credito.montoOriginal),
          ),
          _InfoRow(
            label: 'Saldo actual',
            value: _formatMoney(socio.credito.saldoActual),
            valueColor: const Color(0xFF087DFA),
          ),
          _InfoRow(
            label: 'Cuotas vencidas',
            value: _formatCount(socio.credito.cuotasVencidas),
          ),
          _InfoRow(
            label: 'Días de mora',
            value: _formatCount(socio.credito.diasMora),
          ),
          _InfoRow(
            label: 'Interés por mora',
            value: _formatMoney(socio.credito.interesMora),
          ),
          _InfoRow(
            label: 'Exigible hoy',
            value: _formatMoney(socio.credito.montoExigibleHoy),
            valueColor: const Color(0xFFFF3347),
          ),
        ],
      ),
    );
  }

  Widget _buildObservations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones',
          style: TextStyle(
            color: _navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Escribe tus observaciones...',
            hintStyle: const TextStyle(color: Color(0xFF7D8DA2), fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6F1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6F1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMap() {
    final latitude = socio.latitud;
    final longitude = socio.longitud;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación del cliente',
          style: TextStyle(
            color: _navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 240,
            child:
                latitude == null ||
                    longitude == null ||
                    latitude.abs() > 90 ||
                    longitude.abs() > 180
                ? const ColoredBox(
                    color: Color(0xFFE5ECF4),
                    child: Center(
                      child: Text(
                        'No hay coordenadas válidas para mostrar el mapa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF53677E)),
                      ),
                    ),
                  )
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.geocobranza',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude, longitude),
                            width: 44,
                            height: 48,
                            child: const Icon(
                              Icons.location_pin,
                              color: Color(0xFFE53935),
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                      const RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution('© OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Galería',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${fotoUrls.length} fotos',
                style: const TextStyle(
                  color: Color(0xFF61748D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (fotoUrls.isEmpty)
            const Text(
              'No hay fotografías disponibles para este cliente.',
              style: TextStyle(color: Color(0xFF53677E), fontSize: 12),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 16) / 3;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    fotoUrls.length,
                    (index) => _GalleryThumbnail(
                      imageUrl: fotoUrls[index],
                      size: width,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoFallback() {
    return const ColoredBox(
      color: Color(0xFFE7F1FC),
      child: Icon(Icons.person, color: Color(0xFF4386C7), size: 38),
    );
  }

  static String _formatMoney(double? amount) {
    return amount == null ? '—' : '\$ ${amount.toStringAsFixed(2)}';
  }

  static String _formatCount(int? count) {
    return count?.toString() ?? '—';
  }
}

class _GalleryThumbnail extends StatelessWidget {
  const _GalleryThumbnail({required this.imageUrl, required this.size});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(
                      height: 220,
                      child: Center(
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFFE7F1FC),
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF7C8DA3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100C3768),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6D8198), size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF53677E), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF53677E), fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF102E5A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}
