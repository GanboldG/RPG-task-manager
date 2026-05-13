import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/theme_notifier.dart';
import 'package:rpg_task_manager/services/audio_service.dart';
import 'package:rpg_task_manager/services/item_service.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'dart:io';

// ─── Settings Screen ──────────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  // theme selected in initState
  double _volume = 0.5;
  bool _musicOn = true;
  bool _exporting = false;

  void _toggleMusic(bool val) {
    setState(() => _musicOn = val);
    if (!val) AudioService.instance.stopBackgroundMusic();
  }

  void _setVolume(double v) {
    setState(() => _volume = v);
    AudioService.instance.setVolume(v);
  }

  void _confirmLogout() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Локал өгөгдөл устгагдана.\nFirebase sync хийсэн эсэхийгээ шалгаарай.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _resetAllData();
              appState.setLoggedOut();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    setState(() => _isLoading = true);
    try {
      await Hive.close();
      for (final name in [
        'active_tasks',
        'archived_tasks',
        'user',
        'shop_items',
        'custom_shop_items',
        'task_snapshots',
      ]) {
        try {
          await Hive.deleteBoxFromDisk(name);
        } catch (_) {}
      }
    } finally {
      setState(() => _isLoading = false);
      if (Platform.isAndroid || Platform.isIOS)
        SystemNavigator.pop();
      else
        exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUser = !UserService().currentUserisNull();
    final user = hasUser ? UserService().currentUser : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FA),
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.grey,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // ── Theme ───────────────────────────────────────────────
                _label('THEME'),
                Consumer<ThemeNotifier>(
                  builder: (context, themeNotifier, _) {
                    return _card(
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: themeNotifier.themes.map((t) {
                            final sel = themeNotifier.current.id == t.id;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  themeNotifier.setTheme(t);
                                  setState(() {});
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: sel
                                          ? t.accent
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                    boxShadow: sel
                                        ? [
                                            BoxShadow(
                                              color: t.primary.withOpacity(
                                                0.45,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: t.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        t.label,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (sel)
                                        Icon(
                                          Icons.check,
                                          size: 13,
                                          color: t.accent,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── Audio ───────────────────────────────────────────────
                _label('AUDIO'),
                _card(
                  Column(
                    children: [
                      _row(
                        icon: Icons.music_note,
                        label: 'Music',
                        trailing: Switch(
                          value: _musicOn,
                          activeColor: Theme.of(context).colorScheme.secondary,
                          onChanged: _toggleMusic,
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 52,
                        color: Colors.grey.shade200,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_up,
                              size: 20,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Slider(
                                value: _volume,
                                min: 0,
                                max: 1,
                                divisions: 10,
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                onChanged: _musicOn ? _setVolume : null,
                              ),
                            ),
                            Text(
                              '${(_volume * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Sync Data to Firebase ──────────────────────────────────────────────
                _label('SYNC DATA'),
                _card(
                  _row(
                    icon: Icons.cloud,
                    label: 'Sync Data to cloud',
                    iconColor: const Color.fromARGB(255, 6, 168, 255),
                    labelColor: const Color.fromARGB(255, 6, 168, 255),
                    onTap: syncDataToFirebase,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Download tasks as json ──────────────────────────────────────────────
                _label('EXPORT TASKS'),
                _card(
                  _row(
                    icon: Icons.share,
                    label: 'Export Task History as json',
                    iconColor: const Color.fromARGB(255, 3, 137, 72),
                    labelColor: const Color.fromARGB(255, 3, 137, 72),
                    onTap: _exportTaskHistoryAsJson,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Danger ──────────────────────────────────────────────
                _label('DANGER ZONE'),
                _card(
                  _row(
                    icon: Icons.logout,
                    label: 'Log Out',
                    iconColor: Colors.red,
                    labelColor: Colors.red,
                    onTap: _confirmLogout,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.65),
      ),
    ),
  );

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _row({
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? labelColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey.shade400,
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Future<void> syncDataToFirebase() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await UserService().uploadToFirestore(UserService().currentUser);
      await ItemService().uploadCustomItemsToFirestore();
      await TaskService().uploadActiveTasksToFirestore();
      await TaskService().uploadArchivedTasksToFirestore();
      await TaskService().uploadTaskSnapshotsToFirestore();

      if (mounted) {
        Navigator.pop(context); // close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Everything uploaded to Firestore'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
          ),
        );
      }
    }
  }

  Future<void> _exportTaskHistoryAsJson() async {
    setState(() => _exporting = true);
    late String path;

    try {
      path = await TaskService().exportTasksToFile();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exported to $path")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Export failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _exporting = false);
    }
  }
}
