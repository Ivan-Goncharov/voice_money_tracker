import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_2/core/data/database/app_database.dart';
import 'package:money_tracker_2/core/navigation/navigation_bloc.dart';
import 'package:money_tracker_2/core/theme/app_theme.dart';
import 'package:money_tracker_2/features/add_expense/presentation/blocs/add_expense_bloc/add_expense_modal_bloc.dart';
import 'package:money_tracker_2/features/add_expense/presentation/blocs/add_expense_bloc/add_expense_modal_event.dart';
import 'package:money_tracker_2/features/add_expense/presentation/blocs/add_expense_bloc/add_expense_modal_state.dart';
import 'package:money_tracker_2/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:money_tracker_2/features/category/presentation/bloc/category_bloc.dart';
import 'package:money_tracker_2/features/currency/presentation/bloc/currency_bloc.dart';
import 'package:money_tracker_2/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:money_tracker_2/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'category_selection_bottom_sheet.dart';
import 'date_selection_bottom_sheet.dart';
import 'currency_selection_bottom_sheet.dart';

part 'add_expense_modal_header.dart';
part 'add_expense_modal_selection.dart';
part 'add_expense_modal_amount.dart';
part 'add_expense_modal_description.dart';
part 'add_expense_modal_actions.dart';
part 'add_expense_modal_animated_button.dart';

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return 'Yesterday';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

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

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<CurrencyBloc>().add(const LoadDefaultCurrency());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: BlocBuilder<AddExpenseModalBloc, AddExpenseModalState>(
        builder: (context, modalState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ModalHeader(),
                  const SizedBox(height: 32),
                  _SelectionRow(
                    selectedCategory: modalState.selectedCategory,
                    selectedCurrency: modalState.selectedCurrency,
                    selectedDate: modalState.selectedDate,
                    onCategoryTap: _showCategorySelection,
                    onCurrencyTap: _showCurrencySelection,
                    onDateTap: _showDateSelection,
                  ),
                  const SizedBox(height: 40),
                  _AmountSection(
                    amountController: _amountController,
                    amountFocusNode: _amountFocusNode,
                    descriptionFocusNode: _descriptionFocusNode,
                    selectedCurrency: modalState.selectedCurrency,
                  ),
                  const SizedBox(height: 24),
                  _DescriptionField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                  ),
                  const SizedBox(height: 24),
                  _ActionSection(
                    onSave:
                        (_formKey.currentState?.validate() ?? false)
                            ? null
                            : () => _saveExpense(
                              modalState.selectedCategory,
                              modalState.selectedCurrency,
                              modalState.selectedDate,
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCategorySelection() {
    final categoryState = context.read<CategoryBloc>().state;
    final categories =
        (categoryState is CategoryLoaded)
            ? categoryState.categories
            : (categoryState is CategoryError &&
                categoryState.categories != null)
            ? categoryState.categories!
            : <CategoryEntity>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CategorySelectionBottomSheet(
            selectedCategory:
                context.read<AddExpenseModalBloc>().state.selectedCategory,
            categories: categories,
            onCategorySelected: (category) {
              // Dispatch selection to the modal bloc; bottom sheet handles pop.
              context.read<AddExpenseModalBloc>().add(
                SelectCategoryEvent(category),
              );
            },
          ),
    );
  }

  void _showDateSelection() {
    final currentDate = context.read<AddExpenseModalBloc>().state.selectedDate;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DateSelectionBottomSheet(
            selectedDate: currentDate,
            onDateSelected: (date) {
              context.read<AddExpenseModalBloc>().add(SelectDateEvent(date));
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
            selectedCurrency:
                context.read<AddExpenseModalBloc>().state.selectedCurrency,
            onCurrencySelected: (currency) {
              context.read<AddExpenseModalBloc>().add(
                SelectCurrencyEvent(currency),
              );
            },
          ),
    );
  }

  void _saveExpense(
    CategoryEntity? selectedCategory,
    CurrencyEntity? selectedCurrency,
    DateTime? selectedDate,
  ) {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();

    // If user didn't explicitly choose a currency, try to fall back to default
    CurrencyEntity? currency = selectedCurrency;
    final currencyState = context.read<CurrencyBloc>().state;
    if (currency == null &&
        currencyState is DefaultCurrencyLoaded &&
        currencyState.currency != null) {
      currency = currencyState.currency;
    } else if (currency == null &&
        currencyState is CurrenciesLoaded &&
        currencyState.defaultCurrency != null) {
      currency = currencyState.defaultCurrency;
    }

    context.read<ExpenseBloc>().add(
      CreateExpense(
        amount: amount,
        description: description.isEmpty ? null : description,
        categoryId: selectedCategory.id,
        date: selectedDate ?? DateTime.now(),
        currencyId: currency?.id,
        notes: null,
      ),
    );
  }
}
