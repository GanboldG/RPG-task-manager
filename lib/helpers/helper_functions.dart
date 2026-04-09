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
}