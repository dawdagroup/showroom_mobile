import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Statistics extends StatelessWidget {
  final double balance;
  final color;
  final statsIcon;
  final String cardName;

  const Statistics(
      {
        Key? key,
        required this.balance,
        required this.cardName,
        this.color, this.statsIcon}
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration:  BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all( Radius.circular(16)
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cardName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(balance),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stats",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),

                  IconButton(
                    onPressed: () {

                    },
                    color: Colors.white,
                    icon: Icon(
                        statsIcon
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
    );
  }
}
