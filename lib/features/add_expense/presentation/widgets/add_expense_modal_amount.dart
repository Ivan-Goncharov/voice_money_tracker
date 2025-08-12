part of 'add_expense_modal.dart';

class _AmountSection extends StatelessWidget {
  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final FocusNode descriptionFocusNode;
  final CurrencyEntity? selectedCurrency;

  const _AmountSection({
    required this.amountController,
    required this.amountFocusNode,
    required this.descriptionFocusNode,
    this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = selectedCurrency?.symbol ?? '\$';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Text(
            'Amount',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              TextFormField(
                controller: amountController,
                focusNode: amountFocusNode,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  descriptionFocusNode.requestFocus();
                },
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 40),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              Positioned(
                left: 0,
                child: Text(
                  '$symbol ',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
