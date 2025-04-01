import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'reserva_screen.dart'; // Asegúrate de importar la pantalla de reservas
import 'edit_professor_profile_screen.dart'; // Asegúrate de importar la pantalla de editar perfil

class ProfessorHomeScreen extends StatefulWidget {
  @override
  _ProfessorHomeScreenState createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Función para obtener el perfil del usuario desde la API
  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null) {
      setState(() {
        errorMessage = 'No se encontró el ID del usuario';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://api-musicfinder.onrender.com/getUser');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id": userId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        profileData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Error: ${response.statusCode} - ${response.body}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil Profesor'),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData != null
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        profileData!['imagen'] != null
                            ? ClipOval(
                                child: Image.asset(
                                  profileData!['imagen'],
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.deepPurpleAccent,
                                child: Icon(Icons.person,
                                    size: 70, color: Colors.white),
                              ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple, Colors.blueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(Icons.person,
                                    'Nombre: ${profileData!['nombre']}'),
                                _buildInfoRow(Icons.email,
                                    'Correo: ${profileData!['correo']}'),
                                _buildInfoRow(Icons.music_note,
                                    'Instrumento: ${profileData!['instrumento']}'),
                                _buildInfoRow(Icons.monetization_on,
                                    'Precio: ${profileData!['precio']}'),
                                _buildInfoRow(Icons.location_on,
                                    'Ubicación: ${profileData!['ubicacion']}'),
                                _buildInfoRow(Icons.star,
                                    'Rating: ${profileData!['rating']}'),
                                SizedBox(height: 10),
                                Text(
                                  'Descripción:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(profileData!['descripcion'],
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              'Gestionar Clases',
                              Colors.deepPurple,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              'Editar Perfil',
                              Colors.deepPurple,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfessorProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildActionButton('Cerrar Sesión', Colors.redAccent,
                            () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('userId');
                          Navigator.pushReplacementNamed(context, '/');
                        }),
                      ],
                    ),
                  ),
                )
              : Center(child: Text(errorMessage)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
