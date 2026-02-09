import 'package:flutter/material.dart';

import '../../domain/models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> items;
  final String Function(int?) categoryNameFor;
  final IconData Function(int?) categoryIconFor;
  final VoidCallback onAddEarning;
  final VoidCallback onAddExpense;
  final void Function(int) onDelete;

  const TransactionList({
    super.key,
    required this.items,
    required this.categoryNameFor,
    required this.categoryIconFor,
    required this.onAddEarning,
    required this.onAddExpense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.trending_up, size: 28),
                color: Colors.green,
                onPressed: onAddEarning,
                tooltip: 'Add Earning',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.receipt_long, size: 28),
                color: Colors.red,
                onPressed: onAddExpense,
                tooltip: 'Add Expense',
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isEarning = item.type == TransactionType.earning;
                    final color = isEarning ? Colors.green : Colors.red;
                    final prefix = isEarning ? '+' : '-';
                    final icon = categoryIconFor(item.categoryId);
                    final catName = categoryNameFor(item.categoryId);

                    return ListTile(
                      leading: Icon(icon, color: color),
                      title: Text(item.description),
                      subtitle: Text(
                        '$catName  ·  ${item.date.month}/${item.date.day}/${item.date.year}',
                      ),
                      trailing: Text(
                        '$prefix\$${item.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onLongPress: () => onDelete(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
