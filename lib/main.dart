import 'package:flutter/material.dart';

import 'data/database/app_database.dart';
import 'data/repositories/transaction_repository.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final repository = TransactionRepository(database);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final TransactionRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BankDom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 65, 170, 27),
        ),
      ),
      home: HomeScreen(title: 'BankDom', repository: repository),
    );
  }
}
