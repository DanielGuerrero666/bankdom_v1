import 'package:flutter/material.dart';

import '../../domain/models/category.dart';
import '../../domain/models/transaction.dart';
import '../widgets/balance_circle.dart';
import '../widgets/category_list.dart';
import '../widgets/icon_picker_dialog.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Transaction> _transactions = [];
  final List<Category> _categories = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _totalEarnings => _transactions
      .where((t) => t.type == TransactionType.earning)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _balance => _totalEarnings - _totalExpenses;

  void _recalculateCategoryStats() {
    for (final cat in _categories) {
      final matching = _transactions
          .where((t) => t.categoryName == cat.name && t.type == cat.type);
      cat.totalAmount = matching.fold(0.0, (sum, t) => sum + t.amount);

      final typeTotal =
          cat.type == TransactionType.earning ? _totalEarnings : _totalExpenses;
      cat.percentage = typeTotal == 0 ? 0.0 : (cat.totalAmount / typeTotal * 100);
    }
  }

  List<Category> _categoriesForType(TransactionType type) =>
      _categories.where((c) => c.type == type).toList();

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
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Transactions'),
              Tab(text: 'Categories'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TransactionList(
                  items: _transactions,
                  categories: _categories,
                  onAddEarning: _openAddEarningDialog,
                  onAddExpense: _openAddExpenseDialog,
                  onDelete: _confirmDeleteTransaction,
                ),
                CategoryList(
                  categories: _categories,
                  onAddEarningCategory: () =>
                      _openAddCategoryDialog(TransactionType.earning),
                  onAddExpenseCategory: () =>
                      _openAddCategoryDialog(TransactionType.expense),
                  onDelete: _confirmDeleteCategory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAddExpenseDialog() {
    final expenseCategories = _categoriesForType(TransactionType.expense);
    if (expenseCategories.isEmpty) {
      _showNoCategoriesWarning(TransactionType.expense);
      return;
    }
    _openAddTransactionDialog(
      title: 'Add Expense',
      type: TransactionType.expense,
      typeCategories: expenseCategories,
    );
  }

  void _openAddEarningDialog() {
    final earningCategories = _categoriesForType(TransactionType.earning);
    if (earningCategories.isEmpty) {
      _showNoCategoriesWarning(TransactionType.earning);
      return;
    }
    _openAddTransactionDialog(
      title: 'Add Earning',
      type: TransactionType.earning,
      typeCategories: earningCategories,
    );
  }

  void _showNoCategoriesWarning(TransactionType type) {
    final label = type == TransactionType.earning ? 'earning' : 'expense';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Create an $label category first.')),
    );
    _tabController.animateTo(1);
  }

  void _openAddTransactionDialog({
    required String title,
    required TransactionType type,
    required List<Category> typeCategories,
  }) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    Category selectedCategory = typeCategories.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Category>(
                    initialValue: selectedCategory,
                    decoration:
                        const InputDecoration(labelText: 'Category'),
                    items: typeCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 20),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    decoration:
                        const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Amount'),
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
                          categoryName: selectedCategory.name,
                        ));
                        _recalculateCategoryStats();
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
      },
    );
  }

  void _openAddCategoryDialog(TransactionType type) {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.label;
    final label = type == TransactionType.earning ? 'Earning' : 'Expense';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('New $label Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Icon: '),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final picked = await showIconPicker(context);
                          if (picked != null) {
                            setDialogState(() => selectedIcon = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(selectedIcon, size: 32),
                        ),
                      ),
                    ],
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
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final exists = _categories
                          .any((c) => c.name == name && c.type == type);
                      if (!exists) {
                        setState(() {
                          _categories.add(Category(
                            name: name,
                            icon: selectedIcon,
                            type: type,
                          ));
                        });
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
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
          title: const Text('Delete Transaction'),
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
                  _recalculateCategoryStats();
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

  void _confirmDeleteCategory(int index) {
    final cat = _categories[index];
    final hasTransactions =
        _transactions.any((t) => t.categoryName == cat.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            hasTransactions
                ? '"${cat.name}" has transactions. Delete category and all its transactions?'
                : 'Delete category "${cat.name}"?',
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
                  _transactions.removeWhere(
                      (t) => t.categoryName == cat.name && t.type == cat.type);
                  _categories.removeAt(index);
                  _recalculateCategoryStats();
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
