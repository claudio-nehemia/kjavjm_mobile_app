import '../entities/geofence_event.dart';
import '../entities/geofence_region.dart';

abstract class GeofencingRepository {
  Stream<GeofenceEvent> get events;

  Future<void> startMonitoring(GeofenceRegion region);
  Future<void> stopMonitoring();
}

