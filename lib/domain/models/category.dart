import 'package:flutter/material.dart';

import 'transaction.dart';

class Category {
  final String name;
  final IconData icon;
  final TransactionType type;
  double totalAmount;
  double percentage;

  Category({
    required this.name,
    required this.icon,
    required this.type,
    this.totalAmount = 0.0,
    this.percentage = 0.0,
  });
}
