import 'package:flutter/material.dart';

class hourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const hourlyForecastItem({super.key, required this.icon, required this.time, required this.temp});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 130,
      width: 110,
      child: Card(
        elevation: 7,
        child: Column(
          children: [
            SizedBox(height: 9),
             Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 10),
            Icon(icon , size: 40),
            SizedBox(height: 10),
            Text(temp),

          ],
        ),
      ),
    );
  }}