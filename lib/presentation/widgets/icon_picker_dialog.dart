import 'package:flutter/material.dart';

const List<IconData> availableIcons = [
  Icons.restaurant,
  Icons.shopping_cart,
  Icons.directions_car,
  Icons.home,
  Icons.local_hospital,
  Icons.school,
  Icons.flight,
  Icons.movie,
  Icons.fitness_center,
  Icons.pets,
  Icons.coffee,
  Icons.phone_android,
  Icons.wifi,
  Icons.electric_bolt,
  Icons.water_drop,
  Icons.checkroom,
  Icons.savings,
  Icons.work,
  Icons.card_giftcard,
  Icons.attach_money,
  Icons.trending_up,
  Icons.account_balance,
  Icons.store,
  Icons.music_note,
  Icons.sports_esports,
  Icons.local_grocery_store,
  Icons.local_gas_station,
  Icons.build,
  Icons.brush,
  Icons.book,
];

Future<IconData?> showIconPicker(BuildContext context) {
  return showDialog<IconData>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Pick an Icon'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final icon = availableIcons[index];
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.pop(context, icon),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 28),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
