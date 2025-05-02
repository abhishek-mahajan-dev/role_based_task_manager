import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProjectProgressScreen extends StatefulWidget {
  @override
  _ProjectProgressScreenState createState() => _ProjectProgressScreenState();
}

class _ProjectProgressScreenState extends State<ProjectProgressScreen> {
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
        title: Text('Project Progress'),
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
                labelText: 'Search Projects...',
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
                        .collection('projects')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No projects found.'));
                  }

                  List<DocumentSnapshot> projects = snapshot.data!.docs;

                  statusCount = {
                    'pending': 0,
                    'in progress': 0,
                    'completed': 0,
                  };

                  projects =
                      projects.where((doc) {
                        final name =
                            (doc['name'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                  projects.forEach((doc) {
                    String status = (doc['status'] ?? 'pending').toLowerCase();
                    if (statusCount.containsKey(status)) {
                      statusCount[status] = (statusCount[status]! + 1);
                    }
                  });

                  projects.sort((a, b) {
                    var aValue = (a[_sortBy] ?? '').toString();
                    var bValue = (b[_sortBy] ?? '').toString();
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
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            final data = project.data() as Map<String, dynamic>;
                            return Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              child: ListTile(
                                title: Text(data['name'] ?? 'Unnamed Project'),
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
                                      _showEditProjectDialog(project.id, data);
                                    } else if (value == 'delete') {
                                      bool confirm =
                                          await _showConfirmationDialog(
                                            "Delete this project?",
                                          );
                                      if (confirm) {
                                        await FirebaseFirestore.instance
                                            .collection('projects')
                                            .doc(project.id)
                                            .delete();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Project deleted successfully!',
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

  Future<void> _showEditProjectDialog(
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    final TextEditingController nameController = TextEditingController(
      text: projectData['name'],
    );
    final TextEditingController priorityController = TextEditingController(
      text: projectData['priority'],
    );
    final TextEditingController statusController = TextEditingController(
      text: projectData['status'],
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Project'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Project Name'),
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
                      .collection('projects')
                      .doc(projectId)
                      .update({
                        'name': nameController.text.trim(),
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
