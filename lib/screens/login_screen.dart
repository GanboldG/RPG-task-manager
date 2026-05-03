import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/screens/create_user_screen.dart';
import 'package:rpg_task_manager/services/firebase_authentication.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
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

                          // PROBLEMS
                          onPressed: () async {
                            final uid = await FirebaseAuthentication().loginWithGoogle();
                            if (uid == null) return;

                            final service = UserService();
                            final exists = await service.userExistInFirestore(uid);

                            // If user doesn't exist in firestore, bring up CreateScreen
                            if (!exists) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateUserScreen(isOffline: false),
                                ),
                              );

                              if (result == null) return;

                              await service.initializeFirstTimeUser(result, false);
                            } 

                            // If user exists in firestore
                            else {
                              final user = await service.getFromFirestore();
                              if (user != null) {
                                service.setCurrentUser(user);
                                
                                // TODO: Also get all the task, custom item info to save locally
                                service.saveCurrentUserData();
                                context.read<AppState>().setLoggedIn();
                              }
                            }
                          }
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
    );
  }
}