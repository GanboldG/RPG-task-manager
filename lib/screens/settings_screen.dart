import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget{
  SettingsScreen({super.key});

  @override 
  State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings),
            Text("This is Settings Screen"),
          ]
        )
      )
    );
  }
}