import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SeleccionarUnidadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Unidad'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          _buildListItem('AESA SAN RAFAEL', 'https://www.aesa.com.pe/'),
          _buildListItem('AESA SAN CRISTOBAL',
              'https://www.rumbominero.com/portada/aesa-gana-nueva-adjudicacion-en-la-unidad-minera-san-cristobal-de-volcan/'),
          _buildListItem('AESA RAURA', 'https://www.aesa.com.pe/'),
          _buildListItem('AESA CERRO LINDO',
              'https://www.cosapi.com.pe/Site/Index.aspx?aID=70'),
          _buildListItem('EL PORVENIR',
              'https://ri.nexaresources.com/operations/el-porvenir/'),
          _buildListItem('PUCAMARCA',
              'https://www.minsur.com/nuestras-operaciones/unidad-minera-pucamarca/'),
          _buildListItem('IMPALA', 'https://www.impalaterminals.com/'),
          _buildListItem('MARCONA COSAPI',
              'https://www.cosapi.com.pe/Site/Index.aspx?aID=905'),
          _buildListItem(
              'CSA CONSTRUCCIÓN', 'https://www.casacontratistas.com/'),
          _buildListItem('UNICON',
              'https://www.unicon.com.pe/contactanos/?gad_source=1&gclid=CjwKCAjwgdayBhBQEiwAXhMxtv-Vcd4BPIaGHkeHasQTqqOE7H7jSxnYUcMSh0JUIsom4_0yT8z67hoCtFgQAvD_BwE'),
          _buildListItem('MARCONA SAN MARTIN',
              'https://sanmartin.com/proyectos/mina-shougang/'),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, String url) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Color de fondo
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(Icons.link), // Icono
            SizedBox(width: 10), // Espacio entre el icono y el texto
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para abrir la URL en el navegador
  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'No se pudo abrir la URL: $url';
      }
    } catch (e) {
      print('Error al abrir la URL: $e');
      // Aquí puedes mostrar un mensaje al usuario indicando que la URL no se pudo abrir
    }
  }
}
