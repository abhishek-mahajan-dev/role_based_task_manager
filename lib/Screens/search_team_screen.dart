import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchTeamScreen extends StatefulWidget {
  @override
  _SearchTeamScreenState createState() => _SearchTeamScreenState();
}

class _SearchTeamScreenState extends State<SearchTeamScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Teams')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(labelText: 'Search team name'),
              onChanged: (val) => setState(() => query = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('teams').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final teams =
                    snapshot.data!.docs.where((doc) {
                      final name = doc['name'].toLowerCase();
                      return name.contains(query);
                    }).toList();

                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return ListTile(
                      title: Text(team['name']),
                      subtitle: Text(
                        'Members: ${(team['members'] as List).length}',
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
