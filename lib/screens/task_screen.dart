import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/models/task.dart';
import 'package:rpg_task_manager/widgets/task_tile.dart';

class TaskScreen extends StatefulWidget{
  TaskScreen({super.key});

  @override 
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>{
  late TaskController controller;
  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    controller = TaskController(context: context);
    tasks = controller.tasks;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChosenTask(context),
            _buildTaskList(context),
          ],
        )
      ),
      floatingActionButton: _buildAddButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Builds GUI of current running task
  Widget _buildChosenTask(BuildContext context){
    return Container(
      height: 150,
      width: double.infinity,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary,
      ),
      child: Expanded(
        child: Center(
          child: Text(
            tasks.isNotEmpty ? tasks[0].name : "No tasks available :D",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            )
          )
        )
      )
    );
  }


  // Builds GUI of tasks list
  Widget _buildTaskList(BuildContext context){
    return Expanded(
      child: ReorderableListView(
        children: <Widget>[
          for (int i = 0; i < tasks.length; i++)
          TaskTile(
              key: ValueKey(tasks[i].id),
              task: tasks[i],
              onRemoved: () => setState((){
                controller.deleteTask(tasks[i].id);
              }),
            )
        ],

        onReorder: (oldIndex, newIndex){
          setState(() {
            if (newIndex > oldIndex){newIndex--;}

            // Update the list's elements to syncronize  
            final item = tasks.removeAt(oldIndex);
            tasks.insert(newIndex, item);
          });
        },
      )
    );
  }


  // Builds floating task add button
  Widget _buildAddButton(BuildContext context){
    return FloatingActionButton(
      onPressed: (){
        setState((){
          controller.addTask();
        });
      },
      child: Icon(
        Icons.add,
      ),
    );
  }
}