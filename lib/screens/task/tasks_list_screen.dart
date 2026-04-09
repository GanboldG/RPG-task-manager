import 'package:flutter/material.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/app_fonts.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/widgets/task_tile.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget{
  TaskScreen({super.key});

  @override 
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>{
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context){
    // This screen is subscribed to TaskController. Whenever TaskController method
    // calls notifyListeners(), it rebuilds this GUI, very nice!
    final controller = context.watch<TaskController>();
    final tasks = controller.tasks;

    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            _buildLabel("Current Task:", 5),
            _buildChosenTask(context),
            _buildLabel("Tasks:", 5),
            _buildTaskList(context),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Builds GUI of current running task
  Widget _buildChosenTask(BuildContext context){
    final controller = context.read<TaskController>();
    final tasks = controller.tasks;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),

      child: Column(
        children:[
          Row(
            children: [
              // Circular Progress
              Column(
                children: [
                  Icon(
                    Icons.run_circle_outlined,
                    color: AppColors.textSecondary,
                    size: 80,
                  ),
                  // Text("${tasks[0].doneMinutes}m/${tasks[0].baseMinutes}m")
                ]
              ),

              // Task name / description
              Expanded(
                child: Center(
                  child: Text(
                    tasks[0].name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,  // Add "..." when overflow),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFonts.sizeMedium,
                    )
                  ),
                )
              )
            ]
          ),

          SizedBox(height: 10),

          // Datetime info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "To Finish:",
                    style: TextStyle(
                      fontSize: AppFonts.sizeMedium,
                    )
                  ),

                  Text(
                     tasks[0].getRemainingTimeString(),
                     style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFonts.sizeBig,
                    )
                  )
                ]
              ),

              Column(
                children: [
                  Text(
                    "Time till deadline:",
                    style: TextStyle(
                      fontSize: AppFonts.sizeMedium,
                    )
                  ),

                  Text(
                     tasks[0].getTimeTillDeadlineString(),
                     style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFonts.sizeBig,
                    )
                  )
                ]
              ),
            ]
          ),

          SizedBox(height: 10),

          // Button to start / pause the timer
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.background,
              backgroundColor: AppColors.textSecondary
            ),
            onPressed: () => {},
            child: Text(
              "Start",
              style: TextStyle(
                fontSize: AppFonts.sizeBig,
                fontWeight: FontWeight.bold,
              )
            )
         )
        ]
      )
    );
  }

  // Builds GUI of tasks list
  Widget _buildTaskList(BuildContext context){
    final controller = context.read<TaskController>();
    final tasks = controller.tasks;

    return Expanded(
      child: ReorderableListView(
        buildDefaultDragHandles: true, 
        children: <Widget>[
          for (int i = 0; i < tasks.length; i++)
          _buildTaskTile(i),
        ],
        onReorder: (oldIndex, newIndex){
          setState(() {
            if (newIndex > oldIndex){newIndex--;}
            final item = tasks.removeAt(oldIndex);
            tasks.insert(newIndex, item);
          });
        },  
      )
    );
  }


  // Builds floating task add button
  Widget _buildAddButton(BuildContext context){
    final controller = context.read<TaskController>();

    return FloatingActionButton(
      onPressed: controller.addTask,
      child: Icon(
        Icons.add,
      ),
    );
  }


  // Builds labels
  Widget _buildLabel(String label, [double margin = 3]){
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.all(margin),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: AppFonts.sizeBig
          )
        ),
      )
    );
  }


  Widget _buildTaskTile(int i){
    final TaskController controller = context.read<TaskController>();

    return TaskTile(
      key: ValueKey(controller.tasks[i].id),
      task: controller.tasks[i],
      index: i,
      onRemoved: (){
        String deletedTaskName = controller.deleteTask(controller.tasks[i].id);
        HelperFunctions.showMessage(context, "Removed Task \"$deletedTaskName\"");
      },
      onFinished: (){
        String deletedTaskName = controller.deleteTask(controller.tasks[i].id);
        HelperFunctions.showMessage(context, "Finished Task \"$deletedTaskName\"");

        // Ask confirmation
        // Mark as finished;
        // Give rewards
        // Remove from list
      },
      onEdited: (){
        // Move the the add screen (But it is now edit)
        // Refill the variables with old values
      }
    );
  }
}