import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:rpg_task_manager/controllers/user_controller.dart";
import "package:rpg_task_manager/helpers/app_colors.dart";
import "package:rpg_task_manager/helpers/helper_functions.dart";

class ResourceBar extends StatefulWidget {
  const ResourceBar({super.key});

  @override
  State<ResourceBar> createState() => _ResourceBarState();
}

class _ResourceBarState extends State<ResourceBar> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();

    return Container(
      color: Theme.of(context).colorScheme.primary,
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

              Text("LVL ${controller.user.level.toString()}"),
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

              Text(controller.getExperienceString()),
            ],
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
            ],
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
            ],
          ),
        ],
      ),
    );
  }
}


// ------------ UPDATED VERSION =---------------
class AnimatedResourceBar extends StatefulWidget {
  const AnimatedResourceBar({super.key});

  @override
  State<AnimatedResourceBar> createState() => AnimatedResourceBarState();
}

class AnimatedResourceBarState extends State<AnimatedResourceBar> {
  final GlobalKey goldKey = GlobalKey();
  final GlobalKey xpKey = GlobalKey();

  int? _prevGold;
  int? _prevXp;
  bool _goldFlash = false;
  bool _xpFlash = false;

  void triggerGoldFlash() {
    if (!mounted) return;
    setState(() => _goldFlash = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _goldFlash = false);
    });
  }

  void triggerXpFlash() {
    if (!mounted) return;
    setState(() => _xpFlash = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _xpFlash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    final gold = controller.user.golds;
    final xp = controller.user.experiencePoints; // adjust field name as needed

    if (_prevGold != null && _prevGold != gold) triggerGoldFlash();
    if (_prevXp != null && _prevXp != xp) triggerXpFlash();
    _prevGold = gold;
    _prevXp = xp;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatChip(
            key: null,
            icon: Icons.military_tech,
            color: AppColors.level,
            label: "LVL",
            value: controller.user.level.toString(),
            flash: false,
          ),
          _buildDivider(context),
          _buildStatChip(
            key: xpKey,
            icon: Icons.auto_awesome,
            color: AppColors.experience,
            label: "XP",
            value: controller.getExperienceString(),
            flash: _xpFlash,
          ),
          _buildDivider(context),
          _buildStatChip(
            key: goldKey,
            icon: Icons.monetization_on,
            color: AppColors.gold,
            label: "GOLD",
            value: "${controller.user.golds}",
            flash: _goldFlash,
          ),
          _buildDivider(context),
          _buildStatChip(
            key: null,
            icon: Icons.diamond,
            color: AppColors.gemstone,
            label: "GEM",
            value: "${controller.user.crystals}",
            flash: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
    );
  }

  Widget _buildStatChip({
    required Key? key,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required bool flash,
  }) {
    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: flash
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HelperFunctions.buildOutlinedIcon(
            icon: icon,
            color: flash ? Colors.white : color,
            outlineColor: Colors.black,
            size: 22,
            outlineWidth: 1.5,
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  value,
                  key: ValueKey(value),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: flash
                        ? color
                        : Theme.of(context).colorScheme.secondary,
                    shadows: flash
                        ? [Shadow(color: color, blurRadius: 8)]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}