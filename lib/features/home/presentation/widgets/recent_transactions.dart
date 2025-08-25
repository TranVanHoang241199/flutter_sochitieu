import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/models/income_expense.dart';
import '../../../../core/constants/app_constants.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeExpenses = ref.watch(incomeExpensesProvider);
    
    if (incomeExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Lấy 5 giao dịch gần nhất
    final recentTransactions = incomeExpenses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Giao dịch gần đây',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all transactions
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.length,
          itemBuilder: (context, index) {
            final transaction = recentTransactions[index];
            return _TransactionItem(transaction: transaction);
          },
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final IncomeExpense transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == IncomeExpenseType.income;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            // Icon và màu sắc
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isIncome 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: isIncome ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            
            const SizedBox(width: AppConstants.defaultPadding),
            
            // Thông tin giao dịch
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? 'Không có mô tả',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            // Số tiền
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} VND',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.currency ?? 'VND',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Hôm nay';
    } else if (transactionDate == yesterday) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
