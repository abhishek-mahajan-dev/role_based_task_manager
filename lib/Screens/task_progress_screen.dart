import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskProgressScreen extends StatefulWidget {
  @override
  _TaskProgressScreenState createState() => _TaskProgressScreenState();
}

class _TaskProgressScreenState extends State<TaskProgressScreen> {
  String _searchQuery = '';
  String _sortBy = 'priority';
  bool _ascending = true;

  Map<String, int> statusCount = {
    'pending': 0,
    'in progress': 0,
    'completed': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Progress'),
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            underline: SizedBox(),
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
                labelText: 'Search Tasks...',
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
                    FirebaseFirestore.instance.collection('tasks').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<DocumentSnapshot> tasks = snapshot.data!.docs;

                  statusCount = {
                    'pending': 0,
                    'in progress': 0,
                    'completed': 0,
                  };

                  tasks =
                      tasks.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final taskName =
                            (data['task'] ?? '').toString().toLowerCase();
                        return taskName.contains(_searchQuery);
                      }).toList();

                  tasks.forEach((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    String status = (data['status'] ?? 'pending').toLowerCase();
                    if (statusCount.containsKey(status)) {
                      statusCount[status] = (statusCount[status]! + 1);
                    }
                  });

                  tasks.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aValue = (aData[_sortBy] ?? '').toString();
                    final bValue = (bData[_sortBy] ?? '').toString();
                    return _ascending
                        ? aValue.compareTo(bValue)
                        : bValue.compareTo(aValue);
                  });

                  return Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _getPieSections(),
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final data = task.data() as Map<String, dynamic>;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(data['task'] ?? 'Unnamed Task'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Priority: ${data['priority'] ?? 'N/A'}",
                                    ),
                                    Text(
                                      "Status: ${data['status'] ?? 'pending'}",
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _showEditTaskDialog(task.id, data);
                                    } else if (value == 'delete') {
                                      bool confirm =
                                          await _showConfirmationDialog(
                                            "Delete this task?",
                                          );
                                      if (confirm) {
                                        await FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(task.id)
                                            .delete();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Task deleted successfully!',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTaskDialog(
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    final TextEditingController taskController = TextEditingController(
      text: taskData['task'],
    );
    final TextEditingController priorityController = TextEditingController(
      text: taskData['priority'],
    );
    final TextEditingController statusController = TextEditingController(
      text: taskData['status'],
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(labelText: 'Task'),
                ),
                TextField(
                  controller: priorityController,
                  decoration: InputDecoration(labelText: 'Priority'),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(taskId)
                      .update({
                        'task': taskController.text.trim(),
                        'priority': priorityController.text.trim(),
                        'status': statusController.text.trim(),
                      });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<bool> _showConfirmationDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmation'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  List<PieChartSectionData> _getPieSections() {
    final List<Color> colors = [Colors.orange, Colors.blue, Colors.green];
    final statuses = ['pending', 'in progress', 'completed'];
    final total = statusCount.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'No Data',
          radius: 50,
          titleStyle: TextStyle(color: Colors.white),
        ),
      ];
    }

    return List.generate(statuses.length, (index) {
      final key = statuses[index];
      final value = statusCount[key] ?? 0;
      if (value == 0) return PieChartSectionData(value: 0);

      return PieChartSectionData(
        color: colors[index],
        value: value.toDouble(),
        title: '$key\n$value',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
