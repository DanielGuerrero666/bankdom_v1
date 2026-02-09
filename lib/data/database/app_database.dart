import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../tables/category_table.dart';
import '../tables/transaction_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CategoryTable, TransactionTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'bankdom'));

  @override
  int get schemaVersion => 1;
}
