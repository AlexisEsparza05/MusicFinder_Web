import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'paypal_payment_screen.dart'; // Importamos la pantalla de PayPal

class ReservaScreen extends StatefulWidget {
  final Map<String, dynamic> professor;

  const ReservaScreen({Key? key, required this.professor}) : super(key: key);

  @override
  _ReservaScreenState createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  List<Map<String, dynamic>> clases = [
    {
      'profesorID': 1,
      'precio': '\$200.00/hora',
      'ubicacion': 'Ciudad de México',
      'descripcion': 'Clases de guitarra con técnicas avanzadas.',
      'horario': 'Lunes 10:00 AM - 12:00 PM'
    },
    {
      'profesorID': 2,
      'precio': '\$300.01/hora',
      'ubicacion': 'Buenos Aires',
      'descripcion': 'Clases de piano para principiantes.',
      'horario': 'Martes 2:00 PM - 4:00 PM'
    }
  ];

  List<Map<String, dynamic>> reservas = [];

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reservasString = prefs.getString('reservas');

    if (reservasString != null) {
      List<dynamic> reservasList = jsonDecode(reservasString);
      setState(() {
        reservas = reservasList.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _guardarReservas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String reservasString = jsonEncode(reservas);
    await prefs.setString('reservas', reservasString);
  }

  void _reservarClase(Map<String, dynamic> clase) {
    String precioRaw = clase['precio']; // '$0.01/hora'
    String precioLimpio = precioRaw.replaceAll(RegExp(r'[^\d.]'), ''); // '0.01'

    Map<String, dynamic> nuevaReserva = {...clase};

    setState(() {
      reservas.add(nuevaReserva);
    });

    _guardarReservas();

    _showPayPalPayment(precioLimpio);
  }

  void _showPayPalPayment(String precio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pagar con PayPal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Precio de la clase: \$${precio}"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PayPalPaymentScreen(precio: precio),
                  ),
                );
              },
              child: Text("Pagar con PayPal"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Clases de Música'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: clases.length,
        itemBuilder: (context, index) {
          final clase = clases[index];

          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                clase['descripcion'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ubicación: ${clase['ubicacion']}'),
                  Text('Horario: ${clase['horario']}'),
                  Text('Precio: ${clase['precio']}',
                      style: TextStyle(color: Colors.green)),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _reservarClase(clase),
                child: Text('Reservar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          );
        },
      ),
    );
  }
}
