import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  final VoidCallback? toggleTheme;
  const RoleSelectionScreen({Key? key, this.toggleTheme}) : super(key: key);

  Widget _buildRoleButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 20),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleColor =
        Theme.of(context).appBarTheme.titleTextStyle?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Role'),
        actions: [
          if (toggleTheme != null)
            IconButton(icon: Icon(Icons.brightness_6), onPressed: toggleTheme),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CHOOSE YOUR PROFILE",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 40),
              _buildRoleButton(
                label: "Admin",
                onTap: () => Navigator.pushNamed(context, '/adminLogin'),
              ),
              _buildRoleButton(
                label: "Manager",
                onTap: () => Navigator.pushNamed(context, '/managerLogin'),
              ),
              _buildRoleButton(
                label: "Employee",
                onTap: () => Navigator.pushNamed(context, '/employeeLogin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
