part of 'add_expense_modal.dart';

class _SelectionRow extends StatelessWidget {
  final CategoryEntity? selectedCategory;
  final CurrencyEntity? selectedCurrency;
  final DateTime selectedDate;
  final VoidCallback onCategoryTap;
  final VoidCallback onCurrencyTap;
  final VoidCallback onDateTap;

  const _SelectionRow({
    required this.selectedCategory,
    required this.selectedCurrency,
    required this.selectedDate,
    required this.onCategoryTap,
    required this.onCurrencyTap,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SelectionButton(
            icon: Icons.category,
            label: selectedCategory?.name ?? 'Category',
            isSelected: selectedCategory != null,
            onTap: onCategoryTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<CurrencyBloc, CurrencyState>(
            builder: (context, state) {
              String label = '₽';
              bool isSelected = false;

              if (state is DefaultCurrencyLoaded && state.currency != null) {
                label = state.currency!.symbol;
                isSelected = true;
              } else if (selectedCurrency != null) {
                label = selectedCurrency!.symbol;
                isSelected = true;
              }

              return _SelectionButton(
                icon: Icons.attach_money,
                label: label,
                isSelected: isSelected,
                onTap: onCurrencyTap,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DateSelectionButton(
            icon: Icons.calendar_today,
            label: _formatDate(selectedDate),
            onTap: onDateTap,
          ),
        ),
      ],
    );
  }
}

class _SelectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                  : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateSelectionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
