import 'package:flutter/material.dart';

class HelperFunctions{
  static void showMessage(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
                     style: TextStyle(
                      color: Colors.white,
                     )),
        duration: Duration(seconds: 1),
      ),
    );
  }


  static String formatDateTimeToString(DateTime? dateTime) {
    if (dateTime == null) return '';
    return 'Deadline: ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }


  static int minToSec(double minutes){
    return (minutes * 60).round();
  }


  // Builds custom icons with neon effect
  static Widget buildNeonIcon(IconData icon, Color color, double size) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }


  // Builds outlined icon
  static Widget buildOutlinedIcon({
    required IconData icon,
    required Color color,
    required Color outlineColor,
    double size = 24,
    double outlineWidth = 2,
    }) {
    return Stack(
      children: [
        // Outline (background icon)
        Icon(
          icon,
          size: size + outlineWidth,
          color: outlineColor,
        ),
        // Main icon
        Icon(
          icon,
          size: size,
          color: color,
        ),
      ],
    );
  }
}