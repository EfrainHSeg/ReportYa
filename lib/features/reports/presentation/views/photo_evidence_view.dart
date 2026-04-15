import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/core/utils/app_logger.dart';
import 'package:reportya/features/reports/presentation/views/report_success_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoEvidenceView extends StatefulWidget {
  final String reportId;
  const PhotoEvidenceView({super.key, required this.reportId});

  @override
  State<PhotoEvidenceView> createState() => _PhotoEvidenceViewState();
}

class _PhotoEvidenceViewState extends State<PhotoEvidenceView> {
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;
  final List<File> _images = [];
  bool _uploading = false;
  bool _uploadSuccess = false;
  static const int _maxPhotos = 5;

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 5 fotos permitidas'),
        ),
      );
      return;
    }
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked != null) {
      logger.d('Foto seleccionada: ${picked.path}');
      setState(() {
        _images.add(File(picked.path));
        _uploadSuccess = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _uploadSuccess = false;
    });
  }

  Future<void> _upload() async {
    if (_images.isEmpty) {
      _goToDashboard();
      return;
    }

    setState(() => _uploading = true);

    try {
      logger.i('Iniciando subida de ${_images.length} fotos — reportId: ${widget.reportId}');

      for (final file in _images) {
        final fileName =
            '${widget.reportId}/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

        logger.d('Subiendo: $fileName');
        final bytes = await file.readAsBytes();
        await _supabase.storage
            .from('report-images')
            .uploadBinary(fileName, bytes);

        final url = _supabase.storage
            .from('report-images')
            .getPublicUrl(fileName);

        logger.d('URL pública: $url');
        await _supabase.from('report_images').insert({
          'report_id': widget.reportId,
          'storage_path': fileName,
          'url': url,
        });
        logger.i('Foto guardada en BD');
      }

      await _supabase
          .from('reports')
          .update({'status': 'submitted'})
          .eq('id', widget.reportId);
      logger.i('Status actualizado a submitted');

      if (!mounted) return;
      logger.i('Todas las fotos subidas correctamente');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReportSuccessView(reportId: widget.reportId),
        ),
      );
    } catch (e, stack) {
      logger.e('Error subiendo fotos', error: e, stackTrace: stack);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error subiendo fotos: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _goToDashboard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Banner éxito ──
                  if (_uploadSuccess)
                    _SuccessBanner(count: _images.length),

                  // ── Grid de fotos ──
                  if (_images.isNotEmpty) ...[
                    _sectionLabel('FOTOS DE EVIDENCIA'),
                    const SizedBox(height: 10),
                    _buildPhotoGrid(),
                    const SizedBox(height: 12),
                    _buildCounter(),
                    const SizedBox(height: 20),
                  ],

                  // ── Botones cámara / galería ──
                  _sectionLabel('AGREGAR FOTOS'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _SourceButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Cámara',
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SourceButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Galería',
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final items = <Widget>[
      ...List.generate(
        _images.length,
        (i) => _PhotoThumb(
          file: _images[i],
          onRemove: () => _removeImage(i),
        ),
      ),
      if (_images.length < _maxPhotos)
        _AddMoreButton(
          onTap: () => _pickImage(ImageSource.gallery),
        ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: items,
    );
  }

  Widget _buildCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            'Fotos agregadas',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppColors.textoGris,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_images.length}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.naranjaFerreyros,
                  ),
                ),
                TextSpan(
                  text: ' / $_maxPhotos',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textoGris,
        letterSpacing: 1.4,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: AppColors.amarilloCat,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.negro, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Agregar evidencia',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.negro,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Paso 2 de 3',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.negro.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _progressBar(1.0),
                    const SizedBox(width: 4),
                    _progressBar(1.0),
                    const SizedBox(width: 4),
                    _progressBar(0.2),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(double opacity) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.negro.withValues(alpha: opacity * 0.7),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: const Color(0xFFF7F7F7),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _uploading ? null : _upload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amarilloCat,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _uploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.negro),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Continuar',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.negro,
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.naranjaFerreyros,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner éxito ──────────────────────────────
class _SuccessBanner extends StatelessWidget {
  final int count;
  const _SuccessBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.aprobadoFondo,
        border: Border.all(color: AppColors.aprobado.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.aprobado, size: 20),
          const SizedBox(width: 10),
          Text(
            '$count foto${count > 1 ? 's' : ''} agregada${count > 1 ? 's' : ''} correctamente',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.aprobado,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Miniatura foto ────────────────────────────
class _PhotoThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _PhotoThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.rechazado,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Botón agregar más ─────────────────────────
class _AddMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: AppColors.cardBorde,
              style: BorderStyle.solid,
              width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded,
                size: 24, color: AppColors.textoGris.withValues(alpha: 0.6)),
            const SizedBox(height: 4),
            Text(
              'Agregar',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textoGris,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botón fuente (cámara / galería) ───────────
class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorde),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.naranjaFerreyros),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.negro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
