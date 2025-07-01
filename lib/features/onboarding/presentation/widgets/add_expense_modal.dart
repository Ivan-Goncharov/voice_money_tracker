import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/navigation_bloc.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../expense/presentation/bloc/expense_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import 'category_selection_bottom_sheet.dart';
import 'date_selection_bottom_sheet.dart';

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
  DateTime _selectedDate = DateTime.now();
  CategoryBloc? _categoryBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryBloc ??= context.read<CategoryBloc>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  getIt<CategoryBloc>()..add(const LoadActiveCategories()),
        ),
        BlocProvider(create: (context) => getIt<ExpenseBloc>()),
      ],
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: _buildForm(),
            );
          },
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

          // Title with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppTheme.textLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Add Expense',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
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
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionButton(
                  icon: Icons.calendar_today,
                  label: _getFormattedDate(_selectedDate),
                  isSelected: true,
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
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    prefixStyle: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description field
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What did you spend on?',
              prefixIcon: Icon(Icons.description),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 16),

          // Save button
          BlocConsumer<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseCreated) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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

  void _showCategorySelection() {
    if (_categoryBloc == null) return;
    final categoryState = _categoryBloc!.state;

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
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
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

      context.read<ExpenseBloc>().add(
        CreateExpense(
          amount: amount,
          description: description,
          categoryId: _selectedCategory!.id,
          date: _selectedDate,
          notes: null, // Removed notes field for simplicity
        ),
      );
    }
  }
}
