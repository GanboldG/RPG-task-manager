import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget{
  TaskScreen({super.key});

  @override 
  State<TaskScreen> createState() => _TaskScreenState();
}


class _TaskScreenState extends State<TaskScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task),
            Text("This is Task Screen"),
          ]
        )
      )
    );
  }
}