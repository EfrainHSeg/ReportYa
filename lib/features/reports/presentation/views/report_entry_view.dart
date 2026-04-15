import 'package:flutter/material.dart';
import 'package:reportya/features/reports/presentation/views/new_report_form_view.dart';

class NewReportEntryView extends StatelessWidget {
  const NewReportEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  builder: (context) => const NewReportFormView(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF3498db),
              minimumSize: const Size(200, 40),
            ),
            child: const Text('Presiona aqui'),
          ),
        ],
      ),
    );
  }
}
