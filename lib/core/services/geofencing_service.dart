import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

import '../../features/geofencing/domain/entities/geofence_event.dart';
import '../../features/geofencing/domain/entities/geofence_region.dart';

/// In-app geofence monitoring (Android-only for now).
///
/// Notes:
/// - This does NOT register OS-level geofences; it monitors location updates
///   while the app process is running.
class GeofencingService {
  final _controller = StreamController<GeofenceEvent>.broadcast();

  StreamSubscription<Position>? _positionSub;
  GeofenceRegion? _region;
  bool? _isInside;

  Stream<GeofenceEvent> get events => _controller.stream;

  Future<void> start(GeofenceRegion region) async {
    if (kIsWeb) {
      throw UnsupportedError('GeofencingService is not supported on web.');
    }
    if (!Platform.isAndroid) {
      throw UnsupportedError('GeofencingService is Android-only for now.');
    }

    await stop();
    _region = region;
    _isInside = null;

    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // meters
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((pos) => _onPosition(pos));
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _region = null;
    _isInside = null;
  }

  void _onPosition(Position pos) {
    final region = _region;
    if (region == null) return;

    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      region.latitude,
      region.longitude,
    );

    final insideNow = distance <= region.radiusMeters;
    final insidePrev = _isInside;
    _isInside = insideNow;

    if (insidePrev == null) return; // first fix: establish baseline only
    if (insidePrev == insideNow) return;

    _controller.add(GeofenceEvent(
      regionId: region.id,
      type: insideNow ? GeofenceEventType.enter : GeofenceEventType.exit,
      position: pos,
      occurredAt: DateTime.now(),
    ));
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}

