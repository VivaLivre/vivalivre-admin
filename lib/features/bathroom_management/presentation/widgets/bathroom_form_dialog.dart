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

  LatLng _selectedLocation = const LatLng(-23.5505, -46.6333); // Default SP
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
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
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
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1');
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coordenadas inválidas.'), backgroundColor: Colors.orange));
    }
  }

  Future<void> _searchAndMovePin() async {
    final query = _addressController.text;
    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite pelo menos 3 caracteres para buscar.'), backgroundColor: Colors.orange));
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Localização encontrada e atualizada no mapa!'), backgroundColor: Colors.green),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Endereço não encontrado. Por favor, marque manualmente no mapa.'), backgroundColor: Colors.orange),
          );
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
        'latitude': double.tryParse(_latController.text.replaceAll(',', '.')) ?? _selectedLocation.latitude,
        'longitude': double.tryParse(_lngController.text.replaceAll(',', '.')) ?? _selectedLocation.longitude,
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
      // Feedback visual caso o formulário seja inválido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios corretamente.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bathroom != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar Banheiro' : 'Novo Banheiro',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna Esquerda: Campos
                    Expanded(
                      flex: 1,
                      child: ListView(
                        padding: const EdgeInsets.only(right: 16),
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                            validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(labelText: 'Endereço', border: OutlineInputBorder()),
                            validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSearchingAddress ? null : _searchAndMovePin,
                              icon: _isSearchingAddress ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                              label: const Text('Buscar Localização no Mapa'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dica: Se o endereço não for encontrado na busca, digite-o e clique manualmente no mapa ao lado para marcar a posição exata.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _latController,
                                  decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  onChanged: (value) {
                                    final coordExp = RegExp(r'^(-?\d+\.\d+)[\s,]+(-?\d+\.\d+)$');
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
                                child: TextFormField(
                                  controller: _lngController,
                                  decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  onChanged: (value) {
                                    final coordExp = RegExp(r'^(-?\d+\.\d+)[\s,]+(-?\d+\.\d+)$');
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
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                child: const Icon(Icons.location_on),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _photoUrlController,
                                  decoration: const InputDecoration(labelText: 'URL da Foto (opcional)', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.attach_file),
                                label: Text(_selectedPhotoFile != null ? 'Trocar Anexo' : 'Anexar Foto'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedPhotoFile != null) ...[
                            const SizedBox(height: 8),
                            Text('Anexo: ${_selectedPhotoFile!.name}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _operatingHoursType = 'unknown'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _operatingHoursType == 'unknown' ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                                      border: Border.all(color: _operatingHoursType == 'unknown' ? Colors.blue : Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(child: Text('Desconhecido', style: TextStyle(color: _operatingHoursType == 'unknown' ? Colors.blue : Colors.black))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _operatingHoursType = '24h'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _operatingHoursType == '24h' ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                                      border: Border.all(color: _operatingHoursType == '24h' ? Colors.blue : Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(child: Text('24 Horas', style: TextStyle(color: _operatingHoursType == '24h' ? Colors.blue : Colors.black))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _operatingHoursType = 'custom'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _operatingHoursType == 'custom' ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                                      border: Border.all(color: _operatingHoursType == 'custom' ? Colors.blue : Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(child: Text('Personalizado', style: TextStyle(color: _operatingHoursType == 'custom' ? Colors.blue : Colors.black))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_operatingHoursType == 'custom') ...[
                            const SizedBox(height: 16),
                            _buildCustomScheduleEditor(),
                          ],
                          if (isEditing) ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _status,
                              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
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
                            title: const Text('Acessível (PCD)'),
                            value: _isAccessible,
                            onChanged: (val) => setState(() => _isAccessible = val),
                          ),
                          SwitchListTile(
                            title: const Text('Tem Trocador'),
                            value: _hasChangingTable,
                            onChanged: (val) => setState(() => _hasChangingTable = val),
                          ),
                          SwitchListTile(
                            title: const Text('Gratuito'),
                            value: _isFree,
                            onChanged: (val) => setState(() => _isFree = val),
                          ),
                        ],
                      ),
                    ),
                    // Coluna Direita: Mapa
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Localização (Arraste ou clique)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      _latController.text = point.latitude.toStringAsFixed(6);
                                      _lngController.text = point.longitude.toStringAsFixed(6);
                                    });
                                    _reverseGeocode(point.latitude, point.longitude);
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          Text('Lat: ${_selectedLocation.latitude.toStringAsFixed(5)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(5)}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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

  Widget _buildCustomScheduleEditor() {
    const days = {
      1: 'Segunda',
      2: 'Terça',
      3: 'Quarta',
      4: 'Quinta',
      5: 'Sexta',
      6: 'Sábado',
      7: 'Domingo',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: days.entries.map((entry) {
          final day = entry.key;
          final name = entry.value;
          final isOpen = _customSchedule.containsKey(day);
          final openTime = isOpen ? _customSchedule[day]!['open']! : '08:00';
          final closeTime = isOpen ? _customSchedule[day]!['close']! : '18:00';
          final isLast = day == 7;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isOpen,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _customSchedule[day] = {'open': '08:00', 'close': '18:00'};
                      } else {
                        _customSchedule.remove(day);
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 70,
                  child: Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: isOpen ? Colors.black : Colors.grey)),
                ),
                const Spacer(),
                _buildTimeButton(day, openTime, isOpen, true),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-')),
                _buildTimeButton(day, closeTime, isOpen, false),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeButton(int day, String time, bool isEnabled, bool isStart) {
    return InkWell(
      onTap: isEnabled ? () async {
        final initialParts = time.split(':');
        final initialTime = TimeOfDay(
          hour: int.tryParse(initialParts[0]) ?? 8,
          minute: int.tryParse(initialParts[1]) ?? 0,
        );

        final selected = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
        );

        if (selected != null) {
          final newTime = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
          setState(() {
            if (isStart) {
              _customSchedule[day]!['open'] = newTime;
            } else {
              _customSchedule[day]!['close'] = newTime;
            }
          });
        }
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isEnabled ? Colors.grey.shade400 : Colors.transparent),
        ),
        child: Text(time, style: TextStyle(color: isEnabled ? Colors.black : Colors.grey)),
      ),
    );
  }
}
