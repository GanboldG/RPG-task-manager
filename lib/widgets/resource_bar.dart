import "package:flutter/material.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";
import "package:rpg_task_manager/helpers/helper_functions.dart";

class ResourceBar extends StatefulWidget{
  ResourceBar({super.key});

  @override
  State<ResourceBar> createState() => _ResourceBarState();
}


class _ResourceBarState extends State<ResourceBar>{
  @override
  Widget build(BuildContext context){
    return Container(
      color: AppColors.primary,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              HelperFunctions.buildOutlinedIcon(
                icon: Icons.military_tech,
                color: AppColors.level,
                outlineColor: Colors.black,
                size: 28,
                outlineWidth: 2,
              ),

              Text("12"),
            ],
          ),

          Row(
            children: [
              HelperFunctions.buildOutlinedIcon(
                icon: Icons.explicit_rounded,
                color: AppColors.experience,
                outlineColor: Colors.black,
                size: 28,
                outlineWidth: 2,
              ),

              Text("32/100"),
            ]
          ),

          Row(
            children: [
              HelperFunctions.buildOutlinedIcon(
                icon: Icons.monetization_on,
                color: AppColors.gold,
                outlineColor: Colors.black,
                size: 28,
                outlineWidth: 2,
              ),

              Text("342,0\$"),
            ]
          ),

          Row(
            children: [
              HelperFunctions.buildOutlinedIcon(
                icon: Icons.diamond,
                color: AppColors.gemstone,
                outlineColor: Colors.black,
                size: 28,
                outlineWidth: 2,
              ),

              Text("23/60"),
            ]
          )
        ]
      )
    );
  }
}