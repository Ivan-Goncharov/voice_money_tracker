import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/database/database.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/category_pie_chart.dart';

/// Analytics screen showing financial overview
/// Displays current balance, monthly expenses/income, category chart, and recent transactions
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(const LoadAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              return switch (state) {
                AnalyticsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                AnalyticsError() => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).errorLoadingAnalytics,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            () => context.read<AnalyticsBloc>().add(
                              const LoadAnalytics(),
                            ),
                        child: Text(AppLocalizations.of(context).retry),
                      ),
                    ],
                  ),
                ),

                AnalyticsLoaded() => RefreshIndicator(
                  onRefresh: () async {
                    context.read<AnalyticsBloc>().add(const RefreshAnalytics());
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          AppLocalizations.of(context).analytics,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // Balance Card
                        _buildBalanceCard(context, state.balance),
                        const SizedBox(height: 16),

                        // Monthly Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildExpenseCard(
                                context,
                                state.monthlyExpenses,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildIncomeCard(
                                context,
                                state.monthlyIncome,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Category Chart Section
                        _buildCategoryChartSection(
                          context,
                          state.categoryBreakdown,
                        ),
                        const SizedBox(height: 24),

                        // Recent Transactions Section
                        _buildRecentTransactionsSection(
                          context,
                          state.recentTransactions,
                        ),
                      ],
                    ),
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).currentBalance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textLight.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, double expenses) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, color: AppTheme.error, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).expenses,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${expenses.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.error,
            ),
          ),
          Text(
            AppLocalizations.of(context).thisMonth,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, double income) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Income',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${income.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.success,
            ),
          ),
          Text(
            'This month',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChartSection(
    BuildContext context,
    List<CategoryExpenseData> categoryBreakdown,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CategoryPieChart(categoryBreakdown: categoryBreakdown),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(
    BuildContext context,
    List<ExpenseWithCategory> recentTransactions,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all transactions
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentTransactions.isEmpty)
            const Center(child: Text('No recent transactions'))
          else
            ...recentTransactions.map(
              (transaction) => _buildTransactionItem(context, transaction),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    ExpenseWithCategory transaction,
  ) {
    final categoryColor =
        transaction.category?.color != null
            ? Color(
              int.parse(
                '0xFF${transaction.category!.color.replaceAll('#', '')}',
              ),
            )
            : AppTheme.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              IconData(
                transaction.category?.iconCodePoint ??
                    0xe59c, // default shopping bag
                fontFamily: 'MaterialIcons',
              ),
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.expense.description ?? 'No description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  transaction.category?.name ?? 'Unknown Category',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-\$${transaction.expense.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
