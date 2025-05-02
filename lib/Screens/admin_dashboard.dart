import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback? toggleTheme;
  const AdminDashboard({Key? key, this.toggleTheme}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
        title: Text("Admin Dashboard"),
        actions: [
          if (widget.toggleTheme != null)
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: widget.toggleTheme,
            ),
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
              "Welcome to the Admin Dashboard!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildButton(
              label: '👥 Manage People',
              onTap: () => Navigator.pushNamed(context, '/manage_people'),
            ),
            _buildButton(
              label: '👨‍👩‍👧‍👦 Manage Team',
              onTap: () => Navigator.pushNamed(context, '/manage_team'),
            ),
            _buildButton(
              label: '📊 View Project Progress',
              onTap: () => Navigator.pushNamed(context, '/project_progress'),
            ),
            _buildButton(
              label: '📈 View Task Progress',
              onTap: () => Navigator.pushNamed(context, '/task_progress'),
            ),
            _buildButton(
              label: '🔍 Search People',
              onTap: () => Navigator.pushNamed(context, '/search_people'),
            ),
            _buildButton(
              label: '💬 Chatbox',
              onTap: () => Navigator.pushNamed(context, '/chatbox'),
            ),
          ],
        ),
      ),
    );
  }
}
