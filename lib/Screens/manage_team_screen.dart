import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTeamScreen extends StatefulWidget {
  @override
  _ManageTeamScreenState createState() => _ManageTeamScreenState();
}

class _ManageTeamScreenState extends State<ManageTeamScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _createTeam() async {
    if (_teamNameController.text.trim().isEmpty) return;
    await _firestore.collection('teams').add({
      'name': _teamNameController.text.trim(),
      'members': [],
    });
    _teamNameController.clear();
  }

  void _assignPersonToTeam(String teamId) async {
    final people = await _firestore.collection('people').get();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children:
              people.docs.map((doc) {
                return ListTile(
                  title: Text(doc['name'] ?? 'No Name'),
                  subtitle: Text(doc['email'] ?? 'No Email'),
                  onTap: () async {
                    await _firestore.collection('teams').doc(teamId).update({
                      'members': FieldValue.arrayUnion([doc.id]),
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        );
      },
    );
  }

  void _showTeamMembers(String teamId, String teamName) async {
    final teamDoc = await _firestore.collection('teams').doc(teamId).get();
    final List<dynamic> memberIds = teamDoc['members'] ?? [];

    if (memberIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No members in this team.')));
      return;
    }

    final memberSnapshots = await Future.wait(
      memberIds.map((id) => _firestore.collection('people').doc(id).get()),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            ListTile(
              title: Text(
                'Members of $teamName',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children:
                    memberSnapshots.map((doc) {
                      final data = doc.data();
                      if (data == null) return SizedBox.shrink();
                      return ListTile(
                        title: Text(data['name'] ?? 'No Name'),
                        subtitle: Text(data['email'] ?? 'No Email'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _firestore
                                .collection('teams')
                                .doc(teamId)
                                .update({
                                  'members': FieldValue.arrayRemove([doc.id]),
                                });
                            Navigator.pop(context);
                            _showTeamMembers(teamId, teamName);
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Teams')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamNameController,
                    decoration: InputDecoration(labelText: 'Team Name'),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: _createTeam),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('teams').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final teams = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    final teamData = team.data() as Map<String, dynamic>;
                    final members = teamData['members'] ?? [];

                    return ListTile(
                      title: Text(team['name'] ?? ''),
                      subtitle: Text('Members: ${members.length}'),
                      onTap:
                          () => _showTeamMembers(team.id, team['name'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.group_add),
                        onPressed: () => _assignPersonToTeam(team.id),
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
