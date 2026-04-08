import 'package:flutter/material.dart';

class HelperFunctions{
  static void showMessage(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
                     style: TextStyle(
                      color: Colors.white,
                     )),
        duration: Duration(seconds: 2),
      ),
    );
  }
}