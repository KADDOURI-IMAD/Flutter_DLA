import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  final int total;
  final int done;

  const StatsPage({super.key, required this.total, required this.done});

  @override
  Widget build(BuildContext context) {
    final pending = total - done;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _statCard(Icons.list, 'Total des tâches', total.toString()),
            _statCard(Icons.check_circle, 'Tâches terminées', done.toString()),
            _statCard(Icons.pending_actions, 'Tâches en attente', pending.toString()),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
