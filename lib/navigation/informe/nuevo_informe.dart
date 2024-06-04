import 'package:flutter/material.dart';
import 'package:reportya/navigation/informe/agregar_evidencia.dart';

class NuevoInforme extends StatefulWidget {
  final Function(Map<String, String>) onFormSubmit;

  NuevoInforme({required this.onFormSubmit});

  @override
  _NuevoInformeState createState() => _NuevoInformeState();
}

class _NuevoInformeState extends State<NuevoInforme> {
  final TextEditingController _ocurrioController = TextEditingController();
  final TextEditingController _reportadoPorController = TextEditingController();
  final TextEditingController _evidenciaController = TextEditingController();
  String _riesgoSeleccionado = '';
  String _sistemaSeleccionado = '';

  @override
  void dispose() {
    _ocurrioController.dispose();
    _reportadoPorController.dispose();
    _evidenciaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final formData = {
      'fecha': DateTime.now().toString().substring(0, 10),
      'hora': DateTime.now().toString().substring(11, 16),
      'ocurrio': _ocurrioController.text,
      'riesgo': _riesgoSeleccionado,
      'sistema': _sistemaSeleccionado,
      'reportadoPor': _reportadoPorController.text,
    };
    widget.onFormSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Nuevo Informe'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black),
                const SizedBox(width: 10),
                Text(
                  'Fecha: ${DateTime.now().toString().substring(0, 10)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.access_time, color: Colors.black),
                const SizedBox(width: 10),
                Text(
                  'Hora: ${DateTime.now().toString().substring(11, 16)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              '¿Qué ocurrió?',
              _ocurrioController,
              Icons.report_problem,
            ),
            const SizedBox(height: 20),
            _buildPicker(
              'Nivel de Riesgo',
              _riesgoSeleccionado,
              ['Bajo', 'Medio', 'Alto'],
              (value) => setState(() => _riesgoSeleccionado = value!),
              Icons.warning,
            ),
            const SizedBox(height: 20),
            _buildPicker(
              'Sistema',
              _sistemaSeleccionado,
              ['Campo', 'Taller'],
              (value) => setState(() => _sistemaSeleccionado = value!),
              Icons.build,
            ),
            const SizedBox(height: 20),
            _buildEvidenciaButton(),
            const SizedBox(height: 20),
            _buildTextField(
              'Reportado por',
              _reportadoPorController,
              Icons.person,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildEvidenciaButton() {
    return ElevatedButton.icon(
      onPressed: () {
        final formData = {
          'fecha': DateTime.now().toString().substring(0, 10),
          'hora': DateTime.now().toString().substring(11, 16),
          'ocurrio': _ocurrioController.text,
          'riesgo': _riesgoSeleccionado,
          'sistema': _sistemaSeleccionado,
          'reportadoPor': _reportadoPorController.text,
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EvidenciaPage(formData: formData),
          ),
        );
      },
      icon: const Icon(Icons.photo),
      label: const Text('Agregar Evidencia'),
    );
  }

  Widget _buildPicker(String label, String value, List<String> options,
      Function(String?) onChanged, IconData icon) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      onChanged: onChanged,
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
