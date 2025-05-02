import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeDashboard extends StatelessWidget {
  final VoidCallback? toggleTheme;
  const EmployeeDashboard({Key? key, this.toggleTheme}) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon ?? Icons.arrow_forward_ios),
        title: Text(label, style: TextStyle(fontSize: 18)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Welcome to the Employee Dashboard!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildButton(
              label: '📋 My Tasks',
              onTap: () => Navigator.pushNamed(context, '/assigned_tasks'),
            ),
            _buildButton(
              label: '👥 Team Progress',
              onTap: () => Navigator.pushNamed(context, '/team_progress'),
            ),
            _buildButton(
              label: '📊 Project Progress',
              onTap: () => Navigator.pushNamed(context, '/project_progress'),
            ),
            _buildButton(
              label: '📈 Task Progress',
              onTap: () => Navigator.pushNamed(context, '/task_progress'),
            ),
            _buildButton(
              label: '💬 Chatbox',
              onTap: () => Navigator.pushNamed(context, '/chatbox'),
            ),
            _buildButton(
              label: '📎 Submit Task File',
              onTap:
                  () =>
                      Navigator.pushNamed(context, '/employee_task_submission'),
            ),
            _buildButton(
              label: '📄 Submitted Tasks',
              onTap: () => Navigator.pushNamed(context, '/my_projects'),
            ),
          ],
        ),
      ),
    );
  }
}
