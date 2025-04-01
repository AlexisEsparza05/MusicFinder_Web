import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> professor;

  // Constructor para pasar los datos del profesor
  const ChatScreen({Key? key, required this.professor}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Cargar el ID del usuario desde SharedPreferences
  void _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString(
          'user_id'); // Asegúrate de tener este ID en las SharedPreferences.
    });
  }

  // Enviar el mensaje (funcionalidad para agregarlo a la lista y enviarlo a la API)
  void _sendMessage() async {
    if (_messageController.text.isEmpty ||
        _userId == null ||
        widget.professor['id'] == null) {
      print("ID de usuario o ID de profesor no disponibles o mensaje vacío");
      return;
    }

    final String apiUrl = "http://192.168.1.143:5000"; // Usa la IP de tu PC

    final message = _messageController.text;

    // Imprimir para verificar que todo esté bien
    print("Enviando mensaje: $message");
    print("Usuario ID: $_userId");
    print("Profesor ID: ${widget.professor['id']}");

    try {
      // Enviar mensaje a la API
      final response = await http.post(
        Uri.parse('$apiUrl/api/chat/sendMessage'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": _userId, // Tu ID de usuario
          "receiver_id": widget.professor['id'], // ID del profesor
          "message": message
        }),
      );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, agregar mensaje a la lista local
        setState(() {
          _messages.add({"sender_id": _userId!, "message": message});
        });

        // Limpiar el campo de mensaje
        _messageController.clear();
      } else {
        print("Error al enviar mensaje: ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.professor['nombre']}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['sender_id'] == _userId
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: message['sender_id'] == _userId
                            ? Colors.blueAccent
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message['message'] ?? '',
                        style: TextStyle(
                          color: message['sender_id'] == _userId
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Campo de texto para nuevos mensajes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed:
                      _sendMessage, // Enviar mensaje al presionar el botón
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
