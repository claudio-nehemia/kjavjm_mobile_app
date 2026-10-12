/// Filter Kalman 1D sederhana — dipakai terpisah untuk latitude & longitude.
class _ScalarKalman {
  double? _estimate;
  double _errorCovariance;
  final double _processNoise;
  final double _measurementNoise;

  _ScalarKalman({
    required double processNoise,
    required double measurementNoise,
  })  : _processNoise = processNoise,
        _measurementNoise = measurementNoise,
        _errorCovariance = 1.0;

  double update(double measurement) {
    if (_estimate == null) {
      _estimate = measurement;
      return measurement;
    }

    // Predict
    _errorCovariance += _processNoise;

    // Update
    final kalmanGain =
        _errorCovariance / (_errorCovariance + _measurementNoise);
    _estimate = _estimate! + kalmanGain * (measurement - _estimate!);
    _errorCovariance = (1 - kalmanGain) * _errorCovariance;

    return _estimate!;
  }

  void reset() {
    _estimate = null;
    _errorCovariance = 1.0;
  }
}

/// Merapikan koordinat GPS (lat/lng) sebelum hitung jarak geofence.
class GpsKalmanFilter {
  late final _ScalarKalman _latFilter;
  late final _ScalarKalman _lngFilter;
  int _sampleCount = 0;

  GpsKalmanFilter({
    double processNoise = 0.00001,
    double measurementNoise = 0.0001,
  }) {
    _latFilter = _ScalarKalman(
      processNoise: processNoise,
      measurementNoise: measurementNoise,
    );
    _lngFilter = _ScalarKalman(
      processNoise: processNoise,
      measurementNoise: measurementNoise,
    );
  }

  int get sampleCount => _sampleCount;

  /// Mengembalikan (latFiltered, lngFiltered).
  ({double lat, double lng}) update(double lat, double lng) {
    _sampleCount++;
    return (
      lat: _latFilter.update(lat),
      lng: _lngFilter.update(lng),
    );
  }

  void reset() {
    _latFilter.reset();
    _lngFilter.reset();
    _sampleCount = 0;
  }
}
