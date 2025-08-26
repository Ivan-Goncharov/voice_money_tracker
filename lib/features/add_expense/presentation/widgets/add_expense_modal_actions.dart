part of 'add_expense_modal.dart';

class _ActionSection extends StatelessWidget {
  final VoidCallback? onSave;
  const _ActionSection({this.onSave});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddExpenseModalBloc, AddExpenseModalState>(
      listener: (context, state) {
        final failure = state.errorOf(Op.create);
        final status = state.status[Op.create];
        if (status == ExpenseStatus.success && state.createdExpenseId != null) {
          context.read<OnboardingBloc>().add(const CompleteOnboarding());
          context.read<NavigationBloc>().add(const HideExpenseModal());
        } else if (status == ExpenseStatus.failure && failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.busy(Op.create);

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
