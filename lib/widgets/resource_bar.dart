import "package:flutter/material.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";

class ResourceBar extends StatefulWidget{
  ResourceBar({super.key});

  @override
  State<ResourceBar> createState() => _ResourceBarState();
}


class _ResourceBarState extends State<ResourceBar>{
  @override
  Widget build(BuildContext context){
    return Container(
      color: AppColors.appBarSecondary,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech, color: AppColors.level),
              Text("25"),
            ]
          ),

          Row(
            children: [
              Icon(Icons.explicit_rounded, color: AppColors.experience),
              SizedBox(width: 10),
              Text("32/100"),
            ]
          ),

          Row(
            children: [
              Icon(Icons.monetization_on, color: AppColors.gold),
              SizedBox(width: 10),
              Text("342,0\$"),
            ]
          ),

          Row(
            children: [
              Icon(Icons.diamond, color: AppColors.gemstone),
              SizedBox(width: 10),
              Text("23/60"),
            ]
          )
        ]
      )
    );
  }
}