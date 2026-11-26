import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'services/login.dart';
import 'services/socios.dart';

class MapaClientesPage extends StatefulWidget {
  const MapaClientesPage({
    super.key,
    required this.loginResult,
    this.sociosService,
  });

  final LoginResult loginResult;
  final SociosService? sociosService;

  @override
  State<MapaClientesPage> createState() => _MapaClientesPageState();
}

class _MapaClientesPageState extends State<MapaClientesPage> {
  static const _navy = Color(0xFF102E5A);

  late final SociosService _sociosService;
  late Future<List<Socio>> _sociosFuture;
  String? _selectedSocioId;
  String? _selectedAreaKey;

  @override
  void initState() {
    super.initState();
    _sociosService = widget.sociosService ?? SociosService();
    _cargarSocios();
  }

  @override
  void dispose() {
    _sociosService.dispose();
    super.dispose();
  }

  void _cargarSocios() {
    _selectedAreaKey = null;
    _selectedSocioId = null;
    _sociosFuture = _sociosService.obtenerSocios(widget.loginResult.token);
  }

  void _selectArea(String? key) {
    if (_selectedAreaKey == key) return;
    setState(() {
      _selectedAreaKey = key;
      _selectedSocioId = null;
    });
  }

  void _ocultarNombre() {
    if (_selectedSocioId == null) return;
    setState(() => _selectedSocioId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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

                  final socios = (snapshot.data ?? const <Socio>[])
                      .where(_tieneCoordenadasValidas)
                      .toList(growable: false);
                  if (socios.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No hay clientes con coordenadas válidas para mostrar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _navy),
                        ),
                      ),
                    );
                  }

                  final areas = _groupSociosByArea(socios);
                  final matchingAreas = areas.where(
                    (area) => area.key == _selectedAreaKey,
                  );
                  final selectedArea = matchingAreas.isEmpty
                      ? null
                      : matchingAreas.first;
                  final visibleSocios = selectedArea?.socios ?? socios;
                  final points = visibleSocios
                      .map((socio) => LatLng(socio.latitud!, socio.longitud!))
                      .toList(growable: false);

                  return Column(
                    children: [
                      _buildAreaSelector(areas, socios.length),
                      Expanded(
                        child: FlutterMap(
                          key: ValueKey(_selectedAreaKey ?? 'all-areas'),
                          options: _mapOptions(points),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.geocobranza',
                            ),
                            MarkerLayer(
                              markers: visibleSocios
                                  .map(_buildMarker)
                                  .toList(growable: false),
                            ),
                            const RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  '© OpenStreetMap contributors',
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildAreaSelector(List<_SociosArea> areas, int totalSocios) {
    final selectedAll = _selectedAreaKey == null;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clientes por ciudad y parroquia',
            style: TextStyle(
              color: _navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('Todos ($totalSocios)'),
                  selected: selectedAll,
                  onSelected: (_) => _selectArea(null),
                ),
                for (final area in areas) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(
                      '${area.ciudad} · ${area.parroquia} (${area.socios.length})',
                    ),
                    selected: _selectedAreaKey == area.key,
                    onSelected: (_) => _selectArea(area.key),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_SociosArea> _groupSociosByArea(List<Socio> socios) {
    final areasByKey = <String, _SociosArea>{};

    for (final socio in socios) {
      final ciudad = _displayAreaName(socio.ciudad, 'Sin ciudad');
      final parroquia = _displayAreaName(socio.parroquia, 'Sin parroquia');
      final key =
          '${_normalizeAreaName(ciudad)}\u0000${_normalizeAreaName(parroquia)}';
      final area = areasByKey.putIfAbsent(
        key,
        () => _SociosArea(key: key, ciudad: ciudad, parroquia: parroquia),
      );
      area.socios.add(socio);
    }

    final areas = areasByKey.values.toList()
      ..sort((first, second) {
        final cityComparison = first.ciudad.toLowerCase().compareTo(
          second.ciudad.toLowerCase(),
        );
        if (cityComparison != 0) return cityComparison;
        return first.parroquia.toLowerCase().compareTo(
          second.parroquia.toLowerCase(),
        );
      });
    return areas;
  }

  String _displayAreaName(String value, String fallback) {
    final name = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return name.isEmpty ? fallback : name;
  }

  String _normalizeAreaName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
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
                'Mapa de clientes',
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

  Marker _buildMarker(Socio socio) {
    final selected = _selectedSocioId == socio.id;

    return Marker(
      point: LatLng(socio.latitud!, socio.longitud!),
      width: 56,
      height: 52,
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: -67,
            bottom: 40,
            width: 190,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    socio.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedSocioId = socio.id),
            child: const Icon(
              Icons.location_pin,
              color: Color(0xFFE53935),
              size: 38,
            ),
          ),
        ],
      ),
    );
  }

  MapOptions _mapOptions(List<LatLng> points) {
    final firstPoint = points.first;
    final sameLocation = points.every(
      (point) =>
          point.latitude == firstPoint.latitude &&
          point.longitude == firstPoint.longitude,
    );

    return MapOptions(
      initialCenter: firstPoint,
      initialZoom: 14,
      initialCameraFit: sameLocation
          ? null
          : CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.all(56),
              maxZoom: 15,
            ),
      onTap: (tapPosition, point) => _ocultarNombre(),
      onPositionChanged: (camera, hasGesture) {
        if (hasGesture) _ocultarNombre();
      },
    );
  }

  bool _tieneCoordenadasValidas(Socio socio) {
    final latitud = socio.latitud;
    final longitud = socio.longitud;
    return latitud != null &&
        longitud != null &&
        latitud.abs() <= 90 &&
        longitud.abs() <= 180;
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
              style: const TextStyle(color: _navy),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(_cargarSocios),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SociosArea {
  _SociosArea({
    required this.key,
    required this.ciudad,
    required this.parroquia,
  });

  final String key;
  final String ciudad;
  final String parroquia;
  final List<Socio> socios = [];
}
