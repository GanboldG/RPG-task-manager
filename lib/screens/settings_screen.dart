import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/theme_notifier.dart';
import 'package:rpg_task_manager/services/audio_service.dart';
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

  String _rankTitle(int level) {
    if (level < 5) return 'Novice';
    if (level < 10) return 'Apprentice';
    if (level < 20) return 'Task Hunter';
    if (level < 35) return 'Veteran';
    if (level < 50) return 'Champion';
    return 'Legend';
  }

  String _formatJoined(DateTime dt) =>
      'Joined ${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  Future<void> _launch(String url) async {
    try {
      final uri = Uri.parse(url);
      if (url.startsWith('tel:') || url.startsWith('mailto:')) {
        await SystemChannels.platform.invokeMethod(
          'SystemNavigator.routeUpdated',
          url,
        );
      }
    } catch (_) {}
  }

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

  void _showEditNameDialog() {
    if (UserService().currentUserisNull()) return;
    final user = UserService().currentUser;
    final ctrl = TextEditingController(text: user.fullName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Name'),
        content: TextField(
          controller: ctrl,
          maxLength: 30,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
          ],
          decoration: InputDecoration(
            hintText: 'New name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.length < 3) return;
              final updated = user.copyWith(fullName: newName);
              UserService().setCurrentUser(updated);
              await UserService().saveCurrentUserData();
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
                // ── Profile ─────────────────────────────────────────────
                if (user != null) ...[
                  _label('PROFILE'),
                  _card(
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE8E0F5),
                              border: Border.all(
                                color: const Color(0xFFB39DDB),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: user.avatarPath == null
                                  ? Image.asset(
                                      'assets/images/profile.png',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(user.avatarPath!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _rankTitle(user.level),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatJoined(user.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            tooltip: 'Change Name',
                            onPressed: _showEditNameDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

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

                // ── Contact ─────────────────────────────────────────────
                _label('CONTACT'),
                _card(
                  Column(
                    children: [
                      _row(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        iconColor: const Color(0xFF1877F2),
                        onTap: () {},
                      ),
                      Divider(
                        height: 1,
                        indent: 52,
                        color: Colors.grey.shade200,
                      ),
                      _row(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        iconColor: const Color(0xFFEA4335),
                        onTap: () {},
                      ),
                      Divider(
                        height: 1,
                        indent: 52,
                        color: Colors.grey.shade200,
                      ),
                      _row(
                        icon: Icons.phone_outlined,
                        label: '+976 9999 9999',
                        iconColor: const Color(0xFF34A853),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── About ───────────────────────────────────────────────
                _label('ABOUT'),
                _card(
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RPG Task Manager',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Version 0.0.1',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Turn your daily tasks into quests. Earn XP and gold, level up, and live life like an RPG.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '© 2026 RPG Task Manager',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              'v0.0.1',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
}
