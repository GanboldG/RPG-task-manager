import 'package:flutter/material.dart';
import 'package:rpg_task_manager/models/task/task_type.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';

class DetailedStatisticsScreen extends StatefulWidget {
  const DetailedStatisticsScreen({super.key});

  @override
  State<DetailedStatisticsScreen> createState() =>
      _DetailedStatisticsScreenState();
}

class _DetailedStatisticsScreenState extends State<DetailedStatisticsScreen> {
  int _selectedFilter = 0; // 0 = Week, 1 = Month

  // Week mode: anchor = the Monday of the displayed week
  DateTime _weekAnchor = _mondayOf(DateTime.now());

  // Month mode: anchor = first day of the displayed month
  DateTime _monthAnchor = DateTime(DateTime.now().year, DateTime.now().month, 1);

  // Loaded bar data: list of (label, minutes)
  List<_BarData> _bars = [];
  bool _loading = false;

  final List<String> _filters = ['Week', 'Month'];

  List<_PieData> _pieData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Date helpers ──────────────────────────────────────────────────────────

  static DateTime _mondayOf(DateTime d) {
    // weekday: 1=Mon, 7=Sun
    return DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: d.weekday - 1));
  }

  static String _hiveKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static double _snapshotMinutes(DateTime day) {
    final box = TaskService().taskSnapshotBox;
    final snapshot = box.get(_hiveKey(day));
    if (snapshot == null) return 0;
    double total = 0;
    for (final v in snapshot.taskMinutes.values) {
      total += v;
    }
    return total;
  }

  // ── Load data based on current filter & anchor ───────────────────────────

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final bars = _selectedFilter == 0
        ? _buildWeekBars()
        : _buildMonthBars();

    final pie = _selectedFilter == 0
        ? _buildWeekPieData()
        : _buildMonthPieData();

    setState(() {
      _bars = bars;
      _pieData = pie;
      _loading = false;
    });
  }

  List<_PieData> _buildWeekPieData() {
    final taskController = context.read<TaskController>();
    final Map<TaskType, double> typeMinutes = {};

    for (int i = 0; i < 7; i++) {
      final day = _weekAnchor.add(Duration(days: i));
      final snapshot = TaskService().taskSnapshotBox.get(_hiveKey(day));

      if (snapshot == null) continue;

      for (final entry in snapshot.taskMinutes.entries) {
        final taskId = entry.key;
        final minutes = entry.value;
        final task = taskController.taskMap[taskId];
        if (task == null) continue;
        final type = task.type;

        if (type != null){
          typeMinutes[type] = (typeMinutes[type] ?? 0) + minutes;
        }
      }
    }

    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
    ];

    int index = 0;

    return typeMinutes.entries.map((e) {

      final data = _PieData(
        label: e.key.name,
        minutes: e.value,
        color: colors[index % colors.length],
      );

      index++;
      return data;
    }).toList();
  }

  List<_PieData> _buildMonthPieData() {
    final taskController = context.read<TaskController>();
    final Map<TaskType, double> typeMinutes = {};
    final year = _monthAnchor.year;
    final month = _monthAnchor.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    DateTime current = firstDay;

    while (!current.isAfter(lastDay)) {

      final snapshot =
          TaskService().taskSnapshotBox.get(_hiveKey(current));

      if (snapshot != null) {

        for (final entry in snapshot.taskMinutes.entries) {

          final taskId = entry.key;
          final minutes = entry.value;

          final task =
              taskController.taskMap[taskId];

          if (task == null) continue;

          final type = task.type;

          if (type != null) {

            typeMinutes[type] =
                (typeMinutes[type] ?? 0) + minutes;
          }
        }
      }

      current = current.add(const Duration(days: 1));
    }

    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
    ];

    int index = 0;

    return typeMinutes.entries.map((e) {

      final data = _PieData(
        label: e.key.name,
        minutes: e.value,
        color: colors[index % colors.length],
      );

      index++;

      return data;

    }).toList();
  }

  /// 7 bars: Mon–Sun of the anchored week
  List<_BarData> _buildWeekBars() {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (i) {
      final day = _weekAnchor.add(Duration(days: i));
      final minutes = _snapshotMinutes(day);
      return _BarData(label: dayLabels[i], minutes: minutes, date: day);
    });
  }

  /// Bars per calendar-week that overlaps the anchored month.
  /// Each bar = one week chunk; label = "W1", "W2", etc.
  List<_BarData> _buildMonthBars() {
    final year = _monthAnchor.year;
    final month = _monthAnchor.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0); // last day of month

    // Walk day by day, group into week buckets (Mon–Sun)
    final Map<DateTime, double> weekMinutes = {};

    DateTime current = firstDay;

    while (!current.isAfter(lastDay)) {
      final monday = _mondayOf(current);
      weekMinutes[monday] = (weekMinutes[monday] ?? 0) + _snapshotMinutes(current);
      current = current.add(const Duration(days: 1));
    }

    // Sort by monday date, then build labels with actual day ranges clamped to the month
    final sorted = weekMinutes.keys.toList()..sort();
    return sorted.map((monday) {
      final sunday = monday.add(const Duration(days: 6));
      // Clamp to month boundaries
      final rangeStart = monday.isBefore(firstDay) ? firstDay : monday;
      final rangeEnd = sunday.isAfter(lastDay) ? lastDay : sunday;
      final label = '${rangeStart.day}–${rangeEnd.day}';
      return _BarData(
        label: label,
        minutes: weekMinutes[monday]!,
        date: monday,
      );
    }).toList();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _navigatePrev() {
    setState(() {
      if (_selectedFilter == 0) {
        _weekAnchor = _weekAnchor.subtract(const Duration(days: 7));
      } else {
        _monthAnchor = DateTime(
          _monthAnchor.month == 1 ? _monthAnchor.year - 1 : _monthAnchor.year,
          _monthAnchor.month == 1 ? 12 : _monthAnchor.month - 1,
          1,
        );
      }
    });
    _loadData();
  }

  void _navigateNext() {
    final now = DateTime.now();
    if (_selectedFilter == 0) {
      final nextMonday = _weekAnchor.add(const Duration(days: 7));
      if (nextMonday.isAfter(now)) return; // don't go to future
      setState(() => _weekAnchor = nextMonday);
    } else {
      final nextMonth = DateTime(
        _monthAnchor.month == 12 ? _monthAnchor.year + 1 : _monthAnchor.year,
        _monthAnchor.month == 12 ? 1 : _monthAnchor.month + 1,
        1,
      );
      if (nextMonth.isAfter(now)) return;
      setState(() => _monthAnchor = nextMonth);
    }
    _loadData();
  }

  bool get _canGoNext {
    final now = DateTime.now();
    if (_selectedFilter == 0) {
      return _weekAnchor.add(const Duration(days: 7)).isBefore(now);
    } else {
      final nextMonth = DateTime(
        _monthAnchor.month == 12 ? _monthAnchor.year + 1 : _monthAnchor.year,
        _monthAnchor.month == 12 ? 1 : _monthAnchor.month + 1,
        1,
      );
      return nextMonth.isBefore(now);
    }
  }

  String get _periodLabel {
    if (_selectedFilter == 0) {
      final sunday = _weekAnchor.add(const Duration(days: 6));
      final sameMonth = _weekAnchor.month == sunday.month;
      if (sameMonth) {
        return '${_monthName(_weekAnchor.month)} ${_weekAnchor.day}–${sunday.day}';
      } else {
        return '${_weekAnchor.day} ${_monthName(_weekAnchor.month)} – ${sunday.day} ${_monthName(sunday.month)}';
      }
    } else {
      return '${_monthName(_monthAnchor.month)} ${_monthAnchor.year}';
    }
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[m];
  }

  // ── Summary helpers ───────────────────────────────────────────────────────

  double get _totalMinutes => _bars.fold(0, (sum, b) => sum + b.minutes);

  double get _averageMinutesPerDay {
    if (_bars.isEmpty) return 0;
    if (_selectedFilter == 0) {
      // 7 days in a week
      return _totalMinutes / 7;
    } else {
      // actual days in the month
      final daysInMonth = DateTime(
        _monthAnchor.year,
        _monthAnchor.month + 1,
        0,
      ).day;
      return _totalMinutes / daysInMonth;
    }
  }

  static String _formatHM(double minutes) {
    final h = minutes ~/ 60;
    final m = (minutes % 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  // ── Nav icon ──────────────────────────────────────────────────────────────

  Widget _navIcon(String path, bool isSelected) {
    return Image.asset(
      path,
      width: 24,
      height: 24,
      color: isSelected ? Colors.white : Colors.black,
      errorBuilder: (_, __, ___) => SizedBox(
        width: 24,
        height: 24,
        child: Placeholder(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // ResourceBar(),
          // Back bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/icons/arrow_back.png',
                      width: 22,
                      height: 22,
                      color: Colors.black87,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter tabs
                  _FilterTabs(
                    filters: _filters,
                    selected: _selectedFilter,
                    onTap: (i) {
                      setState(() => _selectedFilter = i);
                      _loadData();
                    },
                  ),
                  const SizedBox(height: 14),

                  // Period navigator
                  _PeriodNavigator(
                    label: _periodLabel,
                    onPrev: _navigatePrev,
                    onNext: _canGoNext ? _navigateNext : null,
                  ),
                  const SizedBox(height: 14),

                  // Summary cards
                  _SummaryRow(
                    totalMinutes: _totalMinutes,
                    avgMinutesPerDay: _averageMinutesPerDay,
                    formatHM: _formatHM,
                  ),
                  const SizedBox(height: 14),

                  // Bar chart
                  _loading
                      ? const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _BarChartCard(
                          bars: _bars,
                          totalMinutes: _totalMinutes,
                          periodLabel: _periodLabel,
                          formatHM: _formatHM,
                        ),
                  const SizedBox(height: 20),

                  _PieChartCard(data: _pieData),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   currentIndex: 2,
      //   onTap: (i) {
      //     if (i == 2) return;
      //     Navigator.popUntil(context, (route) => route.isFirst);
      //   },
      //   backgroundColor: AppColors.primary,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.black,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: _navIcon('assets/icons/nav_tasks.png', false),
      //       label: 'Tasks',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: _navIcon('assets/icons/nav_shop.png', false),
      //       label: 'Shop',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: _navIcon('assets/icons/nav_profile.png', true),
      //       label: 'Profile',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: _navIcon('assets/icons/nav_settings.png', false),
      //       label: 'Settings',
      //     ),
      //   ],
      // ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _BarData {
  final String label;
  final double minutes;
  final DateTime date;

  const _BarData({
    required this.label,
    required this.minutes,
    required this.date,
  });
}

// ─── Filter Tabs ──────────────────────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onTap;

  const _FilterTabs({
    required this.filters,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(filters.length, (i) {
        final bool isSelected = i == selected;
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7E57C2) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Text(
              filters[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Period Navigator ─────────────────────────────────────────────────────────

class _PeriodNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext; // null = disabled

  const _PeriodNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(icon: Icons.chevron_left, onTap: onPrev),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    );
  }
}

// ─── Summary Row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final double totalMinutes;
  final double avgMinutesPerDay;
  final String Function(double) formatHM;

  const _SummaryRow({
    required this.totalMinutes,
    required this.avgMinutesPerDay,
    required this.formatHM,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total time',
            value: formatHM(totalMinutes),
            valueColor: const Color(0xFF7E57C2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            title: 'Daily average',
            value: formatHM(avgMinutesPerDay),
            valueColor: const Color(0xFF26C6DA),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bar Chart Card ───────────────────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  final List<_BarData> bars;
  final double totalMinutes;
  final String periodLabel;
  final String Function(double) formatHM;

  const _BarChartCard({
    required this.bars,
    required this.totalMinutes,
    required this.periodLabel,
    required this.formatHM,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = bars.isEmpty
        ? 1
        : bars.map((b) => b.minutes).reduce((a, b) => a > b ? a : b);
    final double effectiveMax = maxVal == 0 ? 1 : maxVal;

    // Y-axis labels: 0, half, max — in hours
    final double topHours = effectiveMax / 60;
    final double midHours = topHours / 2;

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Time spent',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                totalMinutes == 0 ? 'No data' : formatHM(totalMinutes),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7E57C2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bars.isEmpty || totalMinutes == 0)
            const SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  'No time tracked in this period',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Y-axis labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _shortHours(topHours),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        _shortHours(midHours),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const Text(
                        '0',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  // Bars
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: bars.map((bar) {
                        final double heightFraction = bar.minutes / effectiveMax;
                        final bool isToday = _isToday(bar.date);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Value label on top of bar (only if > 0)
                                if (bar.minutes > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text(
                                      formatHM(bar.minutes),
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isToday
                                            ? const Color(0xFF7E57C2)
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                // Bar itself
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  height: heightFraction * 110,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? const Color(0xFF7E57C2)
                                        : const Color(0xFFB39DDB),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bar.label,
                                  style: TextStyle(
                                    fontSize: 11,
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
            ),
        ],
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  // "4.5h" or "30m" compact label for y-axis
  String _shortHours(double hours) {
    if (hours < 1) return '${(hours * 60).round()}m';
    return '${hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)}h';
  }
}

class _PieData {
  final String label;
  final double minutes;
  final Color color;

  const _PieData({
    required this.label,
    required this.minutes,
    required this.color,
  });
}

class _PieChartCard extends StatelessWidget {
  final List<_PieData> data;

  const _PieChartCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        data.fold<double>(0, (sum, e) => sum + e.minutes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Type Distribution',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 45,
                sections: data.map((e) {
                  final percent =
                      total == 0 ? 0 : (e.minutes / total) * 100;

                  return PieChartSectionData(
                    value: e.minutes,
                    title:
                        '${percent.toStringAsFixed(0)}%',
                    color: e.color,
                    radius: 65,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: e.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(e.label),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}