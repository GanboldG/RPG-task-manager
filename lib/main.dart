import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/controllers/custom_inventory_controller.dart';
import 'package:rpg_task_manager/controllers/inventory_controller.dart';
import 'package:rpg_task_manager/controllers/item_shop_controller.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
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
import 'package:rpg_task_manager/widgets/resource_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:rpg_task_manager/services/task_foreground_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await HiveService.initializeHive();
  await AudioService.instance.init();
  await ConfigService.loadAllConfigs();

  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase амжилттай холбогдлоо.');
  } catch (e) {
    debugPrint('❌ Firebase холболтолд алдаа гарлаа: $e');
  }

  await UserService().loadUserData();

  // ЗӨВХӨН НЭГ УДАА дуудна (өмнө 2 удаа байсан)
  TaskForegroundService.initialize();

  final appState = AppState();
  if (!UserService().currentUserisNull()) {
    appState.setLoggedIn();
  } else {
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final t = themeNotifier.current;
    return WithForegroundTask(
      child: MaterialApp(
        title: 'RPG Task Manager',
        theme: ThemeData(
          scaffoldBackgroundColor: t.scaffoldBg,
          primaryColor: t.primary,
          colorScheme: ColorScheme.light(
            primary: t.primary,
            secondary: t.accent,
          ),
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
            dayOverlayColor: WidgetStateProperty.all(
              t.primary.withOpacity(0.1),
            ),
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
      ),
    );
  }
}

// BootstrapScreen БУЦААЖ НЭМЛЭЭ
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!initialized) {
      initialized = true;

      Future.microtask(() {
        context.read<UserController>().initialize();
        context.read<TaskController>().initialize();
        context.read<InventoryController>().initialize();
        context.read<CustomItemInventoryController>().initialize();
        context.read<ItemShopController>().initialize();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final hasUser = UserService().hasUser();

    final canEnterApp = hasUser || appState.isLoggedIn || appState.isOffline;

    if (!canEnterApp) {
      return LoginScreen();
    }

    if (appState.isLoggedIn || appState.isOffline) {
      if (UserService().currentUserisNull()) {
        return CreateUserScreen(isOffline: true);
      }

      return HomePage();
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final GlobalKey<AnimatedResourceBarState> _resourceBarKey =
      GlobalKey<AnimatedResourceBarState>();

  List<Widget> get _screens => [
    TaskScreen(resourceBarKey: _resourceBarKey),
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
          AnimatedResourceBar(key: _resourceBarKey),
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
