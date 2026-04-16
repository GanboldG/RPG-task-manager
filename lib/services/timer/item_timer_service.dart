import 'dart:async';
import 'package:flutter/material.dart';

class ItemTimerService extends ChangeNotifier {
  Timer? _globalTimer;
  bool _isRunning = false;
  
  // Callback to update items
  Function()? onTick;
  
  bool get isRunning => _isRunning;
  
  void startGlobalTimer() {
    if (_globalTimer != null) return;
    
    _isRunning = true;
    _globalTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // On each tick, decrement all active items
      if (onTick != null) {
        onTick!();
      }
      debugPrint("Tick tock from time service!!!!!!!");

      notifyListeners();
    });
    
    notifyListeners();
  }
  
  void stopGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = null;
    _isRunning = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopGlobalTimer();
    super.dispose();
  }
}