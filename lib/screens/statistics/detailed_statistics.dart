import 'package:flutter/material.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/widgets/resource_bar.dart';

class DetailedStatisticsScreen extends StatefulWidget {
  const DetailedStatisticsScreen({super.key});

  @override
  State<DetailedStatisticsScreen> createState() =>
      _DetailedStatisticsScreenState();
}

class _DetailedStatisticsScreenState extends State<DetailedStatisticsScreen> {
  int _selectedFilter = 0; // 0 = 7 days, 1 = Month, 2 = Lived

  final List<String> _filters = ['7 days', 'Month', 'Lived'];
  final List<double> _dailyData = [1.0, 2.5, 1.5, 3.0, 2.0, 1.0, 4.5];
  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // ─── Bottom nav icon helper (same style as main.dart) ────────────────────
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      // ── Top: ResourceBar + back ─────────────────────────────────────────
      body: Column(
        children: [
          // ResourceBar — main.dart-тай ижил хэвээр
          ResourceBar(),

          // Back button мөр
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // ──────────────────────────────────────────────────────────
                // ICON: assets/icons/arrow_back.png
                // Зүүн тийш харсан буцах сум
                // ──────────────────────────────────────────────────────────
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
                  'Detailed Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards 2×2
                  _SummaryGrid(),
                  const SizedBox(height: 16),

                  // Filter Tabs
                  _FilterTabs(
                    filters: _filters,
                    selected: _selectedFilter,
                    onTap: (i) => setState(() => _selectedFilter = i),
                  ),
                  const SizedBox(height: 16),

                  // Bar Chart
                  _BarChartCard(dailyData: _dailyData, dayLabels: _dayLabels),
                  const SizedBox(height: 16),

                  // By Task Type
                  _TaskTypeSection(),
                  const SizedBox(height: 16),

                  // Average
                  _AverageSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom nav — Profile tab highlighted ───────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Profile tab
        onTap: (i) {
          if (i == 2) return; // Already on Profile stack
          // Буцаж HomePage руу очиж тухайн tab-г нээнэ
          Navigator.popUntil(context, (route) => route.isFirst);
          // HomePage-н index-г сольж чадахгүй тул pop хийгээд дуусна
          // Хэрэв бүрэн tab switch хэрэгтэй бол HomePage-д callback дамжуулна
        },
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/nav_tasks.png', false),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/nav_shop.png', false),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/nav_profile.png', true),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/nav_settings.png', false),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─── Summary Grid ─────────────────────────────────────────────────────────────
class _SummaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total time',
                value: '127.4h',
                subtitle: 'Total active',
                valueColor: const Color(0xFF26C6DA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'Today',
                value: '3.2h',
                subtitle: 'Average daily 4.1h',
                valueColor: const Color(0xFFAB47BC),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Accomplished',
                value: '284',
                subtitle: 'Total Challenge',
                valueColor: const Color(0xFF66BB6A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'Success %',
                value: '91%',
                subtitle: 'Deadline',
                valueColor: const Color(0xFFFFA726),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

// ─── Bar Chart Card ───────────────────────────────────────────────────────────
class _BarChartCard extends StatelessWidget {
  final List<double> dailyData;
  final List<String> dayLabels;

  const _BarChartCard({required this.dailyData, required this.dayLabels});

  @override
  Widget build(BuildContext context) {
    final double maxVal = dailyData.reduce((a, b) => a > b ? a : b);

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
            children: const [
              Text(
                'Daily Clock',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Average 4.1h',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7E57C2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(dailyData.length, (i) {
                final double barHeight = (dailyData[i] / maxVal) * 100;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9575CD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dayLabels[i],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Task Type Section ────────────────────────────────────────────────────────
class _TaskTypeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const int total = 142 + 89 + 41 + 12;

    final List<Map<String, dynamic>> types = [
      {'label': 'Small', 'count': 142, 'color': const Color(0xFF26C6DA)},
      {'label': 'Medium', 'count': 89, 'color': const Color(0xFF66BB6A)},
      {'label': 'Big', 'count': 41, 'color': const Color(0xFFFFA726)},
      {'label': 'Mythic', 'count': 12, 'color': const Color(0xFFEF5350)},
    ];

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
          const Text(
            'By Task Type:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...types.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskTypeRow(
                label: t['label'],
                count: t['count'],
                color: t['color'],
                progress: t['count'] / total,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTypeRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final double progress;

  const _TaskTypeRow({
    required this.label,
    required this.count,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ─── Average Section ──────────────────────────────────────────────────────────
class _AverageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Average',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AverageCard(
                period: '7 days',
                value: '28.7h',
                color: const Color(0xFF7E57C2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AverageCard(
                period: 'of the month',
                value: '123.4h',
                color: const Color(0xFF7E57C2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AverageCard extends StatelessWidget {
  final String period;
  final String value;
  final Color color;

  const _AverageCard({
    required this.period,
    required this.value,
    required this.color,
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
            period,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
