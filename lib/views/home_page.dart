import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/task.dart';
import 'login_page.dart';
import 'task_form_page.dart';
import 'stats_page.dart';

enum TaskFilter { all, done, pending }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAuthenticated = false;
  User? _currentUser;
  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks.clear();
      _tasks.addAll(data.map((e) => Task.fromJson(jsonDecode(e))));
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', data);
  }

  void _login(User user) {
    setState(() {
      _isAuthenticated = true;
      _currentUser = user;
    });
  }

  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui')),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = false;
        _currentUser = null;
        _filter = TaskFilter.all;
      });
      if (mounted) Navigator.pop(context);
    }
  }

  void _saveTask(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) {
        _tasks.add(task);
      } else {
        _tasks[index] = task;
      }
    });
    _saveTasks();
  }

  void _deleteTask(String id) {
    setState(() => _tasks.removeWhere((task) => task.id == id));
    _saveTasks();
  }

  void _toggleTask(Task task, bool value) {
    setState(() => task.isDone = value);
    _saveTasks();
  }

  int get _doneCount => _tasks.where((task) => task.isDone).length;
  int get _pendingCount => _tasks.length - _doneCount;

  List<Task> get _filteredTasks {
    if (_filter == TaskFilter.done) return _tasks.where((task) => task.isDone).toList();
    if (_filter == TaskFilter.pending) return _tasks.where((task) => !task.isDone).toList();
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des tâches')),
      drawer: _buildDrawer(),
      body: _isAuthenticated ? _buildHome() : _buildWelcome(),
      floatingActionButton: _isAuthenticated
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskFormPage(onSaveTask: _saveTask)),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildWelcome() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Bienvenue. Connectez-vous pour gérer vos tâches.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Column(
      children: [
        _buildDashboard(),
        _buildFilters(),
        Expanded(child: _buildTaskList()),
      ],
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _smallCard('Total', _tasks.length, Icons.list),
          _smallCard('Terminées', _doneCount, Icons.check_circle),
          _smallCard('En attente', _pendingCount, Icons.pending_actions),
        ],
      ),
    );
  }

  Widget _smallCard(String title, int value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(height: 6),
              Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SegmentedButton<TaskFilter>(
        segments: const [
          ButtonSegment(value: TaskFilter.all, label: Text('Toutes')),
          ButtonSegment(value: TaskFilter.done, label: Text('Finies')),
          ButtonSegment(value: TaskFilter.pending, label: Text('En attente')),
        ],
        selected: {_filter},
        onSelectionChanged: (value) => setState(() => _filter = value.first),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _filteredTasks;
    if (tasks.isEmpty) {
      return const Center(child: Text('Aucune tâche dans cette catégorie.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Checkbox(
              value: task.isDone,
              onChanged: (value) => _toggleTask(task, value ?? false),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(task.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaskFormPage(onSaveTask: _saveTask, task: task)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(task.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (!_isAuthenticated)
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            )
          else
            UserAccountsDrawerHeader(
              accountName: Text(_currentUser!.name),
              accountEmail: Text(_currentUser!.email),
              currentAccountPicture: CircleAvatar(child: Text(_currentUser!.getInitials())),
            ),
          if (!_isAuthenticated)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(onLogin: _login)));
              },
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Mes tâches'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistiques'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StatsPage(total: _tasks.length, done: _doneCount)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _confirmLogout,
            ),
          ],
        ],
      ),
    );
  }
}
