import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/screens/profile_screen.dart';
import 'package:rpg_task_manager/screens/settings_screen.dart';
import 'package:rpg_task_manager/screens/shop_screen.dart';
import 'package:rpg_task_manager/screens/task/tasks_list_screen.dart';
import 'package:rpg_task_manager/services/timer_service.dart';
import 'package:rpg_task_manager/screens/statistics/detailed_statistics.dart';
import 'package:rpg_task_manager/widgets/resource_bar.dart';
import 'package:provider/provider.dart';

// In main.dart, make sure the callback is set AFTER controller is created
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Just create the controller - callback is now set in the constructor
  final taskController = TaskController();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskController),
      ],
      child: const MyApp(),
<<<<<<< HEAD
    )
=======
    ),
>>>>>>> 7a4d64a (delgermaa profile detailed static)
}

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Task Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,

        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedItemColor: Colors.black,
        ),

        appBarTheme: AppBarThemeData(
<<<<<<< HEAD
          backgroundColor: AppColors.appBarSecondary
        ),

        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: AppColors.textSecondary, // Or AppColors.primary
          headerForegroundColor: Colors.white,
          dayBackgroundColor: WidgetStateProperty.all(Colors.white),
          dayForegroundColor: WidgetStateProperty.all(Colors.black87),
          dayOverlayColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteColor: AppColors.primary.withOpacity(0.2),
          hourMinuteTextColor: Colors.black87,
          dialBackgroundColor: AppColors.primary.withOpacity(0.1),
          dialHandColor: AppColors.textSecondary,
          dialTextColor: Colors.black87,
          entryModeIconColor: AppColors.textSecondary,
          hourMinuteShape: const CircleBorder(),
        )
=======
          backgroundColor: AppColors.appBarSecondary,
        ),
>>>>>>> 7a4d64a (delgermaa profile detailed static)
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final List<Widget> _screens = [
    TaskScreen(),
    ShopScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          ResourceBar(),
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: "Shop",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.man), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
