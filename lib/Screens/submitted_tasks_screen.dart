import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubmittedTasksScreen extends StatefulWidget {
  @override
  _SubmittedTasksScreenState createState() => _SubmittedTasksScreenState();
}

class _SubmittedTasksScreenState extends State<SubmittedTasksScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📄 Submitted Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search by task name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('task_submissions')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final submissions = snapshot.data!.docs;

                final filtered =
                    submissions.where((doc) {
                      final taskName = (doc['task'] ?? '').toLowerCase();
                      return taskName.contains(_searchQuery);
                    }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text('No submitted tasks found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final taskName = doc['task'] ?? 'Unnamed Task';
                    final comments = doc['comments'] ?? 'No comments';
                    final status = doc['status'] ?? 'pending';
                    final submittedBy = doc['submittedBy'] ?? 'Unknown';
                    final timestamp =
                        (doc['timestamp'] as Timestamp?)?.toDate();

                    Color statusColor;
                    if (status == 'approved') {
                      statusColor = Colors.green;
                    } else if (status == 'rejected') {
                      statusColor = Colors.red;
                    } else {
                      statusColor = Colors.orange;
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      elevation: 4,
                      child: ListTile(
                        title: Text(taskName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text(
                              "Comments:\n$comments",
                              style: TextStyle(fontSize: 13),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Submitted By: $submittedBy",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 6),
                            if (timestamp != null)
                              Text(
                                "Submitted on: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            SizedBox(height: 8),
                            Text(
                              "Status: ${status.toUpperCase()}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
