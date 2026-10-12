import 'package:geolocator/geolocator.dart';

import '../../shared/constants/app_constants.dart';

/// Hasil evaluasi jarak ke pusat geofence (untuk pengujian & absensi).
class GeofenceTestResult {
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final bool isInside;
  final DateTime timestamp;

  /// GPS mentah sebelum Kalman (null jika metode M1).
  final double? rawLatitude;
  final double? rawLongitude;

  /// Ground truth label (INSIDE/OUTSIDE).
  final String? groundTruth;

  const GeofenceTestResult({
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.isInside,
    required this.timestamp,
    this.rawLatitude,
    this.rawLongitude,
    this.groundTruth,
  });

  String get predictedLabel => isInside ? 'INSIDE' : 'OUTSIDE';

  String? get isCorrect => groundTruth != null
      ? (predictedLabel == groundTruth ? 'YA' : 'TIDAK')
      : null;

  String toCsvRow({
    required String testId,
    required String metode,
    required String titik,
  }) {
    final columns = [
      testId,
      timestamp.toLocal().toIso8601String(),
      metode,
      titik,
      groundTruth ?? '',
      predictedLabel,
      isCorrect ?? '',
      latitude.toStringAsFixed(6),
      longitude.toStringAsFixed(6),
      rawLatitude?.toStringAsFixed(6) ?? '',
      rawLongitude?.toStringAsFixed(6) ?? '',
      distanceMeters.toStringAsFixed(1),
    ];
    return columns.join(',');
  }
}

/// Titik referensi uji di sekitar Mercu Buana Menteng (perkiraan — verifikasi di lapangan).
class MercuBuanaTestPoint {
  final String id;
  final String name;
  final String landmarkHint;
  final double latitude;
  final double longitude;
  final String expectedLabel;

  const MercuBuanaTestPoint({
    required this.id,
    required this.name,
    required this.landmarkHint,
    required this.latitude,
    required this.longitude,
    required this.expectedLabel,
  });

  double get referenceDistanceMeters => Geolocator.distanceBetween(
    latitude,
    longitude,
    GeofenceConfig.centerLat,
    GeofenceConfig.centerLng,
  );
}

class GeofenceTestHelper {
  static GeofenceTestResult evaluate(
    double lat,
    double lng, {
    double? rawLat,
    double? rawLng,
    String? groundTruth,
  }) {
    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      GeofenceConfig.centerLat,
      GeofenceConfig.centerLng,
    );

    return GeofenceTestResult(
      latitude: lat,
      longitude: lng,
      distanceMeters: distance,
      isInside: distance <= GeofenceConfig.radiusMeters,
      timestamp: DateTime.now(),
      rawLatitude: rawLat,
      rawLongitude: rawLng,
      groundTruth: groundTruth,
    );
  }

  /// Titik uji skripsi — sesuaikan koordinat setelah penandaan di Google Maps.
  static const List<MercuBuanaTestPoint> mercuBuanaMentengPoints = [
    MercuBuanaTestPoint(
      id: 'T1',
      name: 'Dalam jelas',
      landmarkHint:
          'Lobi / area utama Gedung Tedja Buana (Jl. Menteng Raya 29)',
      latitude: -6.18515,
      longitude: 106.8364,
      expectedLabel: 'INSIDE',
    ),
    MercuBuanaTestPoint(
      id: 'T2',
      name: 'Tepi dalam',
      landmarkHint: '~180 m dari pusat geofence, masih di dalam kampus',
      latitude: -6.18398,
      longitude: 106.8364,
      expectedLabel: 'INSIDE',
    ),
    MercuBuanaTestPoint(
      id: 'T3',
      name: 'Tepi luar',
      landmarkHint: 'Trotoar luar / tepi Jl. Menteng Raya (~220 m dari pusat)',
      latitude: -6.18362,
      longitude: 106.8364,
      expectedLabel: 'OUTSIDE',
    ),
    MercuBuanaTestPoint(
      id: 'T4',
      name: 'Luar jelas',
      landmarkHint: 'Jauh dari kampus (mis. arah Gondangdia / ≥500 m)',
      latitude: -6.18110,
      longitude: 106.8364,
      expectedLabel: 'OUTSIDE',
    ),
    MercuBuanaTestPoint(
      id: 'T5',
      name: 'GPS tidak stabil',
      landmarkHint: 'Koridor dalam / dekat dinding — uji flicker GPS',
      latitude: -6.18400,
      longitude: 106.8360,
      expectedLabel: 'INSIDE',
    ),
  ];
}
