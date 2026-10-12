import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/geofence_region.dart';
import '../../domain/repositories/geofencing_repository.dart';

part 'geofencing_state.dart';

class GeofencingCubit extends Cubit<GeofencingState> {
  final GeofencingRepository repository;
  StreamSubscription<GeofenceEvent>? _sub;

  GeofencingCubit({required this.repository}) : super(const GeofencingState()) {
    _sub = repository.events.listen((event) {
      emit(state.copyWith(
        isInside: event.type == GeofenceEventType.enter,
        lastEvent: event,
      ));
    });
  }

  Future<void> start(GeofenceRegion region) async {
    emit(state.copyWith(isMonitoring: true));
    await repository.startMonitoring(region);
  }

  Future<void> stop() async {
    await repository.stopMonitoring();
    emit(state.copyWith(isMonitoring: false, isInside: null, lastEvent: null));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

