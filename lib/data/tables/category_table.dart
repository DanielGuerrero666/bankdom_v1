import 'package:drift/drift.dart';

class CategoryTable extends Table {
  // Auto-incrementing integer primary key — Drift makes this the sole PK.
  late final id = integer().autoIncrement()();

  // Category display name, must be non-empty.
  late final name = text()();

  // Flutter's IconData.codePoint stored as an int so we can reconstruct
  // the icon on read.
  late final iconCodePoint = integer()();

  // 'earning' or 'expense' — stored as text for readability.
  late final type = text()();
}
