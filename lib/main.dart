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
import 'package:rpg_task_manager/helpers/theme_notifier.dart';
import 'package:rpg_task_manager/screens/inventory_screen.dart';
import 'package:rpg_task_manager/screens/login_screen.dart';
import 'package:rpg_task_manager/screens/create_user_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // await Hive.initFlutter();
  // await Hive.deleteBoxFromDisk("user");
  // await Hive.deleteBoxFromDisk("shop_items");
  // await Hive.deleteBoxFromDisk("custom_shop_items");
  // await Hive.deleteBoxFromDisk("archived_tasks");
  // await Hive.deleteBoxFromDisk("active_tasks");
  // await Hive.deleteBoxFromDisk("task_snapshots");

  // Initialize Hive for data storage
  await HiveService.initializeHive();
  await AudioService.instance.init();
  await ConfigService.loadAllConfigs();

  // TODO: Firebase-г идэвхжүүлэх үед доорхыг uncommент хий
  // try {
  //   await Firebase.initializeApp();
  //   debugPrint('✅ Firebase амжилттай холбогдлоо.');
  // } catch (e) {
  //   debugPrint('❌ Firebase холболтолд алдаа гарлаа: $e');
  // }

  await UserService().loadUserData();

  final appState = AppState();
  if (!UserService().currentUserisNull()) {
    appState.setLoggedIn();
  } else {
    // Firebase-гүй үед офлайн горимоор шууд орно
    appState.setOffline();
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

  // await AchievementDatabase.uploadToFirestore(); // Firebase шаардлагатай

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
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final t = themeNotifier.current;
    return MaterialApp(
      title: 'RPG Task Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: t.scaffoldBg,
        primaryColor: t.primary,
        colorScheme: ColorScheme.light(primary: t.primary, secondary: t.accent),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: t.navBar,
          selectedItemColor: t.navSelected,
          unselectedItemColor: t.navUnselected,
        ),
        appBarTheme: AppBarTheme(backgroundColor: t.appBar),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: t.accent,
          headerForegroundColor: Colors.white,
          dayBackgroundColor: WidgetStateProperty.all(Colors.white),
          dayOverlayColor: WidgetStateProperty.all(t.primary.withOpacity(0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteColor: t.primary.withOpacity(0.2),
          hourMinuteTextColor: Colors.black87,
          dialBackgroundColor: t.primary.withOpacity(0.1),
          dialHandColor: t.accent,
          dialTextColor: Colors.black87,
          entryModeIconColor: t.accent,
          hourMinuteShape: const CircleBorder(),
        ),
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
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final hasUser = UserService().hasUser();

    final canEnterApp = hasUser || appState.isLoggedIn || appState.isOffline;

    if (!canEnterApp) {
      return LoginScreen();
    }

    // Offline эсвэл logged in үед controllers-г initialize хийнэ
    if (appState.isLoggedIn || appState.isOffline) {
      // User байхгүй бол (анх нэвтрэх) CreateUserScreen руу явна
      if (UserService().currentUserisNull()) {
        return CreateUserScreen(isOffline: true);
      }
      context.read<UserController>().initialize();
      context.read<TaskController>().initialize();
      context.read<InventoryController>().initialize();
      context.read<CustomItemInventoryController>().initialize();
      context.read<ItemShopController>().initialize();
      return HomePage();
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);

          // inventory
          if (i == 2) {
            AudioService.instance.playBackgroundMusic(
              "assets/audio/touhou_alice.mp3",
            );
          } else {
            AudioService.instance.stopBackgroundMusic();
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: "Shop",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Inventory",
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
