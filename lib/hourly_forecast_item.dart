import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData icon;

  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.temperature,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return 
    Card(
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

            ),
            SizedBox(height: 8,),
            Icon(icon,size: 40,),
            SizedBox(height: 8,),
            Text(temperature,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
          ],
        ),
      ),
    );
  }
}
