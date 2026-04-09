import "package:flutter/material.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";
import "package:rpg_task_manager/models/task.dart";

class TaskTile extends StatefulWidget{
  final Task task;
  final VoidCallback onRemoved;
  final int index;

  TaskTile(
    {super.key, 
    required this.task,
    required this.index,
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
      color: AppColors.primaryLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDragListener(),
          _buildCircularProgress(),
          _buildTaskInfo(),
          _buildRemoveButton(),
        ]
      )
    );
  }

  Widget _buildDragListener(){
    return ReorderableDragStartListener(
      index: widget.index,
      child: Container(
        padding: EdgeInsets.all(6),
        child: Icon(
          Icons.drag_handle,
          color: Colors.grey,
          size: 30,
        ),
      )
    );
  }


  // Circular bar to show progress of the task
  Widget _buildCircularProgress(){
    return Column(
      children: [
        Icon(
          Icons.run_circle_outlined,
          size: 80,
        ),

        Text("${widget.task.doneMinutes}/${widget.task.baseMinutes}")
      ]
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