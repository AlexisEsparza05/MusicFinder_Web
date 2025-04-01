import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward(); // Play animation on screen load
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa tu correo y contraseña.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api-musicfinder.onrender.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': email,
          'contraseña': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        String userId = data['id'];
        String userRole = data['rol'];
        await _saveUserId(userId);

        if (userRole == 'Profesor') {
          Navigator.pushReplacementNamed(context, '/professorHome');
        } else if (userRole == 'Estudiante') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (userRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminHome');
        } else {
          setState(() {
            _errorMessage = 'Rol desconocido. Contacta al soporte.';
          });
        }
      } else {
        setState(() {
          _errorMessage = data['mensaje'] ?? 'Error desconocido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectar con el servidor.';
      });
    }
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo con el GIF
            Image.network(
              'https://media1.giphy.com/media/xTiTnnnWvRXTeXx3wc/giphy.gif',
              fit: BoxFit.cover,
            ),
            // Modal en el centro
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'MusicFinder',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Iniciar sesión',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Correo electrónico',
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildElevatedButton(
                          onPressed: _login,
                          text: 'Iniciar sesión',
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            '¿No tienes cuenta? Regístrate',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required void Function() onPressed,
    required String text,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5, // Added subtle shadow
      ),
      onPressed: onPressed,
      child: const Text(
        'Iniciar sesión',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
