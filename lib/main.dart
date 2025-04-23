import 'package:assessment/screens/login_screen.dart';
import 'package:assessment/screens/profiles_screen.dart';
import 'package:assessment/services/auth_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final token = await authService.getToken();
  
  runApp(MyApp(initialRoute: token != null ? '/profiles' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profiles': (context) => const ProfilesScreen(),
      },
    );
  }
}
