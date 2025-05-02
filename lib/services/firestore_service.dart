import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getProjects() {
    return _db.collection('projects').snapshots();
  }

  Stream<QuerySnapshot> getTasks() {
    return _db.collection('tasks').snapshots();
  }

  Future<void> addProject(String title, String description) async {
    await _db.collection('projects').add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTask(String title, String description) async {
    await _db.collection('tasks').add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

Future<void> addProject(String title, String description) async {
  await FirebaseFirestore.instance.collection('projects').add({
    'title': title,
    'description': description,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<void> addTask(String title, String description) async {
  await FirebaseFirestore.instance.collection('tasks').add({
    'title': title,
    'description': description,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
