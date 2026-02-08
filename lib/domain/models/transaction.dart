enum TransactionType { earning, expense }

class Transaction {
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryName;

  Transaction({
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryName,
  });
}
