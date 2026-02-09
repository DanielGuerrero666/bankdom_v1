// Step 5b: Updated Category domain model.
//
// Added `id` (nullable — null before the DB assigns one).
// `totalAmount` and `percentage` remain computed in-memory by the
// presentation layer after loading data from the repository.

import 'package:flutter/material.dart';

import 'transaction.dart';

class Category {
  final int? id;
  final String name;
  final IconData icon;
  final TransactionType type;
  double totalAmount;
  double percentage;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.totalAmount = 0.0,
    this.percentage = 0.0,
  });
}
