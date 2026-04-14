import 'package:shared_preferences/shared_preferences.dart';

class UserIdCounter {
  static const String _key = 'user_next_id';
  
  static Future<int> getNextId() async {
    final prefs = await SharedPreferences.getInstance();
    int currentId = prefs.getInt(_key) ?? 0;
    await prefs.setInt(_key, currentId + 1);
    return currentId;
  }
  
  // Optional: reset for testing
  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, 0);
  }
}

// Usage when creating a task:
// final int newId = await TaskIdCounter.getNextId();