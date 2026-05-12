import "package:flutter/material.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";
import "package:rpg_task_manager/helpers/helper_functions.dart";
import "package:rpg_task_manager/models/task/task.dart";

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onRemoved;
  final VoidCallback onEdited;
  final VoidCallback onFinished;
  final int index;
  final VoidCallback onPlayPause;
  final bool isRunning;
  final bool isFirstTask;

  const TaskTile({
    super.key,
    required this.task,
    required this.index,
    required this.onRemoved,
    required this.onEdited,
    required this.onFinished,
    required this.onPlayPause,
    this.isRunning = false,
    required this.isFirstTask,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Soft pink background
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        // Difficulty color as border
        border: Border.all(color: _getDifficultyColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getDifficultyColor().withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay
          _buildPatternOverlay(),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildDragHandle(),
                const SizedBox(width: 8),
                _buildProgressSection(),
                const SizedBox(width: 12),
                Expanded(child: _buildTaskDetails()),
                _buildMenuButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BACKGROUND DESIGN ====================
  Widget _buildPatternOverlay() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: CustomPaint(painter: DotPatternPainter()),
      ),
    );
  }

  // ==================== DRAG HANDLE ====================
  Widget _buildDragHandle() {
    return ReorderableDragStartListener(
      index: widget.index,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Icon(
          Icons.drag_handle,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }

  // ==================== PROGRESS SECTION ====================
  Widget _buildProgressSection() {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressCircle(),
          const SizedBox(height: 8),
          _buildRemainingTime(),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: widget.task.progress,
            strokeWidth: 6,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "${(widget.task.progress * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingTime() {
    String timeLeft = widget.task.getRemainingTimeString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              timeLeft,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TASK DETAILS ====================
  Widget _buildTaskDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Name
        Text(
          widget.task.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Deadline
        if (widget.task.deadline != null) _buildDeadlineRow(),

        const SizedBox(height: 6),

        // Rewards (XP & Gold with icons)
        _buildRewardsRow(),
      ],
    );
  }

  Widget _buildDeadlineRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            HelperFunctions.formatDateTimeToString(widget.task.deadline),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsRow() {
    return Row(
      children: [
        // XP Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                "${widget.task.getRewardXp()} XP",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Gold Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 196, 101).withOpacity(1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_money,
                size: 14,
                color: const Color.fromARGB(255, 255, 85, 0),
              ),
              const SizedBox(width: 4),
              Text(
                "${widget.task.getRewardGold()}  ",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 85, 0),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MENU BUTTON ====================
  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      onSelected: (String value) {
        switch (value) {
          case "edit":
            widget.onEdited();
            break;
          case "delete":
            widget.onRemoved();
            break;
          case "finish":
            widget.onFinished();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'finish',
          child: Row(
            children: [
              Icon(
                Icons.done,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 12),
              Text(
                'Finish',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== HELPER METHODS ====================
  Color _getDifficultyColor() {
    return widget.task.difficulty.color;
  }
}

// ==================== CUSTOM PAINTER FOR PATTERN ====================
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    const dotSpacing = 20.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
