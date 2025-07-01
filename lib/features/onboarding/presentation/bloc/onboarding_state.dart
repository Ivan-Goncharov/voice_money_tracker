part of 'onboarding_bloc.dart';

/// States for OnboardingBloc
/// Represents all possible states during onboarding flow
sealed class OnboardingState {
  const OnboardingState();
}

/// Initial state when the bloc is created
final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Loading state while checking first launch status
final class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// State indicating that onboarding should be shown
/// This means it's the first launch and user needs to add their first expense
final class ShowOnboarding extends OnboardingState {
  const ShowOnboarding();
}

/// State indicating that onboarding should not be shown
/// This means the user has already completed onboarding
final class HideOnboarding extends OnboardingState {
  const HideOnboarding();
}

/// State indicating that onboarding has been completed
/// This is emitted after user successfully adds their first expense
final class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// Error state when something goes wrong
final class OnboardingError extends OnboardingState {
  const OnboardingError(this.message);

  final String message;
}
