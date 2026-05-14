class NotificationSettings {
  final bool enableSound;
  final bool enableVibration;
  final bool allowPause;
  final bool allowDone;
  final bool showRemainingTime;
  final bool enableFocusMode;

  const NotificationSettings({
    required this.enableSound,
    required this.enableVibration,
    required this.allowPause,
    required this.allowDone,
    required this.showRemainingTime,
    required this.enableFocusMode,
  });

  factory NotificationSettings.defaults() {
    return const NotificationSettings(
      enableSound: true,
      enableVibration: true,
      allowPause: true,
      allowDone: true,
      showRemainingTime: true,
      enableFocusMode: false,
    );
  }
}
