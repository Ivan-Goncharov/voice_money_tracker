import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/navigation_bloc.dart';
import '../bloc/onboarding_bloc.dart';

/// Home screen that handles the onboarding flow
/// Shows the add expense modal on first launch
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => getIt<OnboardingBloc>()..add(const CheckFirstLaunch()),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Money Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: BlocListener<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is ShowOnboarding) {
              context.read<NavigationBloc>().add(
                const ShowCreateExpenseModal(),
              );
            } else if (state is OnboardingCompleted) {
              // Hide modal and show success message
              context.read<NavigationBloc>().add(const HideExpenseModal());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Welcome! Your first expense has been added.'),
                  backgroundColor: AppTheme.success,
                ),
              );
            } else if (state is OnboardingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppTheme.error,
                ),
              );
            }
          },
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome to Money Tracker',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Track your expenses easily and beautifully',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: AppTheme.gradientDecoration,
        child: FloatingActionButton(
          onPressed:
              () => context.read<NavigationBloc>().add(
                const ShowCreateExpenseModal(),
              ),
          tooltip: 'Add Expense',
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: AppTheme.textLight, size: 28),
        ),
      ),
    );
  }
}
