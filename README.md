Things to note:

- pubspec.yaml тохиргооны файлд:
    - flutter_launcher_icons (App-н icon-ийг өөрчлөх сан)
    - just_audio (Дуун файл тоглуулах сан)
    - provider (InheritedWidget-ын хялбарчилсан хувилбар, ашиглахад амархан)

- Өнгөнүүдийг зөвхөн AppColors.dart файлд тодорхойлж, ThemeData-с өнгөө хэрэглэнэ.

- InheritedWidget ашиглахын оронд Provider ашиглаж, controller-үүдээ build() руу subscribe хийнэ.

------------------------------------------------------------------------------------

Things to do:

Storage:
- Add storage files:
    - user_info.json - gold, xp, level, inventory items
    - old_tasks.json - Stores all previously deleted / finished tasks, to show stats
    - tasks_progress.json - Stores all the timestamps of tasks in a year/month/day object - to show stats
    - custom_shop_items.json - Stores the info of custom shop items

Resources:
-  Create an algorithm to calculate how much gold / xp to gain from task (More level = slightly more rewards from tasks)
- Create an algorithm to calculate xp thresholds needed to level up
- Level up animation
- Daily login rewards

Tasks:
- Custom daily tasks
- Custom weekly tasks

Async:
- Notification control (Stop, Start)
- Background run, show up on notification panel
