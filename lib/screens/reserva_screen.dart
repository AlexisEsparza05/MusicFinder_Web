import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert'; // Para trabajar con JSON
import 'package:http/http.dart' as http;

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late DateTime selectedDate;
  List<Map<String, dynamic>> reservations = []; // Lista de reservas

  // Controladores para los campos del modal
  final TextEditingController placeController = TextEditingController();
  final TextEditingController googleMapsLinkController =
      TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  Future<void> crearReservaAPI(DateTime fecha, String lugar,
      String googleMapsLink, String startTime, String endTime) async {
    final url = Uri.parse(
        'https://api-musicfinder.onrender.com/reservas/${fecha.toIso8601String()}'); // Usa tu IP local
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'place': lugar,
      'googleMapsLink': googleMapsLink,
      'startTime': startTime,
      'endTime': endTime,
      'status': 'Disponible',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}'); // Para depuración

      if (response.statusCode == 200) {
        print('Reserva creada exitosamente');
      } else {
        print('Error al crear reserva: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void _showCreateReservationDialog({Map<String, dynamic>? reservation}) {
    // Si estamos editando una reserva, pre-llenamos los campos
    if (reservation != null) {
      placeController.text = reservation['place'];
      googleMapsLinkController.text = reservation['googleMapsLink'] ?? '';
      startTimeController.text = reservation['startTime'];
      endTimeController.text = reservation['endTime'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reservation == null ? 'Crear Reserva' : 'Editar Reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fecha seleccionada: ${selectedDate.toLocal()}'),
              const SizedBox(height: 10),
              TextField(
                controller: placeController,
                decoration: const InputDecoration(labelText: 'Lugar'),
              ),
              TextField(
                controller: googleMapsLinkController,
                decoration: const InputDecoration(
                    labelText: 'Link de Google Maps (opcional)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: startTimeController,
                decoration: const InputDecoration(labelText: 'Hora de inicio'),
                readOnly: true,
                onTap: () => _selectTime(context, true),
              ),
              TextField(
                controller: endTimeController,
                decoration:
                    const InputDecoration(labelText: 'Hora de finalización'),
                readOnly: true,
                onTap: () => _selectTime(context, false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Verificar si alguno de los campos está vacío
                if (placeController.text.isEmpty ||
                    startTimeController.text.isEmpty ||
                    endTimeController.text.isEmpty) {
                  // Mostrar un mensaje de error si algún campo está vacío
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Por favor llena todos los campos!'),
                    ),
                  );
                  return;
                }

                // Si estamos editando, actualizamos la reserva
                if (reservation != null) {
                  setState(() {
                    reservation['place'] = placeController.text;
                    reservation['googleMapsLink'] =
                        googleMapsLinkController.text;
                    reservation['startTime'] = startTimeController.text;
                    reservation['endTime'] = endTimeController.text;
                  });
                } else {
                  // Si es una nueva reserva, la agregamos
                  setState(() {
                    reservations.add({
                      'date': selectedDate,
                      'place': placeController.text,
                      'googleMapsLink': googleMapsLinkController.text,
                      'startTime': startTimeController.text,
                      'endTime': endTimeController.text,
                      'status': 'Disponible', // Estado inicial
                    });
                  });

                  // Llamada a la API para crear la reserva
                  crearReservaAPI(
                    selectedDate,
                    placeController.text,
                    googleMapsLinkController.text,
                    startTimeController.text,
                    endTimeController.text,
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text(
                  reservation == null ? 'Crear Reserva' : 'Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar las reservas que coinciden con la fecha seleccionada
    List<Map<String, dynamic>> filteredReservations = reservations
        .where(
            (reservation) => reservation['date'].isAtSameMomentAs(selectedDate))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona una fecha para la reserva',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Calendario con bordes y sombras para efecto 3D
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    offset: Offset(0, 6),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 01, 01),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: selectedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.deepPurple),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.deepPurple),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.deepPurple),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showCreateReservationDialog();
              },
              child: const Text('Crear Clase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
            const SizedBox(height: 20),
            // Contenedor con desplazamiento (scroll)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mostrar las reservas si existen para la fecha seleccionada
                    if (filteredReservations.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: filteredReservations.map((reservation) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(
                                'Horario: ${reservation['startTime']} - ${reservation['endTime']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                _showReservationDetails(reservation);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    if (filteredReservations.isEmpty)
                      const Text('No hay reservas para esta fecha'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCreateReservationDialog({Map<String, dynamic>? reservation}) {
    // Si estamos editando una reserva, pre-llenamos los campos
    if (reservation != null) {
      placeController.text = reservation['place'];
      googleMapsLinkController.text = reservation['googleMapsLink'] ?? '';
      startTimeController.text = reservation['startTime'];
      endTimeController.text = reservation['endTime'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reservation == null ? 'Crear Reserva' : 'Editar Reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fecha seleccionada: ${selectedDate.toLocal()}'),
              const SizedBox(height: 10),
              TextField(
                controller: placeController,
                decoration: const InputDecoration(labelText: 'Lugar'),
              ),
              TextField(
                controller: googleMapsLinkController,
                decoration: const InputDecoration(
                    labelText: 'Link de Google Maps (opcional)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: startTimeController,
                decoration: const InputDecoration(labelText: 'Hora de inicio'),
                readOnly: true,
                onTap: () => _selectTime(context, true),
              ),
              TextField(
                controller: endTimeController,
                decoration:
                    const InputDecoration(labelText: 'Hora de finalización'),
                readOnly: true,
                onTap: () => _selectTime(context, false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Verificar si alguno de los campos está vacío
                if (placeController.text.isEmpty ||
                    startTimeController.text.isEmpty ||
                    endTimeController.text.isEmpty) {
                  // Mostrar un mensaje de error si algún campo está vacío
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Por favor llena todos los campos!'),
                    ),
                  );
                  return;
                }

                // Verificar si ya existe una reserva con el mismo horario
                bool isConflict = reservations.any((existingReservation) {
                  return existingReservation['date']
                          .isAtSameMomentAs(selectedDate) &&
                      existingReservation['startTime'] ==
                          startTimeController.text &&
                      existingReservation['endTime'] == endTimeController.text;
                });

                if (isConflict) {
                  // Mostrar un mensaje de error si hay conflicto
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Ya existe una reserva en este horario!'),
                    ),
                  );
                  return;
                }

                // Si estamos editando, actualizamos la reserva
                if (reservation != null) {
                  setState(() {
                    reservation['place'] = placeController.text;
                    reservation['googleMapsLink'] =
                        googleMapsLinkController.text;
                    reservation['startTime'] = startTimeController.text;
                    reservation['endTime'] = endTimeController.text;
                  });
                } else {
                  // Si es una nueva reserva, la agregamos
                  setState(() {
                    reservations.add({
                      'date': selectedDate,
                      'place': placeController.text,
                      'googleMapsLink': googleMapsLinkController.text,
                      'startTime': startTimeController.text,
                      'endTime': endTimeController.text,
                      'status': 'Disponible', // Estado inicial
                    });
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(
                  reservation == null ? 'Crear Reserva' : 'Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  // Función para seleccionar la hora
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (selectedTime != null) {
      String formattedTime = selectedTime.format(context);
      if (isStartTime) {
        startTimeController.text = formattedTime;
      } else {
        endTimeController.text = formattedTime;
      }
    }
  }

  // Función para mostrar los detalles de la reserva
  void _showReservationDetails(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lugar: ${reservation['place']}'),
              Text('Hora de inicio: ${reservation['startTime']}'),
              Text('Hora de finalización: ${reservation['endTime']}'),
              if (reservation['googleMapsLink'] != null)
                Text('Google Maps: ${reservation['googleMapsLink']}'),
              const SizedBox(height: 10),
              // Estado de la reserva
              Text('Estado: ${reservation['status']}'),
            ],
          ),
          actions: [
            // Botón para cambiar el estado de disponible a reservado (palomita verde)
            IconButton(
              onPressed: () {
                setState(() {
                  reservation['status'] = 'Reservado'; // Cambiar estado
                });
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
            ),
            // Botón para cambiar el estado a disponible (tachar roja)
            IconButton(
              onPressed: () {
                setState(() {
                  reservation['status'] = 'Disponible'; // Cambiar estado
                });
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.cancel,
                color: Colors.red,
                size: 30,
              ),
            ),
            // Botón para editar la reserva (lapiz)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCreateReservationDialog(
                    reservation: reservation); // Abrir el modal de edición
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.blue,
                size: 30,
              ),
            ),
            // Botón para eliminar la reserva (papelera)
            IconButton(
              onPressed: () {
                setState(() {
                  reservations.remove(reservation); // Eliminar la reserva
                });
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 30,
              ),
            ),
          ],
        );
      },
    );
  }
}
