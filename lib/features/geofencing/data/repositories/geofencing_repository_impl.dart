import '../../../../core/services/geofencing_service.dart';
import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/geofence_region.dart';
import '../../domain/repositories/geofencing_repository.dart';

class GeofencingRepositoryImpl implements GeofencingRepository {
  final GeofencingService service;

  GeofencingRepositoryImpl({required this.service});

  @override
  Stream<GeofenceEvent> get events => service.events;

  @override
  Future<void> startMonitoring(GeofenceRegion region) => service.start(region);

  @override
  Future<void> stopMonitoring() => service.stop();
}

