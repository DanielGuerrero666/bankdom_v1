import 'package:flutter/material.dart';

import '../../domain/models/transaction.dart';
import '../widgets/balance_circle.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _totalEarnings => _transactions
      .where((t) => t.type == TransactionType.earning)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _balance => _totalEarnings - _totalExpenses;

  void _recalculatePercentages() {
    for (final t in _transactions) {
      if (t.type == TransactionType.earning) {
        t.percentage = t.amount / _totalEarnings * 100;
      }
      else if (t.type == TransactionType.expense) {
        t.percentage = t.amount / _totalExpenses * 100;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(child: BalanceCircle(balance: _balance)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '+\$${_totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                Text(
                  '-\$${_totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: TransactionList(
              items: _transactions,
              onAddEarning: _openAddEarningDialog,
              onAddExpense: _openAddExpenseDialog,
              onDelete: _confirmDeleteTransaction,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddExpenseDialog() {
    _openAddTransactionDialog(
      title: 'Add Expense',
      type: TransactionType.expense,
    );
  }

  void _openAddEarningDialog() {
    _openAddTransactionDialog(
      title: 'Add Earning',
      type: TransactionType.earning,
    );
  }

  void _openAddTransactionDialog({
    required String title,
    required TransactionType type,
  }) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final desc = descController.text.trim();
                if (amount != null && amount > 0 && desc.isNotEmpty) {
                  setState(() {
                    _transactions.add(Transaction(
                      description: desc,
                      amount: amount,
                      date: DateTime.now(),
                      type: type,
                    ));
                    _recalculatePercentages();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTransaction(int index) {
    final item = _transactions[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: Text(
            'Remove "${item.description}" (\$${item.amount.toStringAsFixed(2)})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _transactions.removeAt(index);
                  _recalculatePercentages();
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
