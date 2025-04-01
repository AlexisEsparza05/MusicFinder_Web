import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isCodeSent = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  final String apiUrl = 'https://api-musicfinder.onrender.com';

  Future<void> _requestVerificationCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu correo.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/enviar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isCodeSent = true;
          _successMessage = 'Código enviado a tu correo.';
        });
      } else {
        setState(() {
          _errorMessage = 'Error al enviar el código. Verifica tu correo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectarse con el servidor.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _verifyCodeAndChangePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final email = _emailController.text;
    final code = _codeController.text;
    final newPassword = _newPasswordController.text;

    if (email.isEmpty || code.isEmpty || newPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/cambiar-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'correo': email,
          'codigo': code,
          'nuevaContraseña': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'Contraseña cambiada exitosamente.';
          _isCodeSent = false;
          _emailController.clear();
          _codeController.clear();
          _newPasswordController.clear();
        });
      } else {
        setState(() {
          _errorMessage = 'Código incorrecto o expirado. Intenta de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectarse con el servidor.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://media1.giphy.com/media/xTiTnnnWvRXTeXx3wc/giphy.gif',
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: constraints.maxWidth > 600 ? 400 : double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Recuperar Contraseña',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (_successMessage.isNotEmpty)
                                Text(
                                  _successMessage,
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                              if (!_isCodeSent)
                                _buildEmailForm()
                              else
                                _buildCodeAndPasswordForm(),
                              if (_errorMessage.isNotEmpty)
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildButton('Enviar Código', _requestVerificationCode),
      ],
    );
  }

  Widget _buildCodeAndPasswordForm() {
    return Column(
      children: [
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: 'Código de verificación',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'Nueva contraseña',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildButton('Cambiar Contraseña', _verifyCodeAndChangePassword),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _isLoading ? null : onPressed,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
