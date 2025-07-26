import 'package:flutter/material.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced ToDo App',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: ToDoHomePage(onToggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class Task {
  final String title;
  final String description;
  final DateTime? dueDate;
  final String category;
  bool isDone;

  Task({
    required this.title,
    required this.description,
    this.dueDate,
    this.category = "General",
    this.isDone = false,
  });
}

class ToDoHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const ToDoHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ToDoHomePage> createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  final List<Task> _tasks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedCategory = "General";

  final List<String> _categories = ["General", "Work", "Study", "Personal", "Shopping"];

  void _addTask() {
    String title = _titleController.text.trim();
    String desc = _descController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          title: title,
          description: desc,
          dueDate: _selectedDueDate,
          category: _selectedCategory,
        ));
        // Just simulate a reminder
        if (_selectedDueDate != null) {
          print("Reminder set for: $_selectedDueDate");
        }
      });
      _titleController.clear();
      _descController.clear();
      _selectedDueDate = null;
      _selectedCategory = "General";
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _pickDueDate() async {
    final DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedTasks = [..._tasks];
    sortedTasks.sort((a, b) => a.isDone ? 1 : -1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 Smart ToDo"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Fields
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Task Title"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _pickDueDate,
                  icon: const Icon(Icons.date_range),
                  label: const Text("Due Date"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
            ),
            const SizedBox(height: 20),

            // Task List
            Expanded(
              child: sortedTasks.isEmpty
                  ? const Center(child: Text("No tasks yet!"))
                  : ListView.builder(
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        return Card(
                          color: task.isDone ? Colors.green[50] : null,
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isDone,
                              onChanged: (_) => _toggleTask(_tasks.indexOf(task)),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.description.isNotEmpty)
                                  Text(task.description),
                                if (task.dueDate != null)
                                  Text("Due: ${task.dueDate!.toLocal()}".split(' ')[0]),
                                Text("Category: ${task.category}"),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(_tasks.indexOf(task)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}