import 'package:flutter/material.dart';

class TierCard extends StatelessWidget {
  final String title;
  final String maxPoints;
  final String discount;
  final String minPoints;
  final Color bgColor;

  const TierCard({
    Key? key,
    required this.title,
    required this.maxPoints,
    required this.discount,
    required this.minPoints,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height * 0.27,
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'max points: $maxPoints',
            style: TextStyle(
              fontSize: size.width * 0.03,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'Benefits',
            style: TextStyle(
              fontSize: size.width * 0.03,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$discount discount on all products',
            style: TextStyle(
              fontSize: size.width * 0.02,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'min points: $minPoints',
            style: TextStyle(
              fontSize: size.width * 0.02,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'max points: $maxPoints',
            style: TextStyle(
              fontSize: size.width * 0.02,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '1 point per shs 1 spent',
            style: TextStyle(
              fontSize: size.width * 0.02,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          const Divider(
            height: 10,
            thickness: 1,
            color: Colors.black, // Use your custom color constant if applicable
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learn more about this tier',
                style: TextStyle(
                  fontSize: size.width * 0.02,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: size.width * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
