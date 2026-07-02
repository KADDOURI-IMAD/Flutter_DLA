import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskFormPage extends StatefulWidget {
  final Function(Task) onSaveTask;
  final Task? task;

  const TaskFormPage({super.key, required this.onSaveTask, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isDone: widget.task?.isDone ?? false,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );
      widget.onSaveTask(task);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier la tâche' : 'Ajouter une tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(isEdit ? Icons.edit_note : Icons.add_task, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Titre obligatoire';
                  if (value.trim().length < 3) return 'Minimum 3 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Description obligatoire';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(Icons.save),
                  label: Text(isEdit ? 'Modifier' : 'Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
