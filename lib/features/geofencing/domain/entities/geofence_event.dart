import 'package:geolocator/geolocator.dart';

enum GeofenceEventType { enter, exit }

class GeofenceEvent {
  final String regionId;
  final GeofenceEventType type;
  final Position position;
  final DateTime occurredAt;

  const GeofenceEvent({
    required this.regionId,
    required this.type,
    required this.position,
    required this.occurredAt,
  });
}

