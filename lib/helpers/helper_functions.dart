import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  

  // Helper method to format duration
  static String formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0s';
    
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    final List<String> parts = [];
    
    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0) {
      parts.add('${minutes}m');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('${seconds}s');
    }
    
    return parts.join(' ');
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

  // Formats int into 1.2k , 13M etc
  static String formatNumberSuffix(int number) {
    if (number < 1000) return number.toString();
    
    const suffixes = ['', 'K', 'M', 'B', 'T'];
    int suffixIndex = 0;
    double num = number.toDouble();
    
    while (num >= 1000 && suffixIndex < suffixes.length - 1) {
      num /= 1000;
      suffixIndex++;
    }
    
    return '${num.toStringAsFixed(1)}${suffixes[suffixIndex]}';
  }


  static int randomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }


  static double randomDouble(double min, double max) {
    final random = Random();
    return min + random.nextDouble() * (max - min);
  }


  static Future<void> deleteImage(String path) async {
    if (path.isNotEmpty) {
      final imageFile = File(path);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }
  } 

  static Future<bool> hasInternet() async {
    var result = await Connectivity().checkConnectivity();

    return result != ConnectivityResult.none;
  }
}