import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<ParseObject> tasks = [];
  bool isLoading = false;
  String? userId;
  String? userName;

  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserAndTasks();
  }

  Future<void> loadUserAndTasks() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    userName = prefs.getString('userName');
    if (userId != null) {
      fetchTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  Future<void> fetchTasks() async {
    if (userId == null) return;
    setState(() => isLoading = true);

    final userPointer = ParseObject('user')..objectId = userId;
    final query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('user', userPointer)
      ..orderByDescending('createdAt');

    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() => tasks = response.results as List<ParseObject>);
    } else {
      setState(() => tasks = []);
    }

    setState(() => isLoading = false);
  }

  Future<void> addTask() async {
    if (userId == null) return;
    final title = titleController.text.trim();
    final description = descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final userPointer = ParseObject('user')..objectId = userId;
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('description', description)
      ..set('user', userPointer);

    final response = await task.save();

    if (response.success) {
      titleController.clear();
      descController.clear();
      fetchTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: ${response.error?.message}')),
      );
    }
  }

  Future<void> showEditDialog(ParseObject task) async {
    final editTitle = TextEditingController(text: task.get<String>('title'));
    final editDesc = TextEditingController(text: task.get<String>('description'));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTitle,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: editDesc,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              task
                ..set('title', editTitle.text)
                ..set('description', editDesc.text);
              final response = await task.save();
              if (response.success) {
                Navigator.pop(context);
                fetchTasks();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating task: ${response.error?.message}')),
                );
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteTask(ParseObject task) async {
    await task.delete();
    fetchTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 3,
        title: Text(
          'Hi, ${userName ?? 'User'} 👋',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Input Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: addTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                  ),
                ],
              ),
            ),
          ),

          // Task List Section
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks yet.\nStart by adding one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  title: Text(
                                    task.get<String>('title') ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    task.get<String>('description') ?? '',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blueAccent),
                                        tooltip: 'Edit Task',
                                        onPressed: () => showEditDialog(task),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        tooltip: 'Delete Task',
                                        onPressed: () => deleteTask(task),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
