import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/reports/presentation/views/photo_evidence_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewReportFormView extends StatefulWidget {
  const NewReportFormView({super.key});

  @override
  State<NewReportFormView> createState() => _NewReportFormViewState();
}

class _NewReportFormViewState extends State<NewReportFormView> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedAreaId;
  int? _selectedRiskLevelId;

  List<Map<String, dynamic>> _areas = [];
  List<Map<String, dynamic>> _riskLevels = [];
  bool _loading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadCatalogos();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogos() async {
    try {
      final areas =
          await _supabase.from('areas').select().eq('is_active', true);
      final risks =
          await _supabase.from('risk_levels').select().order('sort_order');
      setState(() {
        _areas = List<Map<String, dynamic>>.from(areas);
        _riskLevels = List<Map<String, dynamic>>.from(risks);
        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando catálogos: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAreaId == null || _selectedRiskLevelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona el área y nivel de riesgo')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _supabase.from('reports').insert({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'area_id': _selectedAreaId,
        'risk_level_id': _selectedRiskLevelId,
        'reported_by': uid,
        'status': 'draft',
      });

      final latest = await _supabase
          .from('reports')
          .select('id')
          .eq('reported_by', uid)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (!mounted) return;
      final reportId = latest['id'] as String;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoEvidenceView(reportId: reportId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _formatFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatHora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: _loadingData
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.naranjaFerreyros),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateTimeCard(),
                          const SizedBox(height: 20),
                          _buildSectionLabel('TÍTULO DEL REPORTE'),
                          const SizedBox(height: 8),
                          _buildTitleField(),
                          const SizedBox(height: 16),
                          _buildSectionLabel('DESCRIPCIÓN'),
                          const SizedBox(height: 8),
                          _buildDescField(),
                          const SizedBox(height: 20),
                          _buildSectionLabel('ÁREA'),
                          const SizedBox(height: 10),
                          _buildAreasGrid(),
                          const SizedBox(height: 20),
                          _buildSectionLabel('NIVEL DE RIESGO'),
                          const SizedBox(height: 10),
                          _buildRiskChips(),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSubmitButton(),
              ],
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
                      'Nuevo reporte',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.negro,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Paso 1 de 3',
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
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.negro.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.negro.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.negro.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
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

  Widget _buildDateTimeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 16, color: AppColors.naranjaFerreyros),
          const SizedBox(width: 8),
          Text(
            _formatFecha(DateTime.now()),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.negro,
            ),
          ),
          const Spacer(),
          Container(width: 1, height: 18, color: const Color(0xFFEEEEEE)),
          const Spacer(),
          const Icon(Icons.access_time_rounded,
              size: 16, color: AppColors.naranjaFerreyros),
          const SizedBox(width: 8),
          Text(
            _formatHora(DateTime.now()),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.negro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
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

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.negro),
      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
      decoration: _inputDecoration('Ej: Inspección equipo CAT 793'),
    );
  }

  Widget _buildDescField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.negro),
      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
      decoration: _inputDecoration('Describe qué ocurrió...'),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(
          fontSize: 14, color: AppColors.textoGris),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.naranjaFerreyros, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.rechazado),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.rechazado, width: 1.8),
      ),
    );
  }

  Widget _buildAreasGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: _areas.map((a) {
        final id = a['id'].toString();
        final isSelected = _selectedAreaId == id;
        final code = (a['code'] as String?) ?? '';
        return GestureDetector(
          onTap: () => setState(() => _selectedAreaId = id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected
                    ? AppColors.amarilloCat
                    : const Color(0xFFEEEEEE),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _areaColor(code).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_areaIcon(code),
                      size: 20, color: _areaColor(code)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        code,
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoGris,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        a['name'],
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.negro,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.amarilloCat,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 13, color: AppColors.negro),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRiskChips() {
    return Row(
      children: List.generate(_riskLevels.length, (i) {
        final r = _riskLevels[i];
        final id = r['id'] as int;
        final isSelected = _selectedRiskLevelId == id;
        final color = _hexColor(r['color_hex'] as String);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRiskLevelId = id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: i < _riskLevels.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.12)
                    : Colors.white,
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFEEEEEE),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (r['label'] as String).toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? color : AppColors.negro,
                    ),
                  ),
                  Text(
                    r['code'] as String,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      color: AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: const Color(0xFFF7F7F7),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amarilloCat,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _loading
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
                      'Crear reporte',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.negro,
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.naranjaFerreyros,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _areaIcon(String code) => switch (code) {
        'MINA' => Icons.terrain_rounded,
        'TALLER' => Icons.build_rounded,
        'CAMPO' => Icons.grass_rounded,
        'PLANTA' => Icons.factory_rounded,
        _ => Icons.location_on_rounded,
      };

  Color _areaColor(String code) => switch (code) {
        'MINA' => AppColors.amarilloCat,
        'TALLER' => const Color(0xFF6366F1),
        'CAMPO' => const Color(0xFF16A34A),
        'PLANTA' => AppColors.naranjaFerreyros,
        _ => AppColors.textoGris,
      };
}
