import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showroom_manager/config/config.dart';

class Statistics extends StatelessWidget {
  final double balance;
  final Color color;
  final IconData statsIcon;
  final String cardName;
  final bool isLoading;

  const Statistics({super.key, required this.balance, required this.cardName, required this.color, required this.statsIcon, required this.isLoading} );

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
              Text(cardName,style: const TextStyle(color: Colors.white,fontSize: 15),),
              const SizedBox(height: 5,),
              isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white,),) :
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(balance), style: const TextStyle(color: Colors.white, fontSize: 15 ),),
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
              )
            ],
          ),
        ),
    );
  }
}
