import 'package:flutter/material.dart';
import 'reservas_screen.dart';

class ProfessorProfileScreen extends StatelessWidget {
  final Map<String, dynamic>
      professor; // Asegúrate de que este parámetro esté definido como un Map.

  // Constructor con el parámetro 'professor' requerido
  const ProfessorProfileScreen({Key? key, required this.professor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(professor[
            'nombre']), // Asegúrate de usar las claves correctas en el mapa.
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen de perfil
              CircleAvatar(
                radius: 60,
                backgroundImage: professor['imagen'] != ''
                    ? NetworkImage(professor['imagen'])
                    : AssetImage('assets/profile_placeholder.png')
                        as ImageProvider,
              ),
              SizedBox(height: 16),
              // Nombre y especialización
              Text(
                professor['nombre'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                professor['instrumento'],
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              // Precio por hora
              Text(
                'Precio: ${professor['precio']}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 16),
              // Calificación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < professor['rating'].toInt()
                        ? Colors.orange
                        : Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Descripción
              Text(
                professor['descripcion'] ?? 'Sin descripción',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservaScreen(
                              professor:
                                  professor), // Este es el paso de 'professor' a la siguiente pantalla
                        ),
                      );
                    },
                    icon: Icon(Icons.class_, color: Colors.white),
                    label: Text('Reservar Clase'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text('Mensaje'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Ubicación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(professor['ubicacion'], style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
