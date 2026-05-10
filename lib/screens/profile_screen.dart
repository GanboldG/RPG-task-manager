import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/screens/Statistics/Detailed_Statistics.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final taskController = context.watch<TaskController>();

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
              _MiniWeekChart(),
              const SizedBox(height: 20),
              _ViewStatsButton(),
              const SizedBox(height: 30),
              _TaskHistorySection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniWeekChart extends StatelessWidget {
  static DateTime _mondayOf(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  static String _hiveKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static double _minutesForDay(DateTime day) {
    final snapshot = TaskService().taskSnapshotBox.get(_hiveKey(day));
    if (snapshot == null) return 0;
    return snapshot.taskMinutes.values.fold(0, (sum, v) => sum + v);
  }

  static String _formatHM(double minutes) {
    final h = minutes ~/ 60;
    final m = (minutes % 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final monday = _mondayOf(DateTime.now());
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final data = List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return (day: day, minutes: _minutesForDay(day), label: labels[i]);
    });

    final maxVal = data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxVal == 0 ? 1.0 : maxVal;
    final today = DateTime.now();
    final total = data.fold(0.0, (sum, d) => sum + d.minutes);
    final avg = total / 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This week',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Avg ${_formatHM(avg)}/day',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7E57C2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((d) {
                final isToday = d.day.day == today.day &&
                    d.day.month == today.month &&
                    d.day.year == today.year;
                final heightFraction = d.minutes / effectiveMax;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (d.minutes > 0)
                          Text(
                            _formatHM(d.minutes),
                            style: TextStyle(
                              fontSize: 8,
                              color: isToday
                                  ? const Color(0xFF7E57C2)
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: heightFraction * 48,
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFF7E57C2)
                                : const Color(0xFFB39DDB),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isToday
                                ? const Color(0xFF7E57C2)
                                : Colors.grey,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final user = userController.user;
    print("Building profile screen");
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
                  child: userController.user.avatarPath == null
                    ? Image.asset(
                        "assets/images/profile.png",
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(userController.user.avatarPath!),
                        key: ValueKey(user.avatarPath! + DateTime.now().toString()),
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
                    print("Chosen image path: ${file.path}");
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
            value: "${HelperFunctions.secToHoursDecimal(UserService().currentUser.secondsSpentOnTasks)}h",
            label: 'Total time',
            color: const Color(0xFF26C6DA),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            value: UserService().currentUser.completedTaskAmount.toString(),
            label: 'Done Tasks',
            color: const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            value: UserService().currentUser.taskCompletionStreak.toString(),
            label: 'Task Streak',
            color: const Color(0xFFFFA726),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            value: '? days',
            label: 'Login Streak',
            color: const Color.fromARGB(255, 255, 92, 11),
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

class _TaskHistorySection extends StatelessWidget {
  const _TaskHistorySection();

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final recentTasks = taskController.getLastNArchivedTasks(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Tasks History",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ...recentTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TaskHistoryTile(
                    title: task.name,
                    time: "${HelperFunctions.formatDuration(task.getSecondsSinceCompletion() ?? 0).toString()} ago",
                    xp: task.reward.xp.toString(),
                    gold: task.reward.gold.toString()
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullTaskHistoryScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F0FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "View Full History",
                      style: TextStyle(
                        color: Color(0xFF7E57C2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskHistoryTile extends StatelessWidget {
  final String title;
  final String time;
  final String xp;
  final String gold;

  const _TaskHistoryTile({
    required this.title,
    required this.time,
    required this.xp,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
      return Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF7E57C2),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children:[
              Text(
                "$xp XP",
                style: const TextStyle(
                  color: const Color(0xFF26C6DA),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$gold GOLD",
                style: const TextStyle(
                  color: const Color(0xFFFFA726),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          )
        ],
      );
  }}

class FullTaskHistoryScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final tasksData = taskController.archivedTasks;

    final tasks = List.generate(
      tasksData.length,
      (index) => {
        "title": "#${index + 1}: ${tasksData[index].name}",
        "time": "${HelperFunctions.formatDuration(tasksData[index].getSecondsSinceCompletion() ?? 0)} ago",
        "xp": "${tasksData[index].reward.xp}",
        "gold": "${tasksData[index].reward.gold}",
      },
    );
    

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Task History"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final task = tasks[index];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _TaskHistoryTile(
              title: task["title"]!,
              time: task["time"]!,
              xp: task["xp"]!,
              gold: task["gold"]!
            ),
          );
        },
      ),
    );
  }
}