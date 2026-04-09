import 'package:flutter/material.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  // Computed properties
  String get displayName {
    switch (this) {
      case Difficulty.easy: return 'Easy';
      case Difficulty.medium: return 'Medium';
      case Difficulty.hard: return 'Hard';
      case Difficulty.expert: return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case Difficulty.easy: return 'Simple tasks, low effort';
      case Difficulty.medium: return 'Moderate challenge, balanced reward';
      case Difficulty.hard: return 'Difficult tasks, high reward';
      case Difficulty.expert: return 'Extreme challenge, massive reward';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy: return AppColors.taskEasy;
      case Difficulty.medium: return AppColors.taskMedium;
      case Difficulty.hard: return AppColors.taskHard;
      case Difficulty.expert: return AppColors.taskExpert;
    }
  }
}