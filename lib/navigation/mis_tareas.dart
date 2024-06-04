import 'package:flutter/material.dart';

// Modelo para representar una incidencia
class Incidencia {
  final String titulo;
  final String descripcion;
  final DateTime fechaCreacion;
  final EstadoIncidencia estado;
  final List<Tarea> tareas;

  Incidencia({
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    required this.estado,
    this.tareas = const [],
  });
}

enum EstadoIncidencia {
  pendiente,
  enProgreso,
  completada,
}

// Modelo para representar una tarea
class Tarea {
  final String titulo;
  final String descripcion;
  final DateTime fechaVencimiento;
  bool completada;

  Tarea({
    required this.titulo,
    required this.descripcion,
    required this.fechaVencimiento,
    this.completada = false,
  });
}

class MisTareasPage extends StatelessWidget {
  // Lista de tareas de informes
  final List<Tarea> _tareas = [
    Tarea(
        titulo: 'Revisar informe 1',
        descripcion: 'Revisar el primer informe detalladamente.',
        fechaVencimiento: DateTime.now()),
    Tarea(
        titulo: 'Corregir errores en informe 2',
        descripcion: 'Corregir los errores encontrados en el segundo informe.',
        fechaVencimiento: DateTime.now()),
    Tarea(
        titulo: 'Enviar informe 3 al cliente',
        descripcion: 'Enviar el tercer informe al cliente final.',
        completada: true,
        fechaVencimiento: DateTime.now()),
    Tarea(
        titulo: 'Agregar evidencia al informe 4',
        descripcion: 'Agregar la evidencia necesaria al cuarto informe.',
        fechaVencimiento: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TareaCard(
              fecha: '13/11/2023',
              titulo: 'Definir factores claves de ferreyros',
              nombre: 'Efrain H Segura',
              ubicacion: 'Oficinas',
              estado: 'Se realizó 20',
            ),
            TareaCard(
              fecha: '13/11/2023',
              titulo: 'Definir factores claves de ferreyros',
              nombre: 'Antony L Ramirez',
              ubicacion: 'Vías de Tránsito internos del vehículo',
              estado: 'Generado',
            ),
          ],
        ),
      ),
    );
  }
}

class TareaCard extends StatelessWidget {
  final String fecha;
  final String titulo;
  final String nombre;
  final String ubicacion;
  final String estado;

  TareaCard({
    required this.fecha,
    required this.titulo,
    required this.nombre,
    required this.ubicacion,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PENDIENTE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.tablet_android),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 5),
                Text(fecha),
              ],
            ),
            SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16),
                SizedBox(width: 5),
                Text(nombre),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 5),
                Text(ubicacion),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16),
                SizedBox(width: 5),
                Text(estado),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    // Acción para guardar
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chat),
                  onPressed: () {
                    // Acción para chatear
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Acción para editar
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
