import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPeopleScreen extends StatefulWidget {
  @override
  _SearchPeopleScreenState createState() => _SearchPeopleScreenState();
}

class _SearchPeopleScreenState extends State<SearchPeopleScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search People')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name or email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => query = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('people').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final results =
                    snapshot.data!.docs.where((doc) {
                      final name = doc['name']?.toLowerCase() ?? '';
                      final email = doc['email']?.toLowerCase() ?? '';
                      return name.contains(query) || email.contains(query);
                    }).toList();

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final person = results[index];
                    return ListTile(
                      title: Text(person['name']),
                      subtitle: Text(person['email']),
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
