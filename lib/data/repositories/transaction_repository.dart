import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show IconData;

import '../../domain/models/category.dart' as domain;
import '../../domain/models/transaction.dart' as domain;
import '../database/app_database.dart';

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  // ---------------------------------------------------------------------------
  // CATEGORIES
  // ---------------------------------------------------------------------------

  // Fetches all categories from SQLite, converts each row into a domain Category.
  Future<List<domain.Category>> getAllCategories() async {
    final rows = await _db.select(_db.categoryTable).get();
    return rows.map(_toDomainCategory).toList();
  }

  // Inserts a new category row. `into()` targets the table, and
  // `CategoryTableCompanion` lets us omit the auto-increment `id`.
  Future<int> insertCategory(domain.Category cat) {
    return _db.into(_db.categoryTable).insert(
          CategoryTableCompanion.insert(
            name: cat.name,
            iconCodePoint: cat.icon.codePoint,
            type: cat.type == domain.TransactionType.earning
                ? 'earning'
                : 'expense',
          ),
        );
  }

  // Deletes a category by its id. Because the TransactionTable has
  // `onDelete: KeyAction.cascade`, all linked transactions are removed too.
  Future<void> deleteCategory(int id) {
    return (_db.delete(_db.categoryTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // TRANSACTIONS
  // ---------------------------------------------------------------------------

  // Fetches all transactions, ordered newest-first.
  Future<List<domain.Transaction>> getAllTransactions() async {
    final rows = await (_db.select(_db.transactionTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map(_toDomainTransaction).toList();
  }

  // Inserts a new transaction row.
  Future<int> insertTransaction(domain.Transaction txn) {
    return _db.into(_db.transactionTable).insert(
          TransactionTableCompanion.insert(
            description: txn.description,
            amount: txn.amount,
            date: txn.date,
            type: txn.type == domain.TransactionType.earning
                ? 'earning'
                : 'expense',
            categoryId: txn.categoryId!,
          ),
        );
  }

  // Deletes a single transaction by id.
  Future<void> deleteTransaction(int id) {
    return (_db.delete(_db.transactionTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Mappers: Drift rows → Domain models
  // ---------------------------------------------------------------------------

  domain.Category _toDomainCategory(CategoryTableData row) {
    return domain.Category(
      id: row.id,
      name: row.name,
      icon: IconData(row.iconCodePoint, fontFamily: 'MaterialIcons'),
      type: row.type == 'earning'
          ? domain.TransactionType.earning
          : domain.TransactionType.expense,
    );
  }

  domain.Transaction _toDomainTransaction(TransactionTableData row) {
    return domain.Transaction(
      id: row.id,
      description: row.description,
      amount: row.amount,
      date: row.date,
      type: row.type == 'earning'
          ? domain.TransactionType.earning
          : domain.TransactionType.expense,
      categoryId: row.categoryId,
    );
  }
}
