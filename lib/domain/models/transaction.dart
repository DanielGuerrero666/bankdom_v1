// Step 5a: Updated Transaction domain model.
//
// Added `id` (nullable because it's null before the DB assigns one)
// and `categoryId` to link to the persisted category row.
// Removed `categoryName` — we now reference categories by their DB id.

enum TransactionType { earning, expense }

class Transaction {
  final int? id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final int? categoryId;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    this.categoryId,
  });
}
