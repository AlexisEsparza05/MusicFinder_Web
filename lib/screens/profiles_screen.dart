import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Clase para representar el perfil
class Profile {
  final String nombre;
  final String instrumento;
  final String precio;
  final String ubicacion;
  final double rating;
  final String imagen;

  Profile({
    required this.nombre,
    required this.instrumento,
    required this.precio,
    required this.ubicacion,
    required this.rating,
    required this.imagen,
  });

  // Método para convertir los datos del JSON a un objeto Profile
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nombre: json['nombre'] ?? 'Sin nombre', // Valor por defecto si es null
      instrumento: json['instrumento'] ??
          'Sin instrumento', // Valor por defecto si es null
      precio: json['precio'] ?? 'Sin precio', // Valor por defecto si es null
      ubicacion:
          json['ubicacion'] ?? 'Sin ubicación', // Valor por defecto si es null
      rating: json['rating'] != null
          ? json['rating'].toDouble()
          : 0.0, // Si rating es null, asignar 0.0
      imagen: json['imagen'] ??
          'assets/guitar_teacher.jpg', // Valor por defecto si es null
    );
  }
}

class ProfilesScreen extends StatefulWidget {
  @override
  _ProfilesScreenState createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<Profile> profiles = [];
  bool isLoading = true;

  // Función para hacer la petición HTTP
  Future<void> fetchProfiles() async {
    final response =
        await http.get(Uri.parse('https://api-musicfinder.onrender.com/profiles'));

    if (response.statusCode == 200) {
      // Parsear la respuesta JSON
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        profiles = data.map((profile) => Profile.fromJson(profile)).toList();
        isLoading = false;
      });
    } else {
      // Si la API no responde correctamente
      setState(() {
        isLoading = false;
      });
      throw Exception('Error al cargar los perfiles');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfiles(); // Llamar a la función para obtener los perfiles
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profesores de Música',
          style: TextStyle(color: Colors.white), // Título en blanco
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Cargando
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          profile.imagen, // Usando la imagen de la API
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        profile.nombre,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.instrumento),
                          Text(profile.precio,
                              style: const TextStyle(color: Colors.green)),
                          Text(profile.ubicacion,
                              style: const TextStyle(color: Colors.grey)),
                          Row(
                            children: List.generate(
                              5,
                              (starIndex) => Icon(
                                Icons.star,
                                color: starIndex < profile.rating.toInt()
                                    ? Colors.orange
                                    : Colors.grey,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Aquí puedes navegar a más detalles si lo deseas
                      },
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }
}
