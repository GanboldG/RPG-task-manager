import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:rpg_task_manager/controllers/user_controller.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";
import "package:rpg_task_manager/helpers/helper_functions.dart";
import "package:rpg_task_manager/services/user_service.dart";

class ResourceBar extends StatefulWidget{
  const ResourceBar({super.key});

  @override
  State<ResourceBar> createState() => _ResourceBarState();
}


class _ResourceBarState extends State<ResourceBar>{
  @override
  Widget build(BuildContext context){
    final controller = context.watch<UserController>();

    return Container(
      color: AppColors.rewardBar,
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

              Text(controller.user.level.toString()),
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

              Text("${controller.user.experiencePoints}/${controller.user.experienceThreshold}"),
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

              Text("${controller.user.golds}"),
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

              Text("${controller.user.crystals}"),
            ]
          )
        ]
      )
    );
  }
}