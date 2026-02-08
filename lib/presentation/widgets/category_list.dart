import 'package:flutter/material.dart';

import '../../domain/models/category.dart';
import '../../domain/models/transaction.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback onAddEarningCategory;
  final VoidCallback onAddExpenseCategory;
  final void Function(int) onDelete;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onAddEarningCategory,
    required this.onAddExpenseCategory,
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
                icon: const Icon(Icons.add_circle, size: 28),
                color: Colors.green,
                onPressed: onAddEarningCategory,
                tooltip: 'Add Earning Category',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 28),
                color: Colors.red,
                onPressed: onAddExpenseCategory,
                tooltip: 'Add Expense Category',
              ),
            ],
          ),
        ),
        Expanded(
          child: categories.isEmpty
              ? const Center(
                  child: Text(
                    'No categories yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isEarning = cat.type == TransactionType.earning;
                    final color = isEarning ? Colors.green : Colors.red;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(cat.icon, color: color),
                            title: Text(cat.name),
                            subtitle: Text(
                              '${cat.percentage.toStringAsFixed(1)}% of ${isEarning ? 'earnings' : 'expenses'}',
                            ),
                            trailing: Text(
                              '\$${cat.totalAmount.toStringAsFixed(2)}',
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
                              value: (cat.percentage / 100).clamp(0.0, 1.0),
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
