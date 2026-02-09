import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bankdom_v1/data/database/app_database.dart';
import 'package:bankdom_v1/data/repositories/transaction_repository.dart';
import 'package:bankdom_v1/main.dart';

void main() {
  testWidgets('App launches and shows BankDom title', (tester) async {
    // Use an in-memory SQLite database so tests don't touch disk.
    final db = AppDatabase(NativeDatabase.memory());
    final repo = TransactionRepository(db);

    await tester.pumpWidget(MyApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('BankDom'), findsOneWidget);

    await db.close();
  });
}
