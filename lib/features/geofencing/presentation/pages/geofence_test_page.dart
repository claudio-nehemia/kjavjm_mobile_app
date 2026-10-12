import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/utils/geofence_test_helper.dart';
import '../../../../core/utils/gps_kalman_filter.dart';
import '../../../../injection_container.dart';
import '../../../../shared/constants/app_constants.dart';

/// Halaman uji akurasi geofence (untuk pengumpulan data skripsi di lapangan).
class GeofenceTestPage extends StatefulWidget {
  const GeofenceTestPage({super.key});

  @override
  State<GeofenceTestPage> createState() => _GeofenceTestPageState();
}

class _GeofenceTestPageState extends State<GeofenceTestPage> {
  final LocationService _locationService = sl<LocationService>();
  final GpsKalmanFilter _kalman = GpsKalmanFilter();
  final List<GeofenceTestResult> _log = [];

  String _selectedTitik = 'T1';
  String _metode = 'M1';
  bool _loading = false;
  String? _error;

  GeofenceTestResult? _latest;

  /// Dapatkan ground truth dari titik yang dipilih.
  String get _currentGroundTruth {
    final point = GeofenceTestHelper.mercuBuanaMentengPoints
        .firstWhere((p) => p.id == _selectedTitik);
    return point.expectedLabel;
  }

  void _simulatePoint(MercuBuanaTestPoint point) {
    final result = GeofenceTestHelper.evaluate(
      point.latitude,
      point.longitude,
      groundTruth: point.expectedLabel,
    );
    setState(() {
      _selectedTitik = point.id;
      _latest = result;
      _log.insert(0, result);
      if (_log.length > 50) _log.removeLast();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${point.id} simulasi: ${result.predictedLabel} — ${result.distanceMeters.toStringAsFixed(0)} m',
        ),
      ),
    );
  }

  Future<void> _sampleLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final sw = Stopwatch()..start();
    try {
      final position = await _locationService.getCurrentLocation();
      sw.stop();

      if (position == null) {
        throw Exception('Lokasi tidak tersedia');
      }

      final GeofenceTestResult result;
      if (_metode == 'M2') {
        final rawLat = position.latitude;
        final rawLng = position.longitude;
        final filtered = _kalman.update(rawLat, rawLng);
        result = GeofenceTestHelper.evaluate(
          filtered.lat,
          filtered.lng,
          rawLat: rawLat,
          rawLng: rawLng,
          groundTruth: _currentGroundTruth,
        );
      } else {
        if (_metode == 'M1') _kalman.reset();
        result = GeofenceTestHelper.evaluate(
          position.latitude,
          position.longitude,
          groundTruth: _currentGroundTruth,
        );
      }

      setState(() {
        _latest = result;
        _log.insert(0, result);
        if (_log.length > 50) _log.removeLast();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.predictedLabel} — ${result.distanceMeters.toStringAsFixed(0)} m (${sw.elapsedMilliseconds} ms)',
            ),
            backgroundColor: result.isInside ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _copyLatestCsv() {
    if (_latest == null) return;
    final id = '${_metode}_${_selectedTitik}_${DateTime.now().millisecondsSinceEpoch % 100000}';
    const header = 'test_id,waktu,metode,titik,ground_truth,prediksi,benar,lat,lng,raw_lat,raw_lng,jarak_m';
    final row = _latest!.toCsvRow(testId: id, metode: _metode, titik: _selectedTitik);
    Clipboard.setData(ClipboardData(text: '$header\n$row'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Baris CSV disalin ke clipboard')),
    );
  }

  void _copyAllLogCsv() {
    if (_log.isEmpty) return;
    const header = 'test_id,waktu,metode,titik,ground_truth,prediksi,benar,lat,lng,raw_lat,raw_lng,jarak_m';
    final buffer = StringBuffer('$header\n');
    for (var i = 0; i < _log.length; i++) {
      final r = _log[i];
      buffer.writeln(
        r.toCsvRow(
          testId: '${_metode}_${_selectedTitik}_${i + 1}',
          metode: _metode,
          titik: _selectedTitik,
        ),
      );
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_log.length} baris CSV disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji Geofence — Mercu Buana Menteng'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          _buildConfigCard(),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildControlsCard(),
          const SizedBox(height: AppSizes.paddingMedium),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: AppSizes.paddingMedium),
          ],
          if (_latest != null) _buildResultCard(_latest!),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildSimulationCard(),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildReferencePointsCard(),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildLogCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _sampleLocation,
        icon: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.my_location),
        label: Text(_loading ? 'Mengambil GPS...' : 'Ambil Lokasi'),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(GeofenceConfig.allowedAreaName, style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text('Pusat: ${GeofenceConfig.centerLat}, ${GeofenceConfig.centerLng}'),
            Text('Radius: ${GeofenceConfig.radiusMeters.toStringAsFixed(0)} m'),
            Text('Metode aktif: $_metode (M1=Haversine)'),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTitik,
              decoration: const InputDecoration(labelText: 'Titik uji (ground truth)'),
              items: GeofenceTestHelper.mercuBuanaMentengPoints
                  .map((p) => DropdownMenuItem(value: p.id, child: Text('${p.id} — ${p.name}')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTitik = v ?? 'T1'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _metode,
              decoration: const InputDecoration(labelText: 'Metode algoritma'),
              items: const [
                DropdownMenuItem(
                  value: 'M1',
                  child: Text('M1 — Haversine (GPS mentah)'),
                ),
                DropdownMenuItem(
                  value: 'M2',
                  child: Text('M2 — Kalman (koordinat GPS)'),
                ),
                DropdownMenuItem(
                  value: 'M3',
                  child: Text('M3 — OS Geofence (label uji)'),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _metode = v ?? 'M1';
                  if (_metode != 'M2') _kalman.reset();
                });
              },
            ),
            if (_metode == 'M2') ...[
              const SizedBox(height: 8),
              Text(
                'Perbandingan: M1 = GPS mentah → Haversine. M2 = GPS Kalman → Haversine. '
                'Sampel Kalman: ${_kalman.sampleCount} (ambil 5–10× berturut di titik sama).',
                style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _latest == null ? null : _copyLatestCsv,
                    icon: const Icon(Icons.copy),
                    label: const Text('Salin 1 baris CSV'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _log.isEmpty ? null : _copyAllLogCsv,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Salin semua log'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(GeofenceTestResult r) {
    final point = GeofenceTestHelper.mercuBuanaMentengPoints
        .firstWhere((p) => p.id == _selectedTitik);
    final expected = point.expectedLabel;
    final correct = r.predictedLabel == expected;

    return Card(
      color: correct ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct ? '✓ Sesuai ground truth' : '✗ Tidak sesuai ground truth',
              style: AppTextStyles.heading3.copyWith(
                color: correct ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text('Prediksi: ${r.predictedLabel} | Seharusnya: $expected'),
            Text('Jarak ke pusat: ${r.distanceMeters.toStringAsFixed(1)} m'),
            if (r.rawLatitude != null) ...[
              Text(
                'GPS mentah: ${r.rawLatitude!.toStringAsFixed(6)}, ${r.rawLongitude!.toStringAsFixed(6)}',
              ),
              Text(
                'GPS Kalman: ${r.latitude.toStringAsFixed(6)}, ${r.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ] else ...[
              Text('Lat: ${r.latitude.toStringAsFixed(6)}'),
              Text('Lng: ${r.longitude.toStringAsFixed(6)}'),
            ],
            Text('Waktu: ${r.timestamp.toLocal()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Simulasi (tanpa GPS)', style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            const Text(
              'Klik titik untuk melihat hasil Haversine langsung — berguna preview skripsi di laptop.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GeofenceTestHelper.mercuBuanaMentengPoints.map((p) {
                return ActionChip(
                  label: Text(p.id),
                  onPressed: () => _simulatePoint(p),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencePointsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Titik referensi (perkiraan)', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            ...GeofenceTestHelper.mercuBuanaMentengPoints.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.id}: ${p.name} → ${p.expectedLabel}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(p.landmarkHint, style: AppTextStyles.caption),
                    Text(
                      'Ref: ${p.latitude}, ${p.longitude} (~${p.referenceDistanceMeters.toStringAsFixed(0)} m)',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              );
            }),
            const Text(
              'Verifikasi titik di Google Maps sebelum pengujian resmi.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard() {
    if (_log.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Text('Belum ada sampel. Tekan "Ambil Lokasi" di setiap titik T1–T5 (10×).'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log sampel (${_log.length})', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            ..._log.take(10).map((r) {
              return ListTile(
                dense: true,
                leading: Icon(
                  r.isInside ? Icons.check_circle : Icons.cancel,
                  color: r.isInside ? AppColors.success : AppColors.error,
                ),
                title: Text('${r.predictedLabel} — ${r.distanceMeters.toStringAsFixed(0)} m'),
                subtitle: Text(
                  '${r.latitude.toStringAsFixed(5)}, ${r.longitude.toStringAsFixed(5)}',
                ),
              );
            }),
            if (_log.length > 10)
              Text('... +${_log.length - 10} sampel lainnya', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
