import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawerHeader extends StatefulWidget {
  const AppDrawerHeader({super.key});

  @override
  State<AppDrawerHeader> createState() => _AppDrawerHeaderState();
}

class _AppDrawerHeaderState extends State<AppDrawerHeader> {
  String userEmail = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
        userName = userEmail.split('@')[0].split('.')[0].toLowerCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var profileImage = 'assets/avatars/perfil1.jpg';
    if (_isFemaleName(userName)) {
      profileImage = 'assets/avatars/perfil2.jpg';
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
            'Bienvenido, $userName',
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
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

  bool _isFemaleName(String name) {
    const femaleNames = ['elvia', 'maria', 'ana', 'sandra'];
    return femaleNames.contains(name.toLowerCase());
  }
}
