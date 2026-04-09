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


  // Removes seconds / milleseconds from DateTime
  // static DateTime? normalizeToMinute(DateTime? dateTime) {
  //   if (dateTime != null){
  //     return DateTime(
  //       dateTime.year,
  //       dateTime.month,
  //       dateTime.day,
  //       dateTime.hour,
  //       dateTime.minute,
  //     );
  //   }

  //   else{
  //     return null;
  //   }
  // }
  static String formatDateTimeToString(DateTime? dateTime) {
    if (dateTime == null) return '';
    return 'Deadline: ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}