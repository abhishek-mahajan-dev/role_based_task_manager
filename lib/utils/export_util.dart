import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ Added for storage permission
import 'package:flutter/material.dart'; // ✅ Added to show Snackbar

Future<void> exportTasksToCSV(BuildContext context) async {
  try {
    // Ask for permission (especially on Android 11+)
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Storage permission denied')));
      return;
    }

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('tasks').get();

    List<List<dynamic>> rows = [];

    rows.add(["Task", "Assigned To", "Priority", "Status"]);

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      rows.add([
        data['task'] ?? '',
        data['assignedTo'] ?? '',
        data['priority'] ?? '',
        data['status'] ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/tasks_report.csv';
    final file = File(path);

    await file.writeAsString(csvData);

    print('CSV File saved at $path');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tasks report exported successfully!')),
    );
  } catch (e) {
    print('Error exporting tasks to CSV: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error exporting tasks: $e')));
  }
}

Future<void> exportProjectsToCSV(BuildContext context) async {
  try {
    // Ask for permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Storage permission denied')));
      return;
    }

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('projects').get();

    List<List<dynamic>> rows = [];

    rows.add(["Project Name", "Assigned Team", "Priority", "Status"]);

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      rows.add([
        data['name'] ?? '',
        data['assignedTo'] ?? '',
        data['priority'] ?? '',
        data['status'] ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/projects_report.csv';
    final file = File(path);

    await file.writeAsString(csvData);

    print('CSV File saved at $path');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Projects report exported successfully!')),
    );
  } catch (e) {
    print('Error exporting projects to CSV: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error exporting projects: $e')));
  }
}
