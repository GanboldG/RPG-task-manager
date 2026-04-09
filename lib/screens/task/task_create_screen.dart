import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/app_fonts.dart';
import 'package:rpg_task_manager/models/difficulty.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit; // If provided, we're editing
  
  const AddTaskScreen({super.key, this.taskToEdit});
  
  bool get isEditing => taskToEdit != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Difficulty _selectedDifficulty;
  late double _baseMinutes;
  DateTime? _selectedDeadline;
  String _description = "";

  @override
  void initState() {
    super.initState();
    // Populate fields if editing
    if (widget.isEditing) {
      _nameController.text = widget.taskToEdit!.name;
      _selectedDifficulty = widget.taskToEdit!.difficulty;
      _baseMinutes = widget.taskToEdit!.getBaseMinutes();
      _selectedDeadline = widget.taskToEdit!.deadline;
      _description = widget.taskToEdit!.description;
    } else {
      _selectedDifficulty = Difficulty.easy;
      _baseMinutes = 30;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? "Edit Task" : "Add New Task",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildNameField(),
            SizedBox(height: 20),
            _buildDifficultySelector(),
            SizedBox(height: 20),
            _buildTimeField(),
            SizedBox(height: 20),
            _buildDeadlinePicker(),
            SizedBox(height: 20),
            _buildDescriptionField(),
            SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: "Task Name",
        hintText: "Enter task name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColors.primary.withOpacity(0.05),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a task name";
        }
        return null;
      },
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
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 10),
        SegmentedButton<Difficulty>(
          segments: const [
            ButtonSegment(value: Difficulty.easy, label: Text("Easy")),
            ButtonSegment(value: Difficulty.medium, label: Text("Medium")),
            ButtonSegment(value: Difficulty.hard, label: Text("Hard")),
            ButtonSegment(value: Difficulty.expert, label: Text("Expert")),
          ],
          selected: {_selectedDifficulty},
          onSelectionChanged: (Set<Difficulty> selection) {
            setState(() {
              _selectedDifficulty = selection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.textSecondary;
              }
              return AppColors.primary;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
  final TextEditingController _minutesController = TextEditingController(
    text: _baseMinutes.toString(),
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Time Required (minutes)",
        style: TextStyle(
          fontSize: AppFonts.sizeMedium,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
      SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            flex: 5,
            child: Slider(
              value: _baseMinutes.toDouble(),
              min: 5,
              max: 3000,
              divisions: 199, // (300-5)/5 = 99 steps of 5 minutes
              label: "$_baseMinutes min",
              onChanged: (_) => {},
              onChangeEnd: (value) {
                setState(() {
                  _baseMinutes = value;
                  _minutesController.text = _baseMinutes.toString();
                });
              },
              activeColor: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: "min",
                suffixStyle: TextStyle(fontSize: 12),
              ),
              onChanged: (value) {
                final double? minutes = double.tryParse(value);
                if (minutes != null && minutes >= 5 && minutes <= 3000) {
                  setState(() {
                    _baseMinutes = minutes;
                  });
                }
                else if (minutes!= null && minutes > 3000){
                  setState(() {
                    _baseMinutes = 3000;
                  });
                }
                else if (minutes!= null && minutes < 5){
                  setState(() {
                    _baseMinutes = 5;
                  });
                }
              },
            ),
          ),
        ],
      ),
    ],
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
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 10),
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDeadline != null
                        ? "${_selectedDeadline!.year}-${_selectedDeadline!.month}-${_selectedDeadline!.day} ${_selectedDeadline!.hour}:${_selectedDeadline!.minute}"
                        : "No deadline set",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      initialValue: _description,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Description (Optional)",
        hintText: "Enter task description",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColors.primary.withOpacity(0.05),
      ),
      onChanged: (value) {
        _description = value;
      },
    );
  }

  Widget _buildSubmitButton() {
    final controller = context.read<TaskController>();
    
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (widget.isEditing) {
            // Update existing task
            // You'll need to add an updateTask method to your controller
            // controller.updateTask(widget.taskToEdit!.id, ...);
          } else {
            // Add new task
            controller.addTask(
              name: _nameController.text,
              difficulty: _selectedDifficulty,
              baseMinutes: _baseMinutes,
              deadline: _selectedDeadline,
              description: _description,
            );
          }
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.background,
        backgroundColor: AppColors.textSecondary,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
}