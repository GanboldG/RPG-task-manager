import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget{
  ShopScreen({super.key});

  @override 
  State<ShopScreen> createState() => _ShopScreenState();
}


class _ShopScreenState extends State<ShopScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shop),
            Text("This is Shop Screen"),
          ]
        )
      )
    );
  }
}