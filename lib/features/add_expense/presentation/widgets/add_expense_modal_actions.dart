part of 'add_expense_modal.dart';

class _ActionSection extends StatelessWidget {
  final VoidCallback? onSave;
  const _ActionSection({this.onSave});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseCreated) {
          context.read<AnalyticsBloc>().add(const RefreshAnalytics());
          context.read<OnboardingBloc>().add(const CompleteOnboarding());
          context.read<NavigationBloc>().add(const HideExpenseModal());
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ExpenseLoading;

        return Container(
          width: double.infinity,
          decoration: AppTheme.gradientDecoration,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.textLight,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Save Expense',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textLight,
                      ),
                    ),
          ),
        );
      },
    );
  }
}
