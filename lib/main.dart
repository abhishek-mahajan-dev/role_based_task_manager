import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Screens/admin_login.dart';
import 'Screens/manager_login.dart';
import 'Screens/employee_login.dart';
import 'Screens/admin_signup.dart';
import 'Screens/manager_signup.dart';
import 'Screens/employee_signup.dart';
import 'Screens/role_selection.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'Screens/admin_dashboard.dart';
import 'Screens/employee_dashboard.dart';
import 'Screens/manager_dashboard.dart';
import 'Screens/manage_people_screen.dart';
import 'Screens/manage_team_screen.dart';
import 'Screens/project_progress_screen.dart';
import 'Screens/task_progress_screen.dart';
import 'Screens/search_people_screen.dart';
import 'Screens/admin_chat_screen.dart';
import 'Screens/assign_task_screen.dart';
import 'Screens/assign_project_screen.dart';
import 'Screens/search_team_screen.dart';
import 'Screens/assigned_tasks_screen.dart';
import 'Screens/team_progress_screen.dart';
import 'Screens/employee_task_submission_screen.dart';
import 'Screens/submitted_tasks_screen.dart';
import 'Screens/view_task_submissions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  void toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        print('✅ Storage permission granted');
      } else {
        print('❌ Storage permission denied');
      }
    }
  }

  Future<void> saveFcmToken(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('people').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  Future<Widget> _getDashboard() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return RoleSelectionScreen(toggleTheme: toggleTheme);

    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('people')
              .doc(user.uid)
              .get();

      if (!snap.exists || snap.data() == null) {
        return RoleSelectionScreen(toggleTheme: toggleTheme);
      }

      final data = snap.data() as Map<String, dynamic>;
      final String? role = (data['role'] as String?)?.toLowerCase();

      await saveFcmToken(user.uid);

      if (role == 'admin') {
        return AdminDashboard(toggleTheme: toggleTheme);
      } else if (role == 'manager') {
        return ManagerDashboard(toggleTheme: toggleTheme);
      } else if (role == 'employee') {
        return EmployeeDashboard(toggleTheme: toggleTheme);
      } else {
        return RoleSelectionScreen(toggleTheme: toggleTheme);
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return RoleSelectionScreen(toggleTheme: toggleTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
      routes: {
        '/adminLogin': (context) => AdminLogin(),
        '/managerLogin': (context) => ManagerLogin(),
        '/employeeLogin': (context) => EmployeeLogin(),
        '/adminSignup': (context) => AdminSignup(),
        '/managerSignup': (context) => ManagerSignup(),
        '/employeeSignup': (context) => EmployeeSignup(),
        '/admin_dashboard':
            (context) => AdminDashboard(toggleTheme: toggleTheme),
        '/manager_dashboard':
            (context) => ManagerDashboard(toggleTheme: toggleTheme),
        '/employee_dashboard':
            (context) => EmployeeDashboard(toggleTheme: toggleTheme),
        '/manage_people': (context) => ManagePeopleScreen(),
        '/manage_team': (context) => ManageTeamScreen(),
        '/project_progress': (context) => ProjectProgressScreen(),
        '/task_progress': (context) => TaskProgressScreen(),
        '/search_people': (context) => SearchPeopleScreen(),
        '/chatbox': (context) => AdminChatScreen(),
        '/assign_task': (context) => AssignTaskScreen(),
        '/assign_project': (context) => AssignProjectScreen(),
        '/search_team': (context) => SearchTeamScreen(),
        '/assigned_tasks': (context) => AssignedTasksScreen(),
        '/team_progress': (context) => TeamProgressScreen(),
        '/employee_task_submission':
            (context) => EmployeeTaskSubmissionScreen(),
        '/my_projects': (context) => SubmittedTasksScreen(),
        '/view_task_submissions': (context) => ViewTaskSubmissionsScreen(),
      },
    );
  }
}
