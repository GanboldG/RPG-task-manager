import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/task/task.dart';
import 'package:rpg_task_manager/services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _taskBoxNames = ["active_tasks", "completed_tasks", "abandoned_tasks"];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: EdgeInsets.all(5),
              child: Text("Warning: This is debug screen! Will move it in the future, and replace with actual settings screen!!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                  color: Colors.red,
                )
            ),
          ),

          Text("Tasks",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            )
          ),

          const SizedBox(height: 10),

          // Reset Data Button
          _buildSettingsButton(
            icon: Icons.delete_sweep,
            text: 'Reset All Task Data\n(Activate before changing a hive field)',
            color: Colors.red,
            onPressed: _confirmResetData,
          ),
          
          const SizedBox(height: 12),
          
          // Individual Box Buttons
          _buildSettingsButton(
            icon: Icons.playlist_add_check,
            text: 'View Active Tasks',
            color: Colors.green,
            onPressed: () => _showBoxContents('active_tasks'),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsButton(
            icon: Icons.check_circle,
            text: 'View Completed Tasks',
            color: Colors.orange,
            onPressed: () => _showBoxContents('completed_tasks'),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsButton(
            icon: Icons.delete_forever,
            text: 'View Abandoned Tasks',
            color: Colors.grey,
            onPressed: () => _showBoxContents('abandoned_tasks'),
          ),
          
          const SizedBox(height: 12),
          
          Text("User",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            )
          ),

          const SizedBox(height: 11),

          _buildSettingsButton(
            icon: Icons.check_circle,
            text: 'Save User Data locally (To Hive)',
            color: const Color.fromARGB(255, 0, 157, 255),
            onPressed: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                await UserService().saveCurrentUserData();
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User data saved successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving data: $e')),
                  );
                }
              }
            },
          ),

          const Spacer(),
          
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          
          const SizedBox(height: 20),

           _buildSettingsButton(
            icon: Icons.check_circle,
            text: 'Sync To Firestore',
            color: const Color.fromARGB(255, 0, 157, 255),
            onPressed: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              // try
              // send every data to firestore
            },
          ),
        ],
      ),
    );
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

  void _showDataOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View Hive Data'),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add_check, color: Colors.green),
              title: const Text('Active Tasks'),
              onTap: () {
                Navigator.pop(context);
                _showBoxContents('active_tasks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.orange),
              title: const Text('Completed Tasks'),
              onTap: () {
                Navigator.pop(context);
                _showBoxContents('completed_tasks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.grey),
              title: const Text('Abandoned Tasks'),
              onTap: () {
                Navigator.pop(context);
                _showBoxContents('abandoned_tasks');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Colors.purple),
              title: const Text('All Boxes Combined'),
              onTap: () {
                Navigator.pop(context);
                _showAllBoxesContents();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
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

  Future<void> _showAllBoxesContents() async {
    setState(() => _isLoading = true);
    
    try {
      Map<String, List<Task>> allTasks = {};
      int totalCount = 0;
      
      for (String boxName in _taskBoxNames) {
        if (!Hive.isBoxOpen(boxName)) {
          await Hive.openBox<Task>(boxName);
        }
        final box = Hive.box<Task>(boxName);
        final tasks = box.values.toList();
        allTasks[boxName] = tasks;
        totalCount += tasks.length;
      }
      
      if (mounted) {
        if (totalCount == 0) {
          _showEmptyDialog('All Boxes');
        } else {
          _showAllTasksDialog(allTasks);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('All Boxes', e.toString());
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

  void _showAllTasksDialog(Map<String, List<Task>> allTasks) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'All Tasks Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryChip('Active', allTasks['active_tasks']?.length ?? 0, Colors.green),
                  _buildSummaryChip('Completed', allTasks['completed_tasks']?.length ?? 0, Colors.orange),
                  _buildSummaryChip('Abandoned', allTasks['abandoned_tasks']?.length ?? 0, Colors.red),
                ],
              ),
              const Divider(),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.black,
                        tabs: [
                          Tab(text: 'Active'),
                          Tab(text: 'Completed'),
                          Tab(text: 'Abandoned'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTaskList(allTasks['active_tasks'] ?? []),
                            _buildTaskList(allTasks['completed_tasks'] ?? []),
                            _buildTaskList(allTasks['abandoned_tasks'] ?? []),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks in this category'),
      );
    }
    
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${task.difficulty} • ${task.type} • ${task.getBaseMinutes()} min'),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showTaskDetailsDialog(task);
              },
            ),
          ),
        );
      },
    );
  }

  void _showTaskDetailsDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('ID', task.id.toString()),
              const Divider(),
              _buildInfoRow('Difficulty', task.difficulty.toString()),
              _buildInfoRow('Type', task.type.toString()),
              _buildInfoRow('Base Minutes', '${task.getBaseMinutes()}'),
              _buildInfoRow('Description', task.description.isNotEmpty ? task.description : 'No description'),
              _buildInfoRow('Deadline', task.deadline != null ? _formatDate(task.deadline!) : 'No deadline'),
              _buildInfoRow('Created', _formatDate(task.createdAt)),
              _buildInfoRow('Completed', task.isCompleted ? 'Yes' : 'No'),
              if (task.completedAt != null)
                _buildInfoRow('Completed At', _formatDate(task.completedAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
            width: 100,
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

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  void _showEmptyDialog(String boxName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$boxName is Empty'),
        content: const Text('No tasks found in this box.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Task Data?'),
        content: const Text(
          'This will permanently delete all tasks from active, completed, and abandoned boxes. This action cannot be undone.',
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
    // Close all boxes first
    await Hive.close();
    
    // Delete each box from disk
    for (String boxName in _taskBoxNames) {
      await Hive.deleteBoxFromDisk(boxName);
    }
    
    // Reopen all boxes with proper typing
    for (String boxName in _taskBoxNames) {
      await Hive.openBox<Task>(boxName);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All task data has been reset\nNow restart the app! (IMPORTANT)')),
      );
    }
    
    // Debug print to verify
    final box = Hive.box<Task>('active_tasks');
    debugPrint("${box.length} tasks in active_tasks");
    final completeBox = Hive.box<Task>('completed_tasks');
    debugPrint("${completeBox.length} tasks in completed_tasks");
    
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting data: $e')),
      );
      _showErrorDialog('Reset', e.toString());
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}