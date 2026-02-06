import 'package:flutter/material.dart';

class BalanceCircle extends StatelessWidget {
  final double balance;

  const BalanceCircle({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: balance >= 0
            ? const Color.fromARGB(255, 69, 192, 73)
            : Colors.red,
      ),
      alignment: Alignment.center,
      child: Text(
        '\$${balance.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
