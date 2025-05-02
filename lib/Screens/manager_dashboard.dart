import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManagerDashboard extends StatelessWidget {
  final VoidCallback? toggleTheme;
  const ManagerDashboard({Key? key, this.toggleTheme}) : super(key: key);

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
        title: Text("Manager Dashboard"),
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
              "Welcome to the Manager Dashboard!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildButton(
              label: '📝 Assign Task',
              onTap: () => Navigator.pushNamed(context, '/assign_task'),
            ),
            _buildButton(
              label: '📂 Assign Project',
              onTap: () => Navigator.pushNamed(context, '/assign_project'),
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
              label: '🔍 Search People',
              onTap: () => Navigator.pushNamed(context, '/search_people'),
            ),
            _buildButton(
              label: '🔍 Search Teams',
              onTap: () => Navigator.pushNamed(context, '/search_team'),
            ),
            _buildButton(
              label: '💬 Chatbox',
              onTap: () => Navigator.pushNamed(context, '/chatbox'),
            ),
            _buildButton(
              label: '📥 View Task Submissions',
              onTap:
                  () => Navigator.pushNamed(context, '/view_task_submissions'),
            ),
          ],
        ),
      ),
    );
  }
}
