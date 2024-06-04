import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MisReportesPage extends StatefulWidget {
  @override
  _MisReportesPageState createState() => _MisReportesPageState();
}

class Reporte {
  String nombre;
  String hora;
  String descripcion;
  String nivelRiesgo;
  String sistemaReportadoPor;

  Reporte({
    required this.nombre,
    required this.hora,
    required this.descripcion,
    required this.nivelRiesgo,
    required this.sistemaReportadoPor,
  });
}

class _MisReportesPageState extends State<MisReportesPage> {
  List<Reporte> reportes = [
    Reporte(
      nombre: "Reporte 1",
      hora: "08:30 AM",
      descripcion: "Error de conexión",
      nivelRiesgo: "Medio",
      sistemaReportadoPor: "Sistema A",
    ),
    Reporte(
      nombre: "Reporte 2",
      hora: "10:15 AM",
      descripcion: "Pérdida de datos",
      nivelRiesgo: "Alto",
      sistemaReportadoPor: "Sistema B",
    ),
    Reporte(
      nombre: "Reporte 3",
      hora: "02:45 PM",
      descripcion: "Fallo de autenticación",
      nivelRiesgo: "Bajo",
      sistemaReportadoPor: "Sistema C",
    ),
    Reporte(
      nombre: "Reporte 4",
      hora: "04:20 PM",
      descripcion: "Caída del servidor",
      nivelRiesgo: "Alto",
      sistemaReportadoPor: "Sistema D",
    ),
  ];

  List<Reporte> reportesFiltrados = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reportesFiltrados = List.from(reportes);
    _searchController.addListener(() {
      filtrarReportes();
    });
  }

  void filtrarReportes() {
    List<Reporte> _reportes = [];
    _reportes.addAll(reportes);
    if (_searchController.text.isNotEmpty) {
      _reportes.retainWhere((reporte) {
        String searchTerm = _searchController.text.toLowerCase();
        String reporteNombre = reporte.nombre.toLowerCase();
        return reporteNombre.contains(searchTerm);
      });
    }
    setState(() {
      reportesFiltrados = _reportes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Buscar",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reportesFiltrados.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reportesFiltrados[index].nombre),
                  subtitle: Text(
                      "${reportesFiltrados[index].hora} - ${reportesFiltrados[index].descripcion}\nNivel Riesgo: ${reportesFiltrados[index].nivelRiesgo}\nSistema Reportado por: ${reportesFiltrados[index].sistemaReportadoPor}"),
                  onTap: () {
                    // Aquí puedes hacer algo con el archivo PDF, como abrirlo
                    // con una aplicación de visualización de PDFs
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
