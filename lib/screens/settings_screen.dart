import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/app_state.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/task/task.dart';
import 'package:rpg_task_manager/models/task/task_snapshot.dart';
import 'package:rpg_task_manager/services/item_service.dart';
import 'package:rpg_task_manager/services/task_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _taskBoxNames = ["active_tasks", "archived_tasks"];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Screen'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          
          const SizedBox(height: 12),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          _buildSettingsButton(
            icon: Icons.check_circle,
            text: 'Sync data to firebase',
            color: const Color.fromARGB(255, 24, 153, 159),
            onPressed: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                await UserService().uploadToFirestore(UserService().currentUser);
                await ItemService().uploadCustomItemsToFirestore();
                await TaskService().uploadActiveTasksToFirestore();
                await TaskService().uploadArchivedTasksToFirestore();
                await TaskService().uploadTaskSnapshotsToFirestore();

                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('EVERYTHING uploaded to firestore')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error uploading EVERYTHING to firestore $e')),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 12),
          
          // Reset Data Button
          _buildSettingsButton(
            icon: Icons.delete_sweep,
            text: 'Logout',
            color: Colors.red,
            onPressed: _confirmResetData,
          ),

          const SizedBox(height: 12),

          _buildSettingsButton(
            icon: Icons.calendar_today,
            text: 'Debug: Task Snapshots',
            color: Colors.purple,
            onPressed: _showTaskSnapshots,
          ),
        ],
      ),
    );
  }

  Future<void> _showTaskSnapshots() async {
    setState(() => _isLoading = true);

    try {
      final box = Hive.box<TaskSnapshot>('task_snapshots');
      final snapshots = box.values.toList();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Task Snapshots (${snapshots.length} days)',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshots.length,
                      itemBuilder: (context, index) {
                        final snapshot = snapshots[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            title: Text(
                              snapshot.day,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${snapshot.taskMinutes.length} tasks worked'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: snapshot.taskMinutes.entries.map((entry) {
                                    return _buildInfoRow(
                                      entry.key, // taskId
                                      '${entry.value.toStringAsFixed(1)} min',
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('task_snapshots', e.toString());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _showBoxContents(String boxName) async {
    setState(() => _isLoading = true);
    
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Task>(boxName);
      }
      
      final box = Hive.box<Task>(boxName);
      final tasks = box.values.toList();
      
      if (mounted) {
        _showTasksDialog(boxName, tasks);
      }
        
    } catch (e) {
      if (mounted) {
        _showErrorDialog(boxName, e.toString());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTasksDialog(String boxName, List<Task> tasks) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '$boxName (${tasks.length} tasks)',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          task.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Difficulty: ${task.difficulty}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('ID', task.id.toString()),
                                const Divider(),
                                _buildInfoRow('Difficulty', task.difficulty.toString()),
                                _buildInfoRow('Type', task.type.toString()),
                                _buildInfoRow('Duration', HelperFunctions.formatDuration(task.baseDurationSec)),
                                _buildInfoRow('Finished in', HelperFunctions.formatDuration(task.doneDurationSec)),
                                _buildInfoRow('Description', task.description.isNotEmpty ? task.description : 'No description'),
                                _buildInfoRow('Deadline', task.deadline != null ? _formatDate(task.deadline!) : 'No deadline'),
                                _buildInfoRow('Created', _formatDate(task.createdAt)),
                                _buildInfoRow('Completed', task.isCompleted ? 'Yes' : 'No'),
                                if (task.completedAt != null)
                                  _buildInfoRow('Completed At', _formatDate(task.completedAt!)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String boxName, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error Loading $boxName'),
        content: Text('Error: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmResetData() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset ALL local Data?'),
        content: const Text(
          '- This will permanently delete all local data from device.\n-Dont forget to sync to firebase.\n- This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData();
              appState.setLoggedOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    setState(() => _isLoading = true);

    try {
      await Hive.close();

      for (final name in _taskBoxNames) {
        await Hive.deleteBoxFromDisk(name);
      }

      _deleteNonTaskBoxes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data cleared. Restart app required.'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);

      if (Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop(); // preferred for mobile
      } else {
        exit(0); // fallback (desktop / debug)
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteNonTaskBoxes() async{
    try{
      await Hive.deleteBoxFromDisk("user");
      await Hive.deleteBoxFromDisk("shop_items");
      await Hive.deleteBoxFromDisk("custom_shop_items");
      // await Hive.openBox<User>('user');
      // await Hive.openBox<Item>('shop_items');
      // await Hive.openBox<CustomItem>('custom_shop_items');
    }catch(e){
      print("Exception $e when trying to delete hive boxes");
    }
  }
}