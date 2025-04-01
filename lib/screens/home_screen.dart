import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'professor_profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MusicFinder',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> professors = [];

  @override
  void initState() {
    super.initState();
    fetchProfessors();
  }

  Future<void> fetchProfessors() async {
    final url = 'https://api-musicfinder.onrender.com/api/homealumno';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          professors = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar los profesores';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profesores Disponibles',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 18)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: professors.length,
                    itemBuilder: (ctx, index) {
                      final professor = professors[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Transform.scale(
                          scale: 1.02,
                          child: Card(
                            elevation: 6,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: Hero(
                                tag: 'prof-${professor['nombre']}',
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: professor['imagen'] != ''
                                      ? NetworkImage(professor['imagen'])
                                      : AssetImage(
                                              'assets/profile_placeholder.png')
                                          as ImageProvider,
                                ),
                              ),
                              title: Text(
                                professor['nombre'],
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(professor['instrumento'],
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 5),
                                  Text(
                                    professor['precio'],
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        Icons.star,
                                        color: starIndex <
                                                professor['rating'].toInt()
                                            ? Colors.orange
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 18, color: Colors.deepPurple),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfessorProfileScreen(
                                            professor: professor),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.logout, color: Colors.white),
      ),
    );
  }
}
