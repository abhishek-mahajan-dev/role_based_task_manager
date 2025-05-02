import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignProjectScreen extends StatefulWidget {
  @override
  _AssignProjectScreenState createState() => _AssignProjectScreenState();
}

class _AssignProjectScreenState extends State<AssignProjectScreen> {
  final _projectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedTeamId;
  DateTime? _dueDate;
  String _selectedPriority = 'medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Project')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('teams').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return DropdownButtonFormField(
                    value: _selectedTeamId,
                    hint: Text('Select Team'),
                    items:
                        snapshot.data!.docs.map((doc) {
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(doc['name'] ?? 'Unnamed Team'),
                          );
                        }).toList(),
                    onChanged: (val) => setState(() => _selectedTeamId = val),
                  );
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _projectController,
                decoration: InputDecoration(labelText: 'Project Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Project Description'),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: [
                  DropdownMenuItem(value: 'high', child: Text('High Priority')),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Medium Priority'),
                  ),
                  DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedPriority = val!;
                  });
                },
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(
                  _dueDate == null
                      ? 'Select Due Date & Time'
                      : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} ${_dueDate!.hour}:${_dueDate!.minute.toString().padLeft(2, '0')}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _assignProject,
                child: Text('Assign Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _assignProject() async {
    if (_projectController.text.isNotEmpty &&
        _selectedTeamId != null &&
        _dueDate != null) {
      await FirebaseFirestore.instance.collection('projects').add({
        'assignedTo': _selectedTeamId,
        'name': _projectController.text,
        'description': _descriptionController.text,
        'priority': _selectedPriority,
        'status': 'pending',
        'dueDate': _dueDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Project assigned successfully!')));
      _projectController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedTeamId = null;
        _dueDate = null;
        _selectedPriority = 'medium';
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please complete all fields')));
    }
  }
}
