import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class CreateUserScreen extends StatefulWidget {
  final bool isOffline;

  const CreateUserScreen({super.key, required this.isOffline});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool get _isValid => _nameController.text.trim().length >= 5;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final username = _nameController.text.trim();

    if (username.length < 5) return;

    bool hasUser = await UserService().initializeFirstTimeUser(username, widget.isOffline);
    if (hasUser){
      AppState appState = context.read<AppState>();
      appState.setLoggedIn();
    }
    // Change the state to loggedIn

    if (!mounted) return;
    Navigator.pop(context, username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 72,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Choose Your Username",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Minimum 5 characters",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  TextField(
                    controller: _nameController,
                    maxLength: 30,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z0-9 ]"),
                      ),

                      /// Prevent 3 spaces in a row
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) {
                          if (newValue.text.contains(RegExp(r" {3,}"))) {
                            return oldValue;
                          }
                          return newValue;
                        },
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: "Username",
                      hintText: "Enter your name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isValid) _submit(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}