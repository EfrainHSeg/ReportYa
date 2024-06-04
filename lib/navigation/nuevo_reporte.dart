import 'package:flutter/material.dart';
import 'package:reportya/navigation/informe/nuevo_informe.dart';

class NuevoReportePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Para crear un nuevo informe:',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 18,
                fontFamily: 'Arial',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NuevoInforme(
                      onFormSubmit: (formData) {
                        // Aquí puedes manejar los datos del formulario
                        print(formData);
                      },
                    ),
                  ),
                );
                // Lógica para manejar el clic del botón
                // Por ejemplo, navegar a la página de creación de informe
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF3498db), // Texto del botón
                minimumSize: const Size(200, 40), // Tamaño mínimo del botón
              ),
              child: const Text('Presione aquí'),
            ),
          ],
        ),
      ),
    );
  }
}
