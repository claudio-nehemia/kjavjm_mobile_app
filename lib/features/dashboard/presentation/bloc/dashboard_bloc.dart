import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/get_dashboard_data.dart';
import '../../../../core/usecases/usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;

  DashboardBloc({
    required this.getDashboardDataUseCase,
  }) : super(DashboardInitial()) {
    on<GetDashboardDataEvent>(_onGetDashboardData);
  }

  Future<void> _onGetDashboardData(
    GetDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await getDashboardDataUseCase(NoParams());

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (dashboardData) => emit(DashboardLoaded(dashboardData: dashboardData)),
    );
  }
}