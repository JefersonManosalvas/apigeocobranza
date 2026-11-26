import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
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
                        SizedBox(
                          width: double.infinity,
                          child: _ActionButton(
                            label: 'Notificar',
                            icon: Icons.notifications_active,
                            color: _blue,
                            onPressed: () =>
                                _showNotificationOptions(context, socio),
                          ),
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
    return _EditableGallery(photoUrls: fotoUrls);
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

enum _ManagementType { commitment, notification }

class _ManagementDraft {
  const _ManagementDraft({
    required this.type,
    required this.message,
    required this.photo,
    required this.position,
    required this.commitmentDate,
  });

  final _ManagementType type;
  final String message;
  final Uint8List? photo;
  final Position? position;
  final DateTime? commitmentDate;
}

Future<void> _showNotificationOptions(BuildContext context, Socio socio) async {
  final type = await showDialog<_ManagementType>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Qué deseas hacer?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.event_note,
              color: DetalleCreditoPage._blue,
            ),
            title: const Text('Añadir compromiso'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pop(context, _ManagementType.commitment),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.notifications_active_outlined,
              color: DetalleCreditoPage._blue,
            ),
            title: const Text('Notificar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pop(context, _ManagementType.notification),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || type == null) return;

  final draft = await showDialog<_ManagementDraft>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: _ManagementForm(type: type, customerName: socio.nombre),
      ),
    ),
  );
  if (!context.mounted || draft == null) return;

  final label = draft.type == _ManagementType.commitment
      ? 'Compromiso'
      : 'Notificación';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$label capturado para ${socio.nombre}. '
        'Ubicación: ${draft.position!.latitude.toStringAsFixed(6)}, '
        '${draft.position!.longitude.toStringAsFixed(6)}.',
      ),
    ),
  );
}

class _ManagementForm extends StatefulWidget {
  const _ManagementForm({required this.type, required this.customerName});

  final _ManagementType type;
  final String customerName;

  @override
  State<_ManagementForm> createState() => _ManagementFormState();
}

class _ManagementFormState extends State<_ManagementForm> {
  final _imagePicker = ImagePicker();
  final _messageController = TextEditingController();

  Uint8List? _photo;
  Position? _position;
  DateTime? _commitmentDate;
  bool _isPickingPhoto = false;
  bool _isGettingLocation = false;

  bool get _isCommitment => widget.type == _ManagementType.commitment;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_isPickingPhoto || _photo != null) return;

    setState(() => _isPickingPhoto = true);
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showMessage(
        'No se pudo abrir la imagen: ${error.message ?? error.code}',
      );
    } on MissingPluginException {
      if (!mounted) return;
      _showMessage('La cámara o la galería no están disponibles.');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<Position?> _obtainCurrentLocation() async {
    if (_isGettingLocation) return null;

    setState(() => _isGettingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage(
          'Activa la ubicación del dispositivo e inténtalo de nuevo.',
        );
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('Se necesita permiso de ubicación para guardarla.');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return null;
      setState(() => _position = position);
      return position;
    } on LocationServiceDisabledException {
      if (mounted) {
        _showMessage(
          'Activa la ubicación del dispositivo e inténtalo de nuevo.',
        );
      }
      return null;
    } on PermissionDeniedException {
      if (mounted) {
        _showMessage('Se necesita permiso de ubicación para guardarla.');
      }
      return null;
    } on TimeoutException {
      if (mounted) _showMessage('No se pudo obtener la ubicación a tiempo.');
      return null;
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage(
          'No se pudo obtener la ubicación: ${error.message ?? error.code}',
        );
      }
      return null;
    } on MissingPluginException {
      if (mounted) {
        _showMessage('La ubicación no está disponible en este dispositivo.');
      }
      return null;
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _saveDraft() async {
    final position = await _obtainCurrentLocation();
    if (!mounted || position == null) return;

    Navigator.pop(
      context,
      _ManagementDraft(
        type: widget.type,
        message: _messageController.text.trim(),
        photo: _photo,
        position: position,
        commitmentDate: _commitmentDate,
      ),
    );
  }

  Future<void> _selectCommitmentDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _commitmentDate ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 5),
    );
    if (date != null && mounted) {
      setState(() => _commitmentDate = date);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final title = _isCommitment ? 'Añadir compromiso' : 'Notificar';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: DetalleCreditoPage._navy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            widget.customerName,
            style: const TextStyle(color: Color(0xFF53677E)),
          ),
          if (_isCommitment) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _selectCommitmentDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _commitmentDate == null
                    ? 'Seleccionar fecha'
                    : 'Fecha: ${_commitmentDate!.day}/${_commitmentDate!.month}/${_commitmentDate!.year}',
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: _isCommitment ? 'Detalle del compromiso' : 'Mensaje',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Foto (máximo 1)',
            style: TextStyle(
              color: DetalleCreditoPage._navy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.8,
            child: _photo == null
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7FC),
                      border: Border.all(color: const Color(0xFFD8E2EF)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF71839A),
                      size: 36,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(_photo!, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPickingPhoto || _photo != null
                      ? null
                      : () => _pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Subir foto'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isPickingPhoto || _photo != null
                      ? null
                      : () => _pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Tomar foto'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isGettingLocation ? null : _obtainCurrentLocation,
            icon: _isGettingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _position == null ? 'Obtener ubicación' : 'Actualizar ubicación',
            ),
          ),
          if (_position != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ubicación obtenida: ${_position!.latitude.toStringAsFixed(6)}, '
              '${_position!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(color: Color(0xFF53677E), fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _isGettingLocation ? null : _saveDraft,
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableGallery extends StatefulWidget {
  const _EditableGallery({required this.photoUrls});

  final List<String> photoUrls;

  @override
  State<_EditableGallery> createState() => _EditableGalleryState();
}

class _EditableGalleryState extends State<_EditableGallery> {
  static const _maxPhotos = 3;

  final _imagePicker = ImagePicker();
  late final List<String?> _remotePhotoUrls;
  late final List<Uint8List?> _localPhotos;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _remotePhotoUrls = List<String?>.generate(
      _maxPhotos,
      (index) =>
          index < widget.photoUrls.length ? widget.photoUrls[index] : null,
    );
    _localPhotos = List<Uint8List?>.filled(_maxPhotos, null);
  }

  int? get _nextAvailableSlot {
    final index = List<int>.generate(_maxPhotos, (index) => index).firstWhere(
      (index) => _remotePhotoUrls[index] == null && _localPhotos[index] == null,
      orElse: () => -1,
    );
    return index == -1 ? null : index;
  }

  Future<void> _pickPhoto(ImageSource source, {int? slot}) async {
    if (_isPickingPhoto) return;
    final targetSlot = slot ?? _nextAvailableSlot;
    if (targetSlot == null) return;

    setState(() => _isPickingPhoto = true);
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _localPhotos[targetSlot] = bytes;
        _remotePhotoUrls[targetSlot] = null;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showMessage(
        'No se pudo abrir la imagen: ${error.message ?? error.code}',
      );
    } on MissingPluginException {
      if (!mounted) return;
      _showMessage('La cámara o la galería no están disponibles.');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _showPhoto(int index) {
    final bytes = _localPhotos[index];
    final url = _remotePhotoUrls[index];
    final image = bytes != null
        ? Image.memory(bytes, fit: BoxFit.contain)
        : Image.network(
            url!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image_outlined, size: 48),
          );

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(child: InteractiveViewer(child: image)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final photoCount = List<int>.generate(_maxPhotos, (index) => index)
        .where(
          (index) =>
              _localPhotos[index] != null || _remotePhotoUrls[index] != null,
        )
        .length;

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
                    color: DetalleCreditoPage._navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$photoCount/$_maxPhotos fotos',
                style: const TextStyle(color: Color(0xFF61748D), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 16) / _maxPhotos;
              return Row(
                children: List.generate(
                  _maxPhotos,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index == _maxPhotos - 1 ? 0 : 8,
                    ),
                    child: SizedBox(
                      width: width,
                      height: width,
                      child: _buildPhotoSlot(index),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPickingPhoto || _nextAvailableSlot == null
                      ? null
                      : () => _pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Subir foto'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isPickingPhoto || _nextAvailableSlot == null
                      ? null
                      : () => _pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Tomar foto'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    final bytes = _localPhotos[index];
    final url = _remotePhotoUrls[index];

    if (bytes == null && url == null) {
      return Material(
        color: const Color(0xFFF3F7FC),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: _isPickingPhoto
              ? null
              : () => _pickPhoto(ImageSource.gallery, slot: index),
          borderRadius: BorderRadius.circular(9),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: Color(0xFF71839A),
                size: 25,
              ),
              SizedBox(height: 4),
              Text(
                'Subir foto',
                style: TextStyle(fontSize: 10, color: Color(0xFF53677E)),
              ),
            ],
          ),
        ),
      );
    }

    final image = bytes != null
        ? Image.memory(bytes, fit: BoxFit.cover)
        : Image.network(
            url!,
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
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: InkWell(onTap: () => _showPhoto(index), child: image),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: IconButton(
              tooltip: 'Tomar foto para reemplazar',
              onPressed: _isPickingPhoto
                  ? null
                  : () => _pickPhoto(ImageSource.camera, slot: index),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                minimumSize: const Size(32, 32),
                padding: const EdgeInsets.all(6),
              ),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
            ),
          ),
        ],
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
