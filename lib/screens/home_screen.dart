import 'package:flutter/material.dart';
import 'package:reportya/navigation/mis_reportes.dart';
import 'package:reportya/navigation/mis_tareas.dart';
import 'package:reportya/navigation/my_drawer_header.dart';
import 'package:reportya/navigation/nuevo_reporte.dart';
import 'package:reportya/navigation/seleccionar_unidad.dart';
import 'package:reportya/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  var currentPage = DrawerSections.nuevoreporte;
  var currentTitle = "Nuevo Reporte"; // Título predeterminado

  @override
  Widget build(BuildContext context) {
    var container;
    if (currentPage == DrawerSections.nuevoreporte) {
      container = NuevoReportePage();
    } else if (currentPage == DrawerSections.reportes) {
      container = MisReportesPage();
    } else if (currentPage == DrawerSections.tareas) {
      container = MisTareasPage();
    } else if (currentPage == DrawerSections.seleccionarunidad) {
      container = SeleccionarUnidadPage();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        elevation: 4,
        centerTitle: true,
        title: Text(
          currentTitle, // Usar el título actual
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: container,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                MyHeaderDrawer(),
                MyDrawerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          menuItem(1, "Nuevo Reporte", Icons.article_outlined,
              currentPage == DrawerSections.nuevoreporte ? true : false),
          menuItem(2, "Mis Reportes", Icons.list_alt_outlined,
              currentPage == DrawerSections.reportes ? true : false),
          menuItem(3, "Mis Tareas", Icons.assignment_outlined,
              currentPage == DrawerSections.tareas ? true : false),
          menuItem(4, "Seleccionar Unidad", Icons.location_city_outlined,
              currentPage == DrawerSections.seleccionarunidad ? true : false),
          const Divider(),
          menuItem(5, "Cerrar Sesión", Icons.logout,
              currentPage == DrawerSections.cerrarsesion ? true : false),
        ],
      ),
    );
  }

  void cerrarSesion(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            if (id == 1) {
              currentPage = DrawerSections.nuevoreporte;
              currentTitle = title; // Actualizar el título
            } else if (id == 2) {
              currentPage = DrawerSections.reportes;
              currentTitle = title;
            } else if (id == 3) {
              currentPage = DrawerSections.tareas;
              currentTitle = title;
            } else if (id == 4) {
              currentPage = DrawerSections.seleccionarunidad;
              currentTitle = title;
            } else if (id == 5) {
              cerrarSesion(context);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawerSections {
  nuevoreporte,
  reportes,
  tareas,
  seleccionarunidad,
  cerrarsesion,
}
