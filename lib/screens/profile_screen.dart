import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget{
  ProfileScreen({super.key});

  @override 
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.man),
            Text("This is Profile Screen"),
          ]
        )
      )
    );
  }
}