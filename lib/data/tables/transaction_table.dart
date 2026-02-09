import 'package:drift/drift.dart';

import 'category_table.dart';

class TransactionTable extends Table {
  late final id = integer().autoIncrement()();

  late final description = text()();

  late final amount = real()();

  late final date = dateTime()();

  late final type = text()();

  // Foreign key: references CategoryTable.id.
  // Cascade delete means removing a category removes all its transactions.
  late final categoryId =
      integer().references(CategoryTable, #id, onDelete: KeyAction.cascade)();
}
