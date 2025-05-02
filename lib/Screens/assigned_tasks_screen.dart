import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssignedTasksScreen extends StatefulWidget {
  const AssignedTasksScreen({Key? key}) : super(key: key);

  @override
  _AssignedTasksScreenState createState() => _AssignedTasksScreenState();
}

class _AssignedTasksScreenState extends State<AssignedTasksScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String _searchQuery = '';
  String _sortBy = 'priority';
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            underline: SizedBox(),
            icon: Icon(Icons.sort, color: Colors.white),
            dropdownColor: Colors.blue,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
            items: [
              DropdownMenuItem(
                value: 'priority',
                child: Text('Sort by Priority'),
              ),
              DropdownMenuItem(value: 'status', child: Text('Sort by Status')),
            ],
          ),
          IconButton(
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _ascending = !_ascending;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search tasks...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('tasks')
                        .where('assignedTo', isEqualTo: userId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  var tasks = snapshot.data!.docs;

                  // Search Filter
                  tasks =
                      tasks.where((doc) {
                        final taskName =
                            (doc['task'] ?? '').toString().toLowerCase();
                        return taskName.contains(_searchQuery);
                      }).toList();

                  // Sorting
                  tasks.sort((a, b) {
                    var aValue = (a[_sortBy] ?? '').toString();
                    var bValue = (b[_sortBy] ?? '').toString();
                    return _ascending
                        ? aValue.compareTo(bValue)
                        : bValue.compareTo(aValue);
                  });

                  if (tasks.isEmpty) {
                    return Center(child: Text('No tasks found.'));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final taskName = task['task'] ?? 'Unnamed Task';
                      final priority = task['priority'] ?? 'Not set';
                      final status = task['status'] ?? 'Pending';
                      final dueDate =
                          (task['dueDate'] != null)
                              ? (task['dueDate'] as Timestamp).toDate()
                              : null;

                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          title: Text(taskName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Priority: $priority"),
                              Text("Status: $status"),
                              if (dueDate != null)
                                Text(
                                  "Due: ${dueDate.day}/${dueDate.month}/${dueDate.year} ${dueDate.hour}:${dueDate.minute}",
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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
