part of 'geofencing_cubit.dart';

class GeofencingState extends Equatable {
  final bool isMonitoring;
  final bool? isInside;
  final GeofenceEvent? lastEvent;

  const GeofencingState({
    this.isMonitoring = false,
    this.isInside,
    this.lastEvent,
  });

  GeofencingState copyWith({
    bool? isMonitoring,
    bool? isInside,
    GeofenceEvent? lastEvent,
  }) {
    return GeofencingState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isInside: isInside ?? this.isInside,
      lastEvent: lastEvent,
    );
  }

  @override
  List<Object?> get props => [isMonitoring, isInside, lastEvent];
}

