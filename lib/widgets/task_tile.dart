import "package:flutter/material.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";
import "package:rpg_task_manager/helpers/app_fonts.dart";
import "package:rpg_task_manager/helpers/helper_functions.dart";
import "package:rpg_task_manager/models/task.dart";

class TaskTile extends StatefulWidget{
  final Task task;
  final VoidCallback onRemoved;
  final VoidCallback onEdited;
  final VoidCallback onFinished;
  final int index;
  final VoidCallback onPlayPause; 
  final bool isRunning;
  final bool isFirstTask;
  
  TaskTile(
    {super.key, 
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

class _TaskTileState extends State<TaskTile>{
  @override
  void initState() {
    super.initState();
  }
  
  @override 
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _getTaskBGcolor(),
              AppColors.primaryLight,
            ],
            stops: [0.05, 0.15], 
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDragListener(),
          _buildCircularProgress(),
          SizedBox(width:5),
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
          color: Colors.black,
          size: 30,
        ),
      )
    );
  }


  // Circular bar to show progress of the task
Widget _buildCircularProgress() {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.all(5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: widget.task.progress,
                strokeWidth: 6,
                backgroundColor: AppColors.textSecondary.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textSecondary,
                ),
              ),
            ),
            Text(
              "${(widget.task.progress * 100).toStringAsFixed(1)}%",
            ),
          ],
        ),
      ),
      // Auto-size text to fit on one line
      Container(
        width: 60, // Match circular progress width
        margin: EdgeInsets.only(top: 4),
        child: FittedBox(
            fit: BoxFit.scaleDown, // Shrinks font to fit, but doesn't stretch
            child: Text(
              "${widget.task.getRemainingTimeString()} left",
              textAlign: TextAlign.center,
            ),
            // child: Text(
            //   "${(widget.task.getBaseMinutes() - widget.task.getDoneMinutes()).toStringAsFixed(1)} min left",
            //   textAlign: TextAlign.center,
            // ),
          ),
        ),
      ],
    );
  }

  // Builds the main task info
  Widget _buildTaskInfo(){
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.task.name,
            maxLines: 2,           // Limit to 2 lines
            overflow: TextOverflow.ellipsis,  // Add "..." when overflow),
          ),

          // Deadline datetime text
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              children: [
                Text(
                  HelperFunctions.formatDateTimeToString(widget.task.deadline),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
                ),
                
                if (widget.task.getRewardString() != "")
                  Text(
                    widget.task.getRewardString(),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 147, 6),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )
                  ),
              ]
            )
          )
        ]
      )
    );
  }


  // Builds the remove button
  Widget _buildRemoveButton(){
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert), // 3 dots icon
      color: AppColors.primaryLight,
      onSelected: (String value) {
        switch (value){
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
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: AppFonts.sizeBig),
              SizedBox(width: 12),
              Text('Edit', style: TextStyle(fontSize: AppFonts.sizeMedium)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, size: AppFonts.sizeBig),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(fontSize: AppFonts.sizeMedium)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'finish',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.done, size: AppFonts.sizeBig),
              SizedBox(width: 12),
              Text('Finish', style: TextStyle(fontSize: AppFonts.sizeMedium)),
            ],
          ),
        ),
      ],
    );
  }


  Color _getTaskBGcolor(){
    return widget.task.difficulty.color;
  }
}