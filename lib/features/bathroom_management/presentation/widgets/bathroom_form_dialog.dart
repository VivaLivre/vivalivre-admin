import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/bathroom.dart';

class BathroomFormDialog extends StatefulWidget {
  final Bathroom? bathroom;

  const BathroomFormDialog({super.key, this.bathroom});

  @override
  State<BathroomFormDialog> createState() => _BathroomFormDialogState();
}

class _BathroomFormDialogState extends State<BathroomFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _photoUrlController;
  late TextEditingController _observationsController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  XFile? _selectedPhotoFile;

  bool _isAccessible = false;
  bool _hasChangingTable = false;
  bool _isFree = false;

  String _operatingHoursType = 'unknown';
  final Map<int, Map<String, String>> _customSchedule = {};
  String _status = 'approved';
  bool _isSearchingAddress = false;

  LatLng _selectedLocation = const LatLng(-23.5505, -46.6333);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    final b = widget.bathroom;
    _nameController = TextEditingController(text: b?.name ?? '');
    _addressController = TextEditingController(text: b?.address ?? '');
    _photoUrlController = TextEditingController(text: b?.photoUrl ?? '');
    _observationsController = TextEditingController(text: '');
    _latController = TextEditingController(text: b?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: b?.longitude.toString() ?? '');

    if (b != null) {
      _isAccessible = b.isAccessible;
      _hasChangingTable = b.hasChangingTable;
      _isFree = b.isFree;
      _status = b.status;
      if (b.latitude != 0.0 && b.longitude != 0.0) {
        _selectedLocation = LatLng(b.latitude, b.longitude);
      }
      if (b.operatingHours != null) {
        if (b.operatingHours is Map && b.operatingHours['type'] != null) {
          _operatingHoursType = b.operatingHours['type'];
          if (_operatingHoursType == 'custom' && b.operatingHours['schedule'] != null) {
            final schedule = b.operatingHours['schedule'] as Map;
            schedule.forEach((key, value) {
              final day = int.tryParse(key.toString());
              if (day != null && value is Map) {
                _customSchedule[day] = {
                  'open': value['open']?.toString() ?? '08:00',
                  'close': value['close']?.toString() ?? '18:00',
                };
              }
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _photoUrlController.dispose();
    _observationsController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPhotoFile = image;
      });
    }
  }

  Future<Iterable<Map<String, dynamic>>> _searchAddress(String query) async {
    if (query.length < 3) return const Iterable<Map<String, dynamic>>.empty();
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error searching address: $e');
    }
    return const Iterable<Map<String, dynamic>>.empty();
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['display_name'] != null && mounted) {
          setState(() {
            _addressController.text = data['display_name'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
  }

  void _movePinFromLatLng() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      setState(() {
        _selectedLocation = LatLng(lat, lng);
      });
      _mapController.move(_selectedLocation, 15.0);
      _reverseGeocode(lat, lng);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordenadas inválidas.'), backgroundColor: Colors.orange));
    }
  }

  Future<void> _searchAndMovePin() async {
    final query = _addressController.text;
    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Digite pelo menos 3 caracteres para buscar.'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSearchingAddress = true);
    try {
      final results = await _searchAddress(query);
      if (results.isNotEmpty) {
        final option = results.first;
        if (option['lat'] != null && option['lon'] != null) {
          final lat = double.parse(option['lat'].toString());
          final lng = double.parse(option['lon'].toString());
          setState(() {
            _selectedLocation = LatLng(lat, lng);
            _latController.text = lat.toStringAsFixed(6);
            _lngController.text = lng.toStringAsFixed(6);
          });
          _mapController.move(_selectedLocation, 15.0);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Localização encontrada e atualizada no mapa!'),
                backgroundColor: Colors.green));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Endereço não encontrado. Por favor, marque manualmente no mapa.'),
              backgroundColor: Colors.orange));
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingAddress = false);
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'address': _addressController.text,
        'latitude': double.tryParse(_latController.text.replaceAll(',', '.')) ??
            _selectedLocation.latitude,
        'longitude':
            double.tryParse(_lngController.text.replaceAll(',', '.')) ??
                _selectedLocation.longitude,
        'is_accessible': _isAccessible,
        'has_changing_table': _hasChangingTable,
        'is_free': _isFree,
        'status': _status,
      };

      if (_photoUrlController.text.isNotEmpty) {
        data['photo_url'] = _photoUrlController.text;
      }
      if (_selectedPhotoFile != null) {
        data['photo_file'] = _selectedPhotoFile!;
      }

      final opHours = <String, dynamic>{'type': _operatingHoursType};
      if (_operatingHoursType == 'custom') {
        final scheduleStrKeys = <String, dynamic>{};
        _customSchedule.forEach((key, value) {
          scheduleStrKeys[key.toString()] = value;
        });
        opHours['schedule'] = scheduleStrKeys;
      }
      data['operating_hours'] = opHours;

      if (_observationsController.text.isNotEmpty) {
        data['observations'] = _observationsController.text;
      }

      Navigator.of(context).pop(data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Por favor, preencha todos os campos obrigatórios corretamente.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.bathroom != null;

    // ── Token colors ─────────────────────────────────────────────────────
    final dialogBg = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF2E3347) : null;
    final hintColor = isDark ? const Color(0xFF8891A8) : Colors.grey;
    final primaryText = isDark ? const Color(0xFFF1F3F9) : null;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar Banheiro' : 'Novo Banheiro',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold, color: primaryText),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? const Color(0xFF8891A8) : null),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(color: dividerColor),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left Column: Fields ──────────────────────────────
                    Expanded(
                      flex: 1,
                      child: ListView(
                        padding: const EdgeInsets.only(right: 16),
                        children: [
                          _themedField(
                            controller: _nameController,
                            label: 'Nome',
                            isDark: isDark,
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Obrigatório' : null,
                          ),
                          const SizedBox(height: 16),
                          _themedField(
                            controller: _addressController,
                            label: 'Endereço',
                            isDark: isDark,
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Obrigatório' : null,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSearchingAddress ? null : _searchAndMovePin,
                              icon: _isSearchingAddress
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.search),
                              label: const Text('Buscar Localização no Mapa'),
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dica: Se o endereço não for encontrado na busca, clique manualmente no mapa ao lado para marcar a posição exata.',
                            style: TextStyle(fontSize: 12, color: hintColor),
                          ),
                          const SizedBox(height: 16),
                          // Lat/Lng row
                          Row(
                            children: [
                              Expanded(
                                child: _themedField(
                                  controller: _latController,
                                  label: 'Latitude',
                                  isDark: isDark,
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                                  onChanged: (value) {
                                    final coordExp = RegExp(
                                        r'^(-?\d+\.\d+)[\s,]+(-?\d+\.\d+)$');
                                    final match = coordExp.firstMatch(value.trim());
                                    if (match != null) {
                                      _latController.text = match.group(1)!;
                                      _lngController.text = match.group(2)!;
                                      _movePinFromLatLng();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _themedField(
                                  controller: _lngController,
                                  label: 'Longitude',
                                  isDark: isDark,
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                                  onChanged: (value) {
                                    final coordExp = RegExp(
                                        r'^(-?\d+\.\d+)[\s,]+(-?\d+\.\d+)$');
                                    final match = coordExp.firstMatch(value.trim());
                                    if (match != null) {
                                      _latController.text = match.group(1)!;
                                      _lngController.text = match.group(2)!;
                                      _movePinFromLatLng();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _movePinFromLatLng,
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16)),
                                child: const Icon(Icons.location_on),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Photo URL + picker
                          Row(
                            children: [
                              Expanded(
                                child: _themedField(
                                  controller: _photoUrlController,
                                  label: 'URL da Foto (opcional)',
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.attach_file),
                                label: Text(_selectedPhotoFile != null
                                    ? 'Trocar Anexo'
                                    : 'Anexar Foto'),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16)),
                              ),
                            ],
                          ),
                          if (_selectedPhotoFile != null) ...[
                            const SizedBox(height: 8),
                            Text('Anexo: ${_selectedPhotoFile!.name}',
                                style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold)),
                          ],
                          const SizedBox(height: 16),

                          // ── Operating Hours selector ──────────────────
                          Row(
                            children: [
                              _buildHoursTypeButton('Desconhecido', 'unknown', isDark),
                              const SizedBox(width: 8),
                              _buildHoursTypeButton('24 Horas', '24h', isDark),
                              const SizedBox(width: 8),
                              _buildHoursTypeButton('Personalizado', 'custom', isDark),
                            ],
                          ),
                          if (_operatingHoursType == 'custom') ...[
                            const SizedBox(height: 16),
                            _buildCustomScheduleEditor(isDark),
                          ],
                          if (isEditing) ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _status,
                              dropdownColor: isDark ? const Color(0xFF232634) : null,
                              style: TextStyle(color: isDark ? const Color(0xFFF1F3F9) : null),
                              decoration: InputDecoration(
                                labelText: 'Status',
                                labelStyle: TextStyle(color: isDark ? const Color(0xFF8891A8) : null),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isDark ? const Color(0xFF2E3347) : Colors.grey.shade400),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'approved', child: Text('Aprovado')),
                                DropdownMenuItem(value: 'pending', child: Text('Pendente')),
                                DropdownMenuItem(value: 'rejected', child: Text('Rejeitado')),
                              ],
                              onChanged: (val) => setState(() => _status = val!),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text('Acessível (PCD)',
                                style: TextStyle(color: primaryText)),
                            value: _isAccessible,
                            activeThumbColor: const Color(0xFF2563EB),
                            onChanged: (val) => setState(() => _isAccessible = val),
                          ),
                          SwitchListTile(
                            title: Text('Tem Trocador',
                                style: TextStyle(color: primaryText)),
                            value: _hasChangingTable,
                            activeThumbColor: const Color(0xFF2563EB),
                            onChanged: (val) => setState(() => _hasChangingTable = val),
                          ),
                          SwitchListTile(
                            title: Text('Gratuito', style: TextStyle(color: primaryText)),
                            value: _isFree,
                            activeThumbColor: const Color(0xFF2563EB),
                            onChanged: (val) => setState(() => _isFree = val),
                          ),
                        ],
                      ),
                    ),

                    // ── Right Column: Map ────────────────────────────────
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Localização (Arraste ou clique)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: primaryText),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _selectedLocation,
                                  initialZoom: 15.0,
                                  onTap: (tapPosition, point) {
                                    setState(() {
                                      _selectedLocation = point;
                                      _latController.text =
                                          point.latitude.toStringAsFixed(6);
                                      _lngController.text =
                                          point.longitude.toStringAsFixed(6);
                                    });
                                    _reverseGeocode(
                                        point.latitude, point.longitude);
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.vivalivre.admin',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _selectedLocation,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${_selectedLocation.latitude.toStringAsFixed(5)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(5)}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: hintColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            Divider(color: dividerColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar',
                      style: TextStyle(
                          color: isDark ? const Color(0xFF8891A8) : null)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: themed TextFormField ──────────────────────────────────────────
  Widget _themedField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? const Color(0xFFF1F3F9) : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: isDark ? const Color(0xFF8891A8) : null),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: isDark ? const Color(0xFF2E3347) : Colors.grey.shade400),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: isDark,
        fillColor: isDark ? const Color(0xFF232634) : null,
      ),
    );
  }

  // ── Helper: operating hours type button ──────────────────────────────────
  Widget _buildHoursTypeButton(String label, String value, bool isDark) {
    final isSelected = _operatingHoursType == value;
    const blue = Color(0xFF2563EB);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _operatingHoursType = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? const Color(0xFF1E2D4A)
                    : blue.withValues(alpha: 0.1))
                : Colors.transparent,
            border: Border.all(
                color: isSelected
                    ? blue
                    : (isDark ? const Color(0xFF2E3347) : Colors.grey)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? blue
                    : (isDark ? const Color(0xFF8891A8) : Colors.black87),
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Custom schedule editor ────────────────────────────────────────────────
  Widget _buildCustomScheduleEditor(bool isDark) {
    const days = {
      1: 'Segunda',
      2: 'Terça',
      3: 'Quarta',
      4: 'Quinta',
      5: 'Sexta',
      6: 'Sábado',
      7: 'Domingo',
    };

    final containerBg =
        isDark ? const Color(0xFF0F1117) : Colors.grey.shade50;
    final containerBorder =
        isDark ? const Color(0xFF2E3347) : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: containerBorder),
      ),
      child: Column(
        children: days.entries.map((entry) {
          final day = entry.key;
          final name = entry.value;
          final isOpen = _customSchedule.containsKey(day);
          final openTime =
              isOpen ? _customSchedule[day]!['open']! : '08:00';
          final closeTime =
              isOpen ? _customSchedule[day]!['close']! : '18:00';
          final isLast = day == 7;

          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: containerBorder)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isOpen,
                  activeColor: const Color(0xFF2563EB),
                  side: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3347)
                          : Colors.grey.shade400),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _customSchedule[day] = {
                          'open': '08:00',
                          'close': '18:00'
                        };
                      } else {
                        _customSchedule.remove(day);
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isOpen
                          ? (isDark
                              ? const Color(0xFFF1F3F9)
                              : Colors.black)
                          : (isDark
                              ? const Color(0xFF8891A8)
                              : Colors.grey),
                    ),
                  ),
                ),
                const Spacer(),
                _buildTimeButton(day, openTime, isOpen, true, isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-',
                      style: TextStyle(
                          color: isDark
                              ? const Color(0xFF8891A8)
                              : null)),
                ),
                _buildTimeButton(day, closeTime, isOpen, false, isDark),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeButton(
      int day, String time, bool isEnabled, bool isStart, bool isDark) {
    return InkWell(
      onTap: isEnabled
          ? () async {
              final initialParts = time.split(':');
              final initialTime = TimeOfDay(
                hour: int.tryParse(initialParts[0]) ?? 8,
                minute: int.tryParse(initialParts[1]) ?? 0,
              );

              final selected = await showTimePicker(
                context: context,
                initialTime: initialTime,
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: true),
                    child: child!),
              );

              if (selected != null) {
                final newTime =
                    '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
                setState(() {
                  if (isStart) {
                    _customSchedule[day]!['open'] = newTime;
                  } else {
                    _customSchedule[day]!['close'] = newTime;
                  }
                });
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isDark ? const Color(0xFF232634) : Colors.white)
              : (isDark
                  ? const Color(0xFF1A1D27)
                  : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isEnabled
                  ? (isDark
                      ? const Color(0xFF2E3347)
                      : Colors.grey.shade400)
                  : Colors.transparent),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isEnabled
                ? (isDark ? const Color(0xFFF1F3F9) : Colors.black)
                : (isDark ? const Color(0xFF8891A8) : Colors.grey),
          ),
        ),
      ),
    );
  }
}
