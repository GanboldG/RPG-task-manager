import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rpg_task_manager/app_colors.dart';
import 'package:rpg_task_manager/screens/profile_screen.dart';
import 'package:rpg_task_manager/screens/settings_screen.dart';
import 'package:rpg_task_manager/screens/shop_screen.dart';
import 'package:rpg_task_manager/screens/task_screen.dart';
import 'package:rpg_task_manager/widgets/resource_bar.dart';
void main() {
  // To hide status bar on android phone
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
          backgroundColor: AppColors.appBarSecondary
        )
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
              child: IndexedStack(
                index: _index,
                children: _screens,
              ),
            )
          ]
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          onTap: (i) {
            setState(() => _index = i);
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: "Tasks",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_grocery_store),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.man),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
    );
  }
}