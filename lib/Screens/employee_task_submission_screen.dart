import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeTaskSubmissionScreen extends StatefulWidget {
  @override
  _EmployeeTaskSubmissionScreenState createState() =>
      _EmployeeTaskSubmissionScreenState();
}

class _EmployeeTaskSubmissionScreenState
    extends State<EmployeeTaskSubmissionScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _selectedTaskId;
  List<DocumentSnapshot> _assignedTasks = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedTasks();
  }

  Future<void> _fetchAssignedTasks() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('tasks')
            .where('assignedTo', isEqualTo: userId)
            .get();

    setState(() {
      _assignedTasks = snapshot.docs;
    });
  }

  Future<String> _getSubmittedByDetails(String userId) async {
    try {
      final userSnapshot =
          await FirebaseFirestore.instance
              .collection('people')
              .doc(userId)
              .get();
      if (userSnapshot.exists) {
        return '${userSnapshot['name']} (${userSnapshot['email']})';
      }
      return 'Unknown User';
    } catch (e) {
      return 'Error fetching user';
    }
  }

  Future<void> _submitTask() async {
    if (_selectedTaskId == null || _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a task and fill in comments")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final taskDoc = _assignedTasks.firstWhere(
        (doc) => doc.id == _selectedTaskId,
      );

      await FirebaseFirestore.instance.collection('task_submissions').add({
        'task': taskDoc['task'] ?? 'Unnamed Task',
        'submittedBy': user.uid,
        'taskId': _selectedTaskId,
        'comments': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Task submitted successfully!")));

      setState(() {
        _selectedTaskId = null;
        _commentController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting task: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _assignedTasks.isEmpty
                ? Center(child: Text("No tasks assigned yet"))
                : Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedTaskId,
                      hint: Text('Select Task to Submit'),
                      items:
                          _assignedTasks.map((doc) {
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text(doc['task'] ?? 'Unnamed Task'),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTaskId = val;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: "Task Details / Comments",
                      ),
                      maxLines: 5,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitTask,
                      child: Text("Submit Task"),
                    ),
                    SizedBox(height: 20),

                    FutureBuilder<String>(
                      future:
                          _selectedTaskId != null
                              ? _getSubmittedByDetails(
                                _assignedTasks.firstWhere(
                                  (doc) => doc.id == _selectedTaskId,
                                )['submittedBy'],
                              )
                              : Future.value('No task selected'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading submitted by...");
                        }
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        return Text("Submitted By: ${snapshot.data}");
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}
