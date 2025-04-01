import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class EditProfessorProfileScreen extends StatefulWidget {
  @override
  _EditProfessorProfileScreenState createState() =>
      _EditProfessorProfileScreenState();
}

class _EditProfessorProfileScreenState
    extends State<EditProfessorProfileScreen> {
  late String userId;
  late TextEditingController _nameController;
  late TextEditingController _instrumentController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late String _currentImage = '';
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _nameController = TextEditingController();
    _instrumentController = TextEditingController();
    _priceController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });

    _fetchProfileData();
  }

  _fetchProfileData() async {
    final response = await http.get(Uri.parse(
        'https://api-musicfinder.onrender.com/api/profiles/getProfile/$userId'));

    if (response.statusCode == 200) {
      final profileData = json.decode(response.body);
      setState(() {
        _nameController.text = profileData['nombre'] ?? '';
        _instrumentController.text = profileData['instrumento'] ?? '';
        _priceController.text = profileData['precio'] ?? '';
        _locationController.text = profileData['ubicacion'] ?? '';
        _descriptionController.text = profileData['descripcion'] ?? '';
        _currentImage = profileData['imagen'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al obtener los datos')));
    }
  }

  _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  _updateProfile() async {
    final response = await http.put(
      Uri.parse(
          'https://api-musicfinder.onrender.com/api/profiles/editProfile/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': _nameController.text,
        'instrumento': _instrumentController.text,
        'precio': _priceController.text,
        'ubicacion': _locationController.text,
        'descripcion': _descriptionController.text,
        'imagen': _newImageFile != null ? _newImageFile!.path : _currentImage,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado correctamente')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white), // Título en blanco
        ),
        backgroundColor: Color(0xFF673AB7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4B0082),
                          Color(0xFF9C27B0)
                        ], // darkPurple y purple
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(5, 5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _newImageFile != null
                          ? Image.file(
                              _newImageFile!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 50,
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _buildTextField(_nameController, 'Nombre'),
              SizedBox(height: 16),
              _buildTextField(_instrumentController, 'Instrumento'),
              SizedBox(height: 16),
              _buildTextField(_priceController, 'Precio'),
              SizedBox(height: 16),
              _buildTextField(_locationController, 'Ubicación'),
              SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Descripción'),
              SizedBox(height: 24),
              Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.orange, // Botón color naranja
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        offset: Offset(0, 10),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: _updateProfile,
                    child: Text(
                      'Actualizar Perfil',
                      style: TextStyle(
                          fontSize: 18, color: Colors.white), // Texto blanco
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF6200EE)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        ),
      ),
    );
  }
}
