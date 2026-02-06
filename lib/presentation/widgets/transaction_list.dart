import 'package:flutter/material.dart';

import '../../domain/models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> items;
  final VoidCallback onAddEarning;
  final VoidCallback onAddExpense;
  final void Function(int) onDelete;

  const TransactionList({
    super.key,
    required this.items,
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
                    final icon = isEarning
                        ? Icons.trending_up
                        : Icons.receipt_long;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(icon, color: color),
                            title: Text(item.description),
                            subtitle: Text(
                              '${item.date.month}/${item.date.day}/${item.date.year}  ·  ${item.percentage.toStringAsFixed(1)}% of ${isEarning ? 'earnings' : 'expenses'}',
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
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (item.percentage / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
