import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/screens/Statistics/Detailed_Statistics.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(),
              const SizedBox(height: 16),
              _XPProgressBar(),
              const SizedBox(height: 16),
              _StatsRow(),
              const SizedBox(height: 12),
              _ViewStatsButton(),
              const SizedBox(height: 20),
              // _AchievementSection(),
              // const SizedBox(height: 16),
              // _StreakCard(),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final userController = context.read<UserController>();
    final user = userController.user;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8E0F5),
                  border: Border.all(color: const Color(0xFFB39DDB), width: 2),
                ),
                child: ClipOval(
                  child: userController.user.avatarUrl == null
                    ? Image.asset(
                        "assets/profile.png",
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(userController.user.avatarUrl!),
                        fit: BoxFit.cover,
                      ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    final file = await pickImage();
                    if (file == null) return;
                    await userController.updateUserImage(File(file.path));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.camera_alt, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.fullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Joined ${DateFormat('yyyy-MM-dd').format(user.createdAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.email}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return null;
    return File(file.path);
  }
}

class _XPProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = context.read<UserController>();
    final user = userController.user;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("LVL${user.level}", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              '${user.experiencePoints}/${user.experienceThreshold}XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text("LVL${user.level+1}", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: user.experiencePoints / user.experienceThreshold,
            minHeight: 10,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7E57C2)),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            value: '127h',
            label: 'Total time',
            color: const Color(0xFF26C6DA),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            value: '284',
            label: 'Task',
            color: const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            value: '42',
            label: 'Streak',
            color: const Color(0xFFFFA726),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ViewStatsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DetailedStatisticsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/chart.png',
              width: 20,
              height: 20,
              color: const Color(0xFF7E57C2),
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 20,
                height: 20,
                child: Placeholder(color: Color(0xFF7E57C2)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'View detailed statistics',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(221, 159, 91, 242),
              ),
            ),
            const Spacer(),

            Image.asset(
              'assets/icons/chevron_right.png',
              width: 18,
              height: 18,
              color: Colors.grey,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(width: 18, height: 18, child: Placeholder()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> achievements = [
      {
        'label': 'Lv1',

        'iconPath': 'assets/icons/lv1.png',
        'bgColor': const Color(0xFFFFF9C4),
        'borderColor': const Color(0xFFF9A825),
      },
      {
        'label': 'Lv2',

        'iconPath': 'assets/icons/lv2.png',
        'bgColor': const Color(0xFFEDE7F6),
        'borderColor': const Color(0xFF7E57C2),
      },
      {
        'label': 'Lv3',

        'iconPath': 'assets/icons/lv3.png',
        'bgColor': const Color(0xFFEDE7F6),
        'borderColor': const Color(0xFF9C27B0),
      },
      {
        'label': 'Lv4',

        'iconPath': 'assets/icons/lv4.png',
        'bgColor': const Color(0xFFE8F5E9),
        'borderColor': const Color(0xFF43A047),
      },
      {
        'label': 'Lv5',

        'iconPath': 'assets/icons/lv5.png',
        'bgColor': const Color(0xFFFFF9C4),
        'borderColor': const Color(0xFFFB8C00),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Outstanding Achievement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7E57C2),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: achievements
              .map(
                (a) => _AchievementBox(
                  label: a['label'],
                  iconPath: a['iconPath'],
                  bgColor: a['bgColor'],
                  borderColor: a['borderColor'],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AchievementBox extends StatelessWidget {
  final String label;
  final String iconPath;
  final Color bgColor;
  final Color borderColor;

  const _AchievementBox({
    required this.label,
    required this.iconPath,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) => SizedBox(
              width: 28,
              height: 28,
              child: Placeholder(color: borderColor),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/fire.png',
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 36,
              height: 36,
              child: Placeholder(color: Color(0xFFFF7043)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '42 Day',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(205, 127, 50, 1),
                ),
              ),
              Text(
                'Daily login streak',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 2),
              const Text(
                'Bronze',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(205, 127, 50, 1),
                ),
              ),
              const Text(
                '58 day silver',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
