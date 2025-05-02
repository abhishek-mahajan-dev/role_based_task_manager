import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamProgressScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Team Progress')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('people')
                .doc(user!.uid)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No team information found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null ||
              !data.containsKey('teamId') ||
              data['teamId'] == null) {
            return Center(child: Text('You are not assigned to any team.'));
          }

          final teamId = data['teamId'];

          return StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('people')
                    .where('teamId', isEqualTo: teamId)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No team members found.'));
              }

              final teamMembers = snapshot.data!.docs;

              return ListView.builder(
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  final member =
                      teamMembers[index].data() as Map<String, dynamic>;
                  final name = member['name'] ?? 'Unknown';
                  final email = member['email'] ?? 'No Email';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text('Email: $email'),
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
