import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminChatScreen extends StatefulWidget {
  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;

    String senderText = 'Unknown User';

    try {
      final peopleDoc =
          await FirebaseFirestore.instance
              .collection('people')
              .doc(user.uid)
              .get();

      if (peopleDoc.exists) {
        final data = peopleDoc.data()!;
        final name = (data['name'] ?? '').toString().trim();
        final email = user.email ?? '';

        if (name.isNotEmpty) {
          senderText = "$name ($email)";
        } else {
          senderText = email;
        }
      } else {
        senderText = user.email ?? 'Unknown Email';
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }

    await FirebaseFirestore.instance.collection('messages').add({
      'sender': senderText.trim(),
      'message': _controller.text.trim(),
      'timestamp': Timestamp.now(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chatbox')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final messageText = msg['message'] ?? '';
                    final sender = msg['sender'] ?? 'Unknown';
                    final timestamp =
                        (msg['timestamp'] as Timestamp?)?.toDate();

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        title: Text(sender),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(messageText),
                            SizedBox(height: 4),
                            if (timestamp != null)
                              Text(
                                DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
