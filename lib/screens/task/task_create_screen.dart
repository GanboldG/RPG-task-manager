import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/app_fonts.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:rpg_task_manager/models/task/task_type.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/models/task/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit; // If provided, we're editing

  const AddTaskScreen({super.key, this.taskToEdit});

  bool get isEditing => taskToEdit != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  int _selectedDays = 0;
  int _selectedHours = 0;
  int _selectedMinutes = 30;
  int _selectedSeconds = 0;
  late Difficulty _selectedDifficulty;
  late TaskType _selectedTaskType;
  late double _baseMinutes;
  DateTime? _selectedDeadline;
  String _description = "";

  // Focus node for time field
  final FocusNode _timeFocusNode = FocusNode();

  // Expandable tile state
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Add focus listener
    _timeFocusNode.addListener(_onFocusChange);

    // Populate fields if editing
    if (widget.isEditing) {
      _nameController.text = widget.taskToEdit!.name;
      _selectedDifficulty = widget.taskToEdit!.difficulty;
      _selectedTaskType = widget.taskToEdit!.type!;
      _baseMinutes = widget.taskToEdit!.getBaseMinutes();
      _selectedDeadline = widget.taskToEdit!.deadline;
      _description = widget.taskToEdit!.description;
    } else {
      _selectedDifficulty = Difficulty.easy;
      _selectedTaskType = TaskType.learning;
      _baseMinutes = 30;
    }

    // Set initial dropdown values
    final int totalMins = _baseMinutes.toInt();
    _selectedDays = totalMins ~/ 1440;
    _selectedHours = (totalMins % 1440) ~/ 60;
    _selectedMinutes = totalMins % 60;
    _selectedSeconds = 0;
  }

  @override
  void dispose() {
    // Remove focus listener
    _timeFocusNode.removeListener(_onFocusChange);

    // Dispose controllers and focus node
    _nameController.dispose();

    _timeFocusNode.dispose();

    super.dispose();
  }

  void _onFocusChange() {
    // When focus is lost (user leaves the text field)
    if (!_timeFocusNode.hasFocus) {
      _validateAndUpdateMinutes();
    }
  }

  void _validateAndUpdateMinutes() {
    final double total =
        _selectedDays * 1440 +
        _selectedHours * 60 +
        _selectedMinutes +
        _selectedSeconds / 60.0;
    if (total < 1) {
      HelperFunctions.showMessage(
        context,
        "Task duration cannot be less than a minute",
      );
      return;
    }
    if (total > 3000) {
      HelperFunctions.showMessage(
        context,
        "Task duration cannot be more than 3000 minutes",
      );
      return;
    }
    setState(() {
      _baseMinutes = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? "Edit Task" : "Add New Task",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildNameField(),
            const SizedBox(height: 20),
            _buildTaskTypeSelector(),
            const SizedBox(height: 20),
            _buildDifficultySelector(),
            const SizedBox(height: 20),
            _buildTimeField(),
            const SizedBox(height: 20),
            _buildExpandableSection(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      maxLength: 30,
      decoration: InputDecoration(
        labelText: "Task Name",
        hintText: "Enter task name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a task name";
        }
        return null;
      },
    );
  }

  Widget _buildTaskTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Task Type",
          style: TextStyle(
            fontSize: AppFonts.sizeMedium,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: TaskType.values.map((type) {
            final isSelected = _selectedTaskType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTaskType = type;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getTaskTypeIcon(type),
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTaskTypeName(type),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Difficulty",
          style: TextStyle(
            fontSize: AppFonts.sizeMedium,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: Difficulty.values.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDifficulty = difficulty;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getDifficultyIcon(difficulty),
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDifficultyName(difficulty),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    int value,
    int maxValue,
    int step,
    ValueChanged<int?> onChanged,
  ) {
    final items = <int>[];
    for (int i = 0; i <= maxValue; i += step) items.add(i);
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              alignment: Alignment.center,
              items: items
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Center(
                        child: Text('$v', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time Required",
          style: TextStyle(
            fontSize: AppFonts.sizeMedium,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildDropdown("Өдөр", _selectedDays, 9, 1, (v) {
              setState(() {
                _selectedDays = v!;
              });
              _validateAndUpdateMinutes();
            }),
            const SizedBox(width: 6),
            _buildDropdown("Цаг", _selectedHours, 23, 1, (v) {
              setState(() {
                _selectedHours = v!;
              });
              _validateAndUpdateMinutes();
            }),
            const SizedBox(width: 6),
            _buildDropdown("Мин", _selectedMinutes, 59, 1, (v) {
              setState(() {
                _selectedMinutes = v!;
              });
              _validateAndUpdateMinutes();
            }),
            const SizedBox(width: 6),
            _buildDropdown("Сек", _selectedSeconds, 59, 5, (v) {
              setState(() {
                _selectedSeconds = v!;
              });
              _validateAndUpdateMinutes();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandableSection() {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // Removes default dividers
      ),
      child: ExpansionTile(
        title: Text(
          "Advanced Options",
          style: TextStyle(
            fontSize: AppFonts.sizeMedium,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        shape: const Border(), // Remove borders
        collapsedShape: const Border(),
        children: [
          _buildDeadlinePicker(),
          const SizedBox(height: 20),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Deadline (Optional)",
          style: TextStyle(
            fontSize: AppFonts.sizeMedium,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDeadline ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(
                  _selectedDeadline ?? DateTime.now(),
                ),
              );
              if (time != null) {
                setState(() {
                  _selectedDeadline = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDeadline != null
                        ? "${_selectedDeadline!.year}-${_selectedDeadline!.month}-${_selectedDeadline!.day} ${_selectedDeadline!.hour}:${_selectedDeadline!.minute.toString().padLeft(2, '0')}"
                        : "No deadline set",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description (Optional)",
          style: TextStyle(
            fontSize: AppFonts.sizeMedium,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: _description,
          maxLines: 3,
          maxLength: 60,
          decoration: InputDecoration(
            hintText: "Enter task description",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ),
          onChanged: (value) {
            _description = value;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final controller = context.read<TaskController>();

    return ElevatedButton(
      onPressed: () {
        // Force validation of time field before saving
        _validateAndUpdateMinutes();

        // Also unfocus to commit any pending changes
        if (_timeFocusNode.hasFocus) {
          _timeFocusNode.unfocus();
        }

        if (_formKey.currentState!.validate()) {
          if (widget.isEditing) {
            // Update existing task
            controller.updateTask(
              id: widget.taskToEdit!.id,
              name: _nameController.text,
              difficulty: _selectedDifficulty,
              type: _selectedTaskType,
              baseMinutes: _baseMinutes,
              deadline: _selectedDeadline,
              description: _description,
            );
          } else {
            // Add new task
            controller.addTask(
              name: _nameController.text,
              difficulty: _selectedDifficulty,
              type: _selectedTaskType,
              baseMinutes: _baseMinutes,
              deadline: _selectedDeadline,
              description: _description,
            );
          }
          Navigator.pop(context, true);
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.background,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        widget.isEditing ? "Save Changes" : "Add Task",
        style: TextStyle(
          fontSize: AppFonts.sizeMedium,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper methods for Task Type
  String _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.learning:
        return '📚';
      case TaskType.health:
        return '💪';
      case TaskType.chore:
        return '🧹';
      case TaskType.social:
        return '💬';
      case TaskType.career:
        return '💼';
    }
  }

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.learning:
        return 'Learn';
      case TaskType.health:
        return 'Health';
      case TaskType.chore:
        return 'Chore';
      case TaskType.social:
        return 'Social';
      case TaskType.career:
        return 'Career';
    }
  }

  // Helper methods for Difficulty
  String _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '🌱';
      case Difficulty.medium:
        return '⚡';
      case Difficulty.hard:
        return '🔥';
      case Difficulty.expert:
        return '💀';
    }
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }
}
