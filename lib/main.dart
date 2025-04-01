import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/professor_home_screen.dart';
import 'screens/profiles_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Corrección: 'super.key' en lugar de 'key'

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MusicFinder',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/Reservas',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/professorHome': (context) => ProfessorHomeScreen(),
        '/profiles': (context) =>
            ProfilesScreen(), // Agregar la ruta a la pantalla de perfiles
      },
    );
  }
}
