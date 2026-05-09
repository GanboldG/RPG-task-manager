import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/controllers/custom_inventory_controller.dart';
import 'package:rpg_task_manager/controllers/inventory_controller.dart';
import 'package:rpg_task_manager/controllers/item_shop_controller.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/screens/inventory_screen.dart';
import 'package:rpg_task_manager/screens/login_screen.dart';
import 'package:rpg_task_manager/screens/profile_screen.dart';
import 'package:rpg_task_manager/screens/settings_screen.dart';
import 'package:rpg_task_manager/screens/shop_screen.dart';
import 'package:rpg_task_manager/screens/task/tasks_list_screen.dart';
import 'package:rpg_task_manager/services/audio_service.dart';
import 'package:rpg_task_manager/services/config_service.dart';
import 'package:rpg_task_manager/services/hive_service.dart';
import 'package:rpg_task_manager/services/timer/item_timer_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'package:rpg_task_manager/storage/achievement_database.dart';
import 'package:rpg_task_manager/widgets/resource_bar.dart';
import 'package:provider/provider.dart';  
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // await Hive.initFlutter();
  // await Hive.deleteBoxFromDisk("user");
  // await Hive.deleteBoxFromDisk("shop_items");
  // await Hive.deleteBoxFromDisk("custom_shop_items");

  // Initialize Hive for data storage
  await HiveService.initializeHive();
  await AudioService.instance.init();
  await ConfigService.loadAllConfigs();


  try {
    await Firebase.initializeApp(
      // options: DefaultfireBaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase амжилттай холбогдлоо.');
  } catch (e) {
    debugPrint('❌ Firebase холболтолд алдаа гарлаа: $e');
  } 

  // Delete
  // await Hive.deleteBoxFromDisk("user");
  
  await UserService().loadUserData();
  
  final appState = AppState();
  if (!UserService().currentUserisNull()){
    appState.setLoggedIn();
  }

  final itemTimerService = ItemTimerService();
  final userController = UserController();
  final taskController = TaskController(userController);
  final inventoryController = InventoryController(itemTimerService);
  final customInventoryController = CustomItemInventoryController();
  final shopController = ItemShopController(
    inventoryController,
    customInventoryController,
  );
  
  await AchievementDatabase.uploadToFirestore();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskController),
        ChangeNotifierProvider.value(value: shopController),
        ChangeNotifierProvider.value(value: userController),
        ChangeNotifierProvider.value(value: inventoryController),
        ChangeNotifierProvider.value(value: itemTimerService),
        ChangeNotifierProvider.value(value: customInventoryController),
        ChangeNotifierProvider.value(value: appState),
      ],
      child: MyApp(),
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Task Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 224, 208, 235),
        primaryColor: const Color.from(alpha: 1, red: 0.882, green: 0.706, blue: 0.996),

        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          // surface: AppColors.surface,
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedItemColor: Colors.black,
        ),

        appBarTheme: AppBarThemeData(
          backgroundColor: AppColors.appBarSecondary
        ),

        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: AppColors.textSecondary, // Or AppColors.primary
          headerForegroundColor: Colors.white,
          dayBackgroundColor: WidgetStateProperty.all(Colors.white),
          // dayForegroundColor: WidgetStateProperty.all(Colors.black87),
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
      ),
      home: BootstrapScreen(),
    );
  }
}




// Chooses between login screen & main screen
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  bool hasUser = UserService().hasUser();
      


  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final canEnterApp =
        hasUser ||
        appState.isLoggedIn ||
        appState.isOffline;

    if (!canEnterApp) {
      return LoginScreen();
    }

    // Can only run if LoginScreen Navigation is popped

    if (!appState.isLoggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If logged, initialize the controllers
    if (appState.isLoggedIn){
      context.read<UserController>().initialize();
      context.read<TaskController>().initialize();
      context.read<InventoryController>().initialize();
      context.read<CustomItemInventoryController>().initialize();
      context.read<ItemShopController>().initialize();
    } 

    return HomePage();
  }
}


// This should be called after app state has been decided (offline, online)
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final List<Widget> _screens = [
    TaskScreen(),
    ShopScreen(),
    InventoryScreen(),
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

            // inventory
            if (i == 2){
              AudioService.instance.playBackgroundMusic("assets/audio/touhou_alice.mp3");
            }
            else{
              AudioService.instance.stopBackgroundMusic();
            }
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
              icon: Icon(Icons.inventory),
              label: "Inventory",
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