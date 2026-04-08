import "package:flutter/material.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";
import "package:rpg_task_manager/models/task.dart";

class TaskTile extends StatefulWidget{
  Task task;
  VoidCallback onRemoved;

  TaskTile(
    {super.key, 
    required this.task,
    required this.onRemoved
  });

  @override 
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>{
  @override
  void initState() {
    super.initState();
  }
  
  @override 
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(7),
      color: AppColors.primaryLight,
      margin: EdgeInsets.only(right: 5, left: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTaskInfo(),
          _buildRemoveButton(),
        ]
      )
    );
  }


  // Builds the main task info
  Widget _buildTaskInfo(){
    return Expanded(
      child: Text(widget.task.name),
    );
  }


  // Builds the remove button
  Widget _buildRemoveButton(){
    return IconButton(
      onPressed: widget.onRemoved,
      icon: Icon(Icons.remove),
    );
  }
}