import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHeaderDrawer extends StatefulWidget {
  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  String userEmail =
      ""; // Variable para almacenar el correo electrónico del usuario
  String userName = ""; // Variable para almacenar el nombre del usuario

  @override
  void initState() {
    super.initState();
    // Obtén el usuario actualmente autenticado
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si el usuario está autenticado, actualiza el correo electrónico del usuario
      setState(() {
        userEmail = user.email ??
            ""; // Obtén el correo electrónico del usuario, si está disponible
        // Extrae el primer nombre del correo electrónico
        userName = userEmail.split('@')[0].split('.')[0].toLowerCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String profileImage =
        'assets/images/perfil1.jpg'; // Perfil predeterminado (hombre)

    // Si el primer nombre del usuario es uno de mujer, usa el perfil 2 (mujer)
    if (_isFemaleName(userName)) {
      profileImage = 'assets/images/perfil2.jpg';
    }

    return Container(
      color: Colors.yellow[700],
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(profileImage),
              ),
            ),
          ),
          Text(
            "Bienvenido, $userName", // Muestra el primer nombre del usuario
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          // Espacio entre el nombre y el correo electrónico
          Text(
            userEmail,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Función para verificar si el nombre es de mujer
  bool _isFemaleName(String name) {
    List<String> femaleNames = [
      'elvia',
      'maría',
      'ana',
      'sandra'
    ]; // Agrega más nombres según sea necesario
    return femaleNames.contains(name.toLowerCase());
  }
}
