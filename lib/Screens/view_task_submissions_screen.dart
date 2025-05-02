import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewTaskSubmissionsScreen extends StatefulWidget {
  const ViewTaskSubmissionsScreen({Key? key}) : super(key: key);

  @override
  State<ViewTaskSubmissionsScreen> createState() =>
      _ViewTaskSubmissionsScreenState();
}

class _ViewTaskSubmissionsScreenState extends State<ViewTaskSubmissionsScreen> {
  Future<String> _getSubmittedBy(String userId) async {
    try {
      final userSnap =
          await FirebaseFirestore.instance
              .collection('people')
              .doc(userId)
              .get();
      if (userSnap.exists) {
        final userData = userSnap.data() as Map<String, dynamic>;
        final name = userData['name'] ?? 'Unknown';
        final email = userData['email'] ?? 'No email';
        return '$name ($email)';
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      return 'Error fetching user: $e';
    }
  }

  Future<void> _approveSubmission(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('task_submissions')
          .doc(docId)
          .update({'status': 'approved'});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submission approved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve submission: $e')),
      );
    }
  }

  Future<void> _rejectSubmission(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('task_submissions')
          .doc(docId)
          .update({'status': 'rejected'});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submission rejected')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject submission: $e')),
      );
    }
  }

  Future<void> _deleteSubmission(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('task_submissions')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submission deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete submission: $e')),
      );
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String action,
  ) async {
    return (await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Confirm $action'),
                content: Text(
                  'Are you sure you want to $action this submission?',
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  ElevatedButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submitted Tasks')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('task_submissions')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final submissions = snapshot.data!.docs;

          if (submissions.isEmpty)
            return Center(child: Text("No submissions yet."));

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final doc = submissions[index];
              final docId = doc.id;
              final task = doc['task'] ?? 'Unnamed Task';
              final comments = doc['comments'] ?? 'No comments';
              final status = doc['status'] ?? 'pending';
              final submittedBy = doc['submittedBy'] ?? '';

              return FutureBuilder<String>(
                future: _getSubmittedBy(submittedBy),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final submittedByText = userSnapshot.data ?? 'Unknown User';

                  return Card(
                    margin: EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(task),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text("Comments: $comments"),
                          SizedBox(height: 8),
                          Text("Submitted By: $submittedByText"),
                          SizedBox(height: 8),
                          Text(
                            "Status: ${status.toUpperCase()}",
                            style: TextStyle(
                              color:
                                  status == 'approved'
                                      ? Colors.green
                                      : (status == 'rejected'
                                          ? Colors.red
                                          : Colors.orange),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          bool confirmed = await _showConfirmationDialog(
                            context,
                            value,
                          );
                          if (confirmed) {
                            if (value == 'approve')
                              await _approveSubmission(docId);
                            else if (value == 'reject')
                              await _rejectSubmission(docId);
                            else if (value == 'delete')
                              await _deleteSubmission(docId);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'approve',
                                child: Text('✅ Approve'),
                              ),
                              PopupMenuItem(
                                value: 'reject',
                                child: Text('❌ Reject'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('🗑️ Delete'),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
