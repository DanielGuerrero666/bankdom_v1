// Step 6b: HomeScreen — now uses the repository for all data operations.
//
// On init, `_loadData()` fetches categories and transactions from SQLite.
// Every add/delete calls the repository first, then reloads the lists from
// the DB so the UI always reflects persisted state.
// Category stats (totalAmount, percentage) are still computed in-memory after
// each load since they are derived values, not stored data.

import 'package:flutter/material.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../domain/models/category.dart';
import '../../domain/models/transaction.dart';
import '../widgets/balance_circle.dart';
import '../widgets/category_list.dart';
import '../widgets/icon_picker_dialog.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  final TransactionRepository repository;

  const HomeScreen({
    super.key,
    required this.title,
    required this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  late TabController _tabController;
  bool _loading = true;

  TransactionRepository get _repo => widget.repository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Reads all data from the DB and recalculates derived stats.
  Future<void> _loadData() async {
    final categories = await _repo.getAllCategories();
    final transactions = await _repo.getAllTransactions();

    _recalculateCategoryStats(categories, transactions);

    setState(() {
      _categories = categories;
      _transactions = transactions;
      _loading = false;
    });
  }

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _totalEarnings => _transactions
      .where((t) => t.type == TransactionType.earning)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _balance => _totalEarnings - _totalExpenses;

  void _recalculateCategoryStats(
      List<Category> categories, List<Transaction> transactions) {
    final earningsTotal = transactions
        .where((t) => t.type == TransactionType.earning)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expensesTotal = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    for (final cat in categories) {
      final matching = transactions
          .where((t) => t.categoryId == cat.id && t.type == cat.type);
      cat.totalAmount = matching.fold(0.0, (sum, t) => sum + t.amount);

      final typeTotal =
          cat.type == TransactionType.earning ? earningsTotal : expensesTotal;
      cat.percentage =
          typeTotal == 0 ? 0.0 : (cat.totalAmount / typeTotal * 100);
    }
  }

  List<Category> _categoriesForType(TransactionType type) =>
      _categories.where((c) => c.type == type).toList();

  // Returns the category name for a given categoryId.
  String _categoryNameFor(int? categoryId) {
    if (categoryId == null) return '';
    final match = _categories.where((c) => c.id == categoryId);
    return match.isNotEmpty ? match.first.name : '';
  }

  // Returns the category icon for a given categoryId.
  IconData _categoryIconFor(int? categoryId) {
    if (categoryId == null) return Icons.label;
    final match = _categories.where((c) => c.id == categoryId);
    return match.isNotEmpty ? match.first.icon : Icons.label;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                  categoryNameFor: _categoryNameFor,
                  categoryIconFor: _categoryIconFor,
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
                  // Inserts into the DB, then reloads all data so the UI
                  // reflects the persisted state.
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    final desc = descController.text.trim();
                    if (amount != null && amount > 0 && desc.isNotEmpty) {
                      await _repo.insertTransaction(Transaction(
                        description: desc,
                        amount: amount,
                        date: DateTime.now(),
                        type: type,
                        categoryId: selectedCategory.id,
                      ));
                      await _loadData();
                      if (context.mounted) Navigator.pop(context);
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
                  // Inserts the category into the DB, reloads data.
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final exists = _categories
                          .any((c) => c.name == name && c.type == type);
                      if (!exists) {
                        await _repo.insertCategory(Category(
                          name: name,
                          icon: selectedIcon,
                          type: type,
                        ));
                        await _loadData();
                        if (context.mounted) Navigator.pop(context);
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
              // Deletes from DB, reloads data.
              onPressed: () async {
                await _repo.deleteTransaction(item.id!);
                await _loadData();
                if (context.mounted) Navigator.pop(context);
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
        _transactions.any((t) => t.categoryId == cat.id);

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
              // Cascade delete: the DB removes linked transactions automatically.
              onPressed: () async {
                await _repo.deleteCategory(cat.id!);
                await _loadData();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
