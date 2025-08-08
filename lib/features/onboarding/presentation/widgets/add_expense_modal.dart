import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/database/database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/navigation_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../expense/presentation/bloc/expense_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../currency/presentation/bloc/currency_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import 'category_selection_bottom_sheet.dart';
import 'date_selection_bottom_sheet.dart';
import 'currency_selection_bottom_sheet.dart';

/// Modal widget for adding a new expense
/// Used during onboarding and regular expense addition
class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryEntity? _selectedCategory;
  CurrencyEntity? _selectedCurrency;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Trigger default currency loading when modal is built
    context.read<CurrencyBloc>().add(const LoadDefaultCurrency());

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: IntrinsicHeight(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              'App Expense',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 32),

          // Selection buttons row
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  icon: Icons.category,
                  label: _selectedCategory?.name ?? 'Category',
                  isSelected: _selectedCategory != null,
                  onTap: _showCategorySelection,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocConsumer<CurrencyBloc, CurrencyState>(
                  listener: (context, state) {
                    if (state is DefaultCurrencyLoaded &&
                        state.currency != null) {
                      setState(() {
                        _selectedCurrency = state.currency;
                      });
                    }
                  },
                  builder: (context, state) {
                    String label = '₽';
                    bool isSelected = false;

                    if (state is DefaultCurrencyLoaded &&
                        state.currency != null) {
                      label = state.currency!.symbol;
                      isSelected = true;
                    } else if (_selectedCurrency != null) {
                      label = _selectedCurrency!.symbol;
                      isSelected = true;
                    }

                    return _buildSelectionButton(
                      icon: Icons.attach_money,
                      label: label,
                      isSelected: isSelected,
                      onTap: _showCurrencySelection,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateSelectionButton(
                  icon: Icons.calendar_today,
                  label: _getFormattedDate(_selectedDate),
                  onTap: _showDateSelection,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Amount field - centered and prominent
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                Text(
                  'Amount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered text field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
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
                    // Dollar sign positioned on the left
                    Positioned(
                      left: 0,
                      child: Text(
                        '\$ ',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description field (optional)
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'What did you spend on?',
              prefixIcon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 16),

          // Save button
          BlocConsumer<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseCreated) {
                // Refresh analytics to show the new transaction
                context.read<AnalyticsBloc>().add(const RefreshAnalytics());

                // Complete onboarding if this is the first expense
                context.read<OnboardingBloc>().add(const CompleteOnboarding());
                // Close modal
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
                  onPressed: isLoading ? null : _saveExpense,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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

  Widget _buildDateSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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

  void _showCategorySelection() {
    final categoryState = context.read<CategoryBloc>().state;

    List<CategoryEntity> categories = [];
    if (categoryState is CategoryLoaded) {
      categories = categoryState.categories;
    } else if (categoryState is CategoryCreated) {
      categories = categoryState.categories;
    } else if (categoryState is CategoryUpdated) {
      categories = categoryState.categories;
    } else if (categoryState is CategoryDeleted) {
      categories = categoryState.categories;
    } else if (categoryState is CategoryError &&
        categoryState.categories != null) {
      categories = categoryState.categories!;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CategorySelectionBottomSheet(
            selectedCategory: _selectedCategory,
            categories: categories,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
    );
  }

  void _showDateSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DateSelectionBottomSheet(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
    );
  }

  void _showCurrencySelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CurrencySelectionBottomSheet(
            selectedCurrency: _selectedCurrency,
            onCurrencySelected: (currency) {
              setState(() {
                _selectedCurrency = currency;
              });
            },
          ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _saveExpense() {
    print('DEBUG: _saveExpense called');

    if (_formKey.currentState!.validate()) {
      print('DEBUG: Form validation passed');

      if (_selectedCategory == null) {
        print('DEBUG: No category selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      print(
        'DEBUG: Creating expense - amount: $amount, description: $description, categoryId: ${_selectedCategory!.id}, currencyId: ${_selectedCurrency?.id}',
      );

      context.read<ExpenseBloc>().add(
        CreateExpense(
          amount: amount,
          description: description.isEmpty ? null : description,
          categoryId: _selectedCategory!.id,
          date: _selectedDate,
          currencyId: _selectedCurrency?.id,
          notes: null, // Removed notes field for simplicity
        ),
      );
    } else {
      print('DEBUG: Form validation failed');
    }
  }
}

/// Animated button widget with scale effect on tap
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButton({required this.child, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
