import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../data/models/user_model.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/persistent_login_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatus checkAuthStatus;
  final PersistentLoginService persistentLoginService;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatus,
    required this.persistentLoginService,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<AuthUserUpdated>(_onAuthUserUpdated);
    on<CheckPersistentLogin>(_onCheckPersistentLogin);
    on<UpdateActivity>(_onUpdateActivity);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        // Save login data for persistence
        await persistentLoginService.saveLoginData(
          user: user.toJson(),
          token: user.token ?? '',
        );
        
        // Only emit if emitter is still active
        if (!emit.isDone) {
          emit(AuthAuthenticated(user: user));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase(NoParams());

    // Clear persistent login data
    await persistentLoginService.clearLoginData();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final result = await checkAuthStatus(NoParams());
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    // Also update persistent storage
    await persistentLoginService.saveLoginData(
      user: event.user.toJson(),
      token: event.user.token ?? '',
    );
    emit(AuthAuthenticated(user: event.user));
  }

  Future<void> _onCheckPersistentLogin(
    CheckPersistentLogin event,
    Emitter<AuthState> emit,
  ) async {
    final cachedUserData = await persistentLoginService.getCachedUser();
    
    if (cachedUserData != null) {
      try {
        // Convert cached data back to User entity
        final user = UserModel.fromJson(cachedUserData);
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        // If conversion fails, clear cache and emit unauthenticated
        await persistentLoginService.clearLoginData();
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateActivity(
    UpdateActivity event,
    Emitter<AuthState> emit,
  ) async {
    await persistentLoginService.updateActivity();
  }
}