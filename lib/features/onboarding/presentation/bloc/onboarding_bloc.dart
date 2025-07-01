import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/interactors/onboarding_interactor.dart';
import '../../../../core/service_locator/service_locator.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// BLoC for managing onboarding flow
/// Handles first launch detection and onboarding completion
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingInteractor _interactor;

  OnboardingBloc()
    : _interactor = getIt<OnboardingInteractor>(),
      super(const OnboardingInitial()) {
    on<CheckFirstLaunch>((event, emit) => _onCheckFirstLaunch(emit));
    on<CompleteOnboarding>((event, emit) => _onCompleteOnboarding(emit));
    on<ResetOnboarding>((event, emit) => _onResetOnboarding(emit));
  }

  /// Handle checking if this is the first launch
  Future<void> _onCheckFirstLaunch(Emitter<OnboardingState> emit) async {
    emit(const OnboardingLoading());

    final result = await _interactor.shouldShowOnboarding();

    result.fold((failure) => emit(OnboardingError(failure.message)), (
      shouldShow,
    ) {
      if (shouldShow) {
        emit(const ShowOnboarding());
      } else {
        emit(const HideOnboarding());
      }
    });
  }

  /// Handle completing the onboarding process
  Future<void> _onCompleteOnboarding(Emitter<OnboardingState> emit) async {
    emit(const OnboardingLoading());

    final result = await _interactor.completeOnboarding();

    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (_) => emit(const OnboardingCompleted()),
    );
  }

  /// Handle resetting the onboarding state
  Future<void> _onResetOnboarding(Emitter<OnboardingState> emit) async {
    emit(const OnboardingLoading());

    final result = await _interactor.resetOnboarding();

    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (_) => emit(const ShowOnboarding()),
    );
  }
}
