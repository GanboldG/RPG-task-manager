import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/controllers/item_shop_controller.dart';
import 'package:rpg_task_manager/controllers/task_controller.dart';
import 'package:rpg_task_manager/screens/create_user_screen.dart';
import 'package:rpg_task_manager/services/firebase_authentication.dart';
import 'package:rpg_task_manager/services/item_service.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          // MAIN UI
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEAD6FF),
                  Color(0xFFF6EEFF),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: Offset(0, 10),
                            color: Color.fromARGB(40, 0, 0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Container(
                            width: size.width * 0.18,
                            height: size.width * 0.18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFAEFF),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "RPG Task Manager",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D1B3D),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Turn your daily tasks into quests.\nEarn rewards. Level up your life.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.login),
                              label: const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7A42F4),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              onPressed: () async {

                                setState(() {
                                  isLoading = true;
                                });

                                try {

                                  final totalStopwatch = Stopwatch()..start();

                                  // Cache controllers early
                                  final appState = context.read<AppState>();
                                  final itemShopController = context.read<ItemShopController>();
                                  final taskController = context.read<TaskController>();

                                  // GOOGLE LOGIN
                                  final loginStopwatch = Stopwatch()..start();

                                  final uid = await FirebaseAuthentication().loginWithGoogle();

                                  loginStopwatch.stop();

                                  print("Google login took: ${loginStopwatch.elapsedMilliseconds} ms");

                                  if (uid == null) return;

                                  final service = UserService();

                                  // CHECK USER EXISTS
                                  final existsStopwatch = Stopwatch()..start();

                                  final exists = await service.userExistInFirestore(uid);

                                  existsStopwatch.stop();

                                  print("userExistInFirestore took: ${existsStopwatch.elapsedMilliseconds} ms");

                                  // NEW USER
                                  if (!exists) {

                                    final navStopwatch = Stopwatch()..start();

                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CreateUserScreen(isOffline: false),
                                      ),
                                    );

                                    navStopwatch.stop();

                                    print("CreateUserScreen navigation took: ${navStopwatch.elapsedMilliseconds} ms");

                                    if (result == null) return;

                                    final initStopwatch = Stopwatch()..start();

                                    await service.initializeFirstTimeUser(result, false);

                                    initStopwatch.stop();

                                    print("initializeFirstTimeUser took: ${initStopwatch.elapsedMilliseconds} ms");
                                  }

                                  // EXISTING USER
                                  else {

                                    // DOWNLOAD USER
                                    final userStopwatch = Stopwatch()..start();

                                    final user = await service.getFromFirestore();

                                    userStopwatch.stop();

                                    print("getFromFirestore USER took: ${userStopwatch.elapsedMilliseconds} ms");

                                    if (user != null) {

                                      final setUserStopwatch = Stopwatch()..start();

                                      service.setCurrentUser(user);

                                      setUserStopwatch.stop();

                                      print("setCurrentUser took: ${setUserStopwatch.elapsedMilliseconds} ms");

                                      // DOWNLOAD CUSTOM ITEMS
                                      final customItemsStopwatch = Stopwatch()..start();

                                      final customItems = await ItemService().getCustomItemsFromFirestore();

                                      customItemsStopwatch.stop();

                                      print("getCustomItemsFromFirestore took: ${customItemsStopwatch.elapsedMilliseconds} ms");

                                      final populateItemsStopwatch = Stopwatch()..start();

                                      itemShopController.populateCustomItemsList(customItems);

                                      populateItemsStopwatch.stop();

                                      print("populateCustomItemsList took: ${populateItemsStopwatch.elapsedMilliseconds} ms");

                                      // DOWNLOAD TASKS
                                      final taskDownloadStopwatch = Stopwatch()..start();

                                      final tasks = await TaskService().getActiveTasksFromFirestore();

                                      taskDownloadStopwatch.stop();

                                      print("TaskService.getFromFirestore took: ${taskDownloadStopwatch.elapsedMilliseconds} ms");

                                      print("Amount of tasks gotten from firebase: ${tasks.length}");

                                      final populateTaskStopwatch = Stopwatch()..start();

                                      taskController.populateTasks(tasks);

                                      populateTaskStopwatch.stop();

                                      print("populateTasks took: ${populateTaskStopwatch.elapsedMilliseconds} ms");

                                      // DOWNLOAD ARCHIVED TASKS
                                      final taskArchiveStopwatch = Stopwatch()..start();
                                      await TaskService().getArchivedTasksFromFirestore();
                                      taskArchiveStopwatch.stop();
                                      print("TaskService.getArchivedTasksFromFirestore took: ${taskArchiveStopwatch.elapsedMilliseconds} ms");

                                      // DOWNLOAD TASK SNAPSHOTS
                                      final taskSnapshotStopwatch = Stopwatch()..start();
                                      await TaskService().getTaskSnapshotsFromFirestore();
                                      taskSnapshotStopwatch.stop();
                                      print("TaskService.getTaskSnapshotsFromFirestore took: ${taskSnapshotStopwatch.elapsedMilliseconds} ms");
                                      
                                      // SAVE LOCAL
                                      final saveStopwatch = Stopwatch()..start();

                                      service.saveCurrentUserData();

                                      saveStopwatch.stop();

                                      print("saveCurrentUserData took: ${saveStopwatch.elapsedMilliseconds} ms");

                                      // LOGIN STATE
                                      final appStateStopwatch = Stopwatch()..start();

                                      appState.setLoggedIn();

                                      appStateStopwatch.stop();

                                      print("setLoggedIn took: ${appStateStopwatch.elapsedMilliseconds} ms");
                                    }
                                  }

                                  totalStopwatch.stop();

                                  print("TOTAL LOGIN FLOW TIME: ${totalStopwatch.elapsedMilliseconds} ms");

                                } catch (e, stack) {

                                  print("LOGIN ERROR: $e");
                                  print(stack);

                                } finally {

                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.cloud_off),
                              label: const Text(
                                "Work Offline",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5A4A68),
                                side: const BorderSide(
                                  color: Color(0xFFD4C7E6),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () async {

                                appState.setOffline();

                                final hasLocalUser = await UserService().loadUserData();

                                if (!hasLocalUser) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CreateUserScreen(isOffline: true),
                                    ),
                                  );
                                  return;
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "Offline mode uses local storage only.\nYou can sign in later anytime.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black45,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // LOADING OVERLAY
          if (isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}