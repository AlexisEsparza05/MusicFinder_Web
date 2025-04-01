import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  String _selectedRole = ''; // Variable para seleccionar el rol
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  // Función para registrar al usuario
  Future<void> _registerUser() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedRole.isEmpty) {
      // Mostrar un mensaje de error si faltan campos
      _showErrorDialog('Todos los campos son necesarios');
      return;
    }

    // Crear el objeto con los datos del usuario
    Map<String, String> userData = {
      'nombre': name,
      'correo': email,
      'contraseña': password,
      'rol': _selectedRole,
    };

    try {
      // Hacer la solicitud POST a la API de registro
      final response = await http.post(
        Uri.parse('https://api-musicfinder.onrender.com/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        // Si el registro es exitoso
        final responseData = json.decode(response.body);
        _showSuccessDialog(responseData['mensaje']);
      } else {
        // Si algo sale mal
        final errorData = json.decode(response.body);
        _showErrorDialog(errorData['mensaje']);
      }
    } catch (e) {
      // Si hay un error de conexión o algo similar
      _showErrorDialog('Error al conectar con el servidor. Intenta más tarde.');
    }
  }

  // Mostrar un mensaje de error en un diálogo
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Mostrar un mensaje de éxito en un diálogo
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Éxito'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(
                  context, '/'); // Redirigir al inicio
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://media1.giphy.com/media/xTiTnnnWvRXTeXx3wc/giphy.gif'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'MusicFinder',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Crear una cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Nombre completo',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 15),
                  // DropdownButton para seleccionar el rol
                  DropdownButtonFormField<String>(
                    value: _selectedRole.isEmpty ? null : _selectedRole,
                    hint: const Text(
                      'Selecciona un rol',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    items: [
                      'Estudiante',
                      'Profesor',
                    ].map((role) {
                      return DropdownMenuItem<String>(
                          value: role, child: Text(role));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue ?? '';
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.account_circle,
                          color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _registerUser,
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '¿Ya tienes una cuenta? Inicia sesión',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
}
