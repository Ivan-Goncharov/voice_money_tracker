part of 'onboarding_bloc.dart';

/// Events for OnboardingBloc
/// Represents all possible user actions and system events for onboarding
sealed class OnboardingEvent {
  const OnboardingEvent();
}

/// Check if onboarding should be shown
/// This is typically called when the app starts
final class CheckFirstLaunch extends OnboardingEvent {
  const CheckFirstLaunch();
}

/// Complete the onboarding process
/// This is called after user adds their first expense
final class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

/// Reset onboarding state
/// This is useful for testing or app reset functionality
final class ResetOnboarding extends OnboardingEvent {
  const ResetOnboarding();
}
