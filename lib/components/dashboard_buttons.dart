import 'package:flutter/material.dart';

class DashboardBtns extends StatelessWidget {
  final String iconImagePath;
  final String buttonText;
  final String pageRoute;
  const DashboardBtns(
      {
        Key? key,
        required this.iconImagePath,
        required this.buttonText, required this.pageRoute
      }
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, pageRoute);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5),
        child: Column(

          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 20,
                        spreadRadius: 2
                    )
                  ]
              ),
              child: Center(
                child: Image.asset(iconImagePath),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              buttonText,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700]
              ),
            )
          ],
        ),
      ),
    );
  }
}
