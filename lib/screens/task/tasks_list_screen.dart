import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/app_fonts.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/screens/task/task_create_screen.dart';
import 'package:rpg_task_manager/widgets/task_tile.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This screen is subscribed to TaskController. Whenever TaskController method
    // calls notifyListeners(), it rebuilds this GUI, very nice!
    final controller = context.watch<TaskController>();
    // final timerService = controller.timerService;
    final tasks = controller.tasks;

    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            _buildLabel("Current Task:", 5),
            _buildChosenTask(context),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel("Tasks (${tasks.length}/60):", 0),
                _buildSortButton(context),
              ],
            ),
            _buildTaskList(context),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Builds GUI of current running task (always shows the first task in the list)
  Widget _buildChosenTask(BuildContext context) {
    final controller = context.read<TaskController>();
    final timerService = controller.timerService;
    final tasks = controller.tasks;

    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: Text(
            "No tasks available. Add a task to get started!",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: AppFonts.sizeMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ALWAYS use the first task in the list (index 0)
    final currentTask = tasks[0];
    final isRunning = timerService.isRunning;
    final isThisTaskRunning =
        timerService.activeTask?.id == currentTask.id && isRunning;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Progress with animation
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: currentTask.progress,
                      strokeWidth: 6,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Text("${(currentTask.progress * 100).toStringAsFixed(1)}%"),
                ],
              ),
              SizedBox(width: 16),

              // Task name / description
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isThisTaskRunning ? "ACTIVE TASK" : "NEXT TASK",
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentTask.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppFonts.sizeMedium,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          // Time info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard(
                  title: "To Finish:",
                  value: currentTask.getRemainingTimeString(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                ),
                _buildInfoCard(
                  title: "Studying for:",
                  value: currentTask.getFormattedStudyingTime(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                ),
                _buildInfoCard(
                  title: "Till deadline:",
                  value: currentTask.getTimeTillDeadlineString(),
                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          // Timer control button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.background,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // DEBUG to check if idCounter is working
              // HelperFunctions.showMessage(context, controller.tasks.map((k) => k.id).toString(), 1);

              setState(() {
                if (isThisTaskRunning) {
                  timerService.stopTimer();
                  HelperFunctions.showMessage(
                    context,
                    "Timer paused for \"${currentTask.name}\"",
                  );

                  // Update doneDuration for storage data
                  controller.updateHiveTaskDoneDuration(taskId: currentTask.id);
                } else {
                  // If another task is running, stop it first
                  if (timerService.isRunning &&
                      timerService.activeTask?.id != currentTask.id) {
                    timerService.stopTimer();
                  }
                  timerService.startTimer(currentTask);
                  HelperFunctions.showMessage(
                    context,
                    "Started working on \"${currentTask.name}\"",
                  );
                }
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isThisTaskRunning ? Icons.pause : Icons.play_arrow,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  isThisTaskRunning ? "Pause" : "Start",
                  style: TextStyle(
                    fontSize: AppFonts.sizeBig,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Show timer status
          if (isThisTaskRunning)
            Text(
              "Timer is running...",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // Helper widget for info cards
  Widget _buildInfoCard({required String title, required String value}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppFonts.sizeSmall,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppFonts.sizeMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  // Builds GUI of tasks list
  Widget _buildTaskList(BuildContext context) {
    final controller = context.read<TaskController>();
    final tasks = controller.tasks;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ReorderableListView(
          buildDefaultDragHandles: true,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: <Widget>[
            for (int i = 0; i < tasks.length; i++) _buildTaskTile(i),
          ],
          onReorder: (oldIndex, newIndex) {
            setState(() {
              controller.reorderTasks(
                oldIndex,
                newIndex,
              ); // mutates _tasks directly
              controller.updateTaskOrderId();

              final timerService = controller.timerService;
              if (timerService.activeTask != null &&
                  controller.tasks.isNotEmpty) {
                if (timerService.activeTask!.id != controller.tasks[0].id) {
                  timerService.stopTimer();
                  HelperFunctions.showMessage(
                    context,
                    "Task reordered - Timer stopped",
                  );
                }
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final controller = context.watch<TaskController>(); // watch, not read

    final labels = {
      TaskSortOrder.manual: "Manual",
      TaskSortOrder.newest: "Newest first",
      TaskSortOrder.oldest: "Oldest first",
      TaskSortOrder.closestDeadline: "Closest deadline",
      TaskSortOrder.closestToCompletion: "Closest to done",
    };

    return PopupMenuButton<TaskSortOrder>(
      color: Theme.of(context).colorScheme.primary,
      onSelected: (order) => controller.setSortOrder(order),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.secondary,
            size: 18,
          ),
          SizedBox(width: 4),
          Text(
            labels[controller.sortOrder]!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: AppFonts.sizeMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.secondary,
            size: 18,
          ),
        ],
      ),
      itemBuilder: (_) => [
        _sortMenuItem(TaskSortOrder.manual, Icons.drag_handle, "Manual"),
        _sortMenuItem(TaskSortOrder.newest, Icons.fiber_new, "Newest first"),
        _sortMenuItem(TaskSortOrder.oldest, Icons.history, "Oldest first"),
        _sortMenuItem(
          TaskSortOrder.closestDeadline,
          Icons.timer,
          "Closest deadline",
        ),
        _sortMenuItem(
          TaskSortOrder.closestToCompletion,
          Icons.percent,
          "Closest to done",
        ),
      ],
    );
  }

  PopupMenuItem<TaskSortOrder> _sortMenuItem(
    TaskSortOrder value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 20),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  // Builds floating task add button
  Widget _buildAddButton(BuildContext context) {
    final taskCount = context.read<TaskController>().tasks.length;

    return FloatingActionButton(
      heroTag: "add_button_fab",
      onPressed: () async {
        if (taskCount >= 60) {
          HelperFunctions.showMessage(
            context,
            "Task limit reached, complete or delete a task to add.",
            duration: 2,
          );
          return;
        }

        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTaskScreen()),
        );
        // Refresh if task was added
        if (result == true) {
          setState(() {});
        }
      },
      child: Icon(Icons.add),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: AppColors.background,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // Builds labels
  Widget _buildLabel(String label, [double margin = 3]) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(left: 12, top: margin, bottom: margin),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: AppFonts.sizeBig,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTile(int i) {
    final TaskController controller = context.read<TaskController>();
    final timerService = controller.timerService;
    final task = controller.tasks[i];
    final isThisTaskRunning =
        timerService.activeTask?.id == task.id && timerService.isRunning;

    // Highlight the first task (current task)
    final isFirstTask = i == 0;

    return Container(
      key: ValueKey(task.id),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      // decoration: isFirstTask && !isThisTaskRunning ? BoxDecoration(
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: Theme.of(context).colorScheme.secondary.withAlpha(125),
      //     width: 2,
      //   ),
      // ) : null,
      child: TaskTile(
        task: task,
        index: i,
        isRunning: isThisTaskRunning,
        isFirstTask: isFirstTask, // Pass this to TaskTile for styling
        onRemoved: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1E1E2E), // Dark background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                title: const Text(
                  'Delete Task?',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete "${task.name}"?',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You will lose:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFFFD700),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${task.getRewardXp()} XP',
                          style: const TextStyle(color: AppColors.level),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFFFD700),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${task.getRewardGold()} Gold',
                          style: const TextStyle(color: AppColors.gold),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      // ----------ACTUAL DELETE METHODS----------
                      if (isThisTaskRunning) timerService.stopTimer();
                      String deletedTaskName = controller.abandonTask(
                        task.id,
                      ); // this deletes
                      HelperFunctions.showMessage(
                        context,
                        "Removed Task \"$deletedTaskName\"",
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        onFinished: () {
          if (isThisTaskRunning) {
            timerService.stopTimer();
          }
          controller.finishTask(task.id);
          // HelperFunctions.showMessage(context, "Finished Task \"$deletedTaskName\" - You earned 100 XP!");
        },
        onEdited: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(taskToEdit: task),
            ),
          );
        },
        onPlayPause: () {
          setState(() {
            if (isThisTaskRunning) {
              timerService.stopTimer();
              HelperFunctions.showMessage(context, "Paused \"${task.name}\"");
            } else {
              // Stop any other running timer first
              if (timerService.isRunning) {
                timerService.stopTimer();
              }
              timerService.startTimer(task);
              HelperFunctions.showMessage(context, "Started \"${task.name}\"");
            }
          });
        },
      ),
    );
  }
}
