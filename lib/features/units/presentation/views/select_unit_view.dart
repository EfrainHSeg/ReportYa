import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/units/data/models/worksite.dart';
import 'package:reportya/features/units/presentation/viewmodels/select_unit_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectUnitView extends StatefulWidget {
  const SelectUnitView({super.key});

  @override
  State<SelectUnitView> createState() => _SelectUnitViewState();
}

class _SelectUnitViewState extends State<SelectUnitView> {
  final _vm         = SelectUnitViewModel();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWebsite(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: ListenableBuilder(
              listenable: _vm,
              builder: (context, _) => _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => Container(
          color: AppColors.amarilloCat,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  // Botón atrás
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
                  // Título
                  Expanded(
                    child: Text(
                      'Unidades de trabajo',
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.negro,
                      ),
                    ),
                  ),
                  // Badge conteo
                  if (!_vm.loading && _vm.total > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.negro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_vm.total} unidades',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorde),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: _vm.setSearch,
          style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.negro),
          decoration: InputDecoration(
            hintText: 'Buscar unidad...',
            hintStyle: GoogleFonts.montserrat(
                fontSize: 13, color: AppColors.textoGris),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 18, color: AppColors.textoGris),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_vm.loading) return _buildSkeletons();
    if (_vm.error != null) return _ErrorState(onRetry: _vm.load);
    if (_vm.filtered.isEmpty) return _EmptyState(search: _vm.searchQuery);

    final items = _vm.groupedList;

    return RefreshIndicator(
      color: AppColors.naranjaFerreyros,
      onRefresh: _vm.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];

          // Header de sección
          if (item is String) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(
                item,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoGris,
                  letterSpacing: 1.4,
                ),
              ),
            );
          }

          // Tarjeta de unidad
          final w = item as Worksite;
          final selected = w.id == _vm.selectedId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WorksiteCard(
              worksite: w,
              selected: selected,
              onTap: () => _vm.selectUnit(w.id),
              onWebsite: w.website != null ? () => _openWebsite(w.website!) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _CardSkeleton(),
    );
  }
}

// ── Tarjeta ─────────────────────────────────────
class _WorksiteCard extends StatelessWidget {
  final Worksite worksite;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onWebsite;
  const _WorksiteCard({
    required this.worksite,
    required this.selected,
    required this.onTap,
    this.onWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? AppColors.amarilloCat : AppColors.cardBorde,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Ícono
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.store_mall_directory_rounded,
                color: selected
                    ? AppColors.naranjaFerreyros
                    : const Color(0xFFBDBDBD),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worksite.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.naranjaFerreyros
                          : AppColors.negro,
                    ),
                  ),
                  if (worksite.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.place_rounded,
                          size: 11,
                          color: selected
                              ? AppColors.naranjaFerreyros
                              : AppColors.textoGris),
                      const SizedBox(width: 3),
                      Text(
                        worksite.location,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: selected
                              ? AppColors.naranjaFerreyros
                              : AppColors.textoGris,
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
            // Botón web
            if (onWebsite != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onWebsite,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.amarilloCat
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: selected ? AppColors.negro : AppColors.textoGris,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Estado vacío ────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String search;
  const _EmptyState({required this.search});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.location_city_outlined,
                  size: 34, color: AppColors.textoGris),
            ),
            const SizedBox(height: 16),
            Text(
              search.isNotEmpty
                  ? 'Sin resultados para "$search"'
                  : 'No hay unidades disponibles',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  fontSize: 13, color: AppColors.textoGris),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ─────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 40, color: AppColors.textoGris),
          const SizedBox(height: 12),
          Text('Error al cargar las unidades',
              style: GoogleFonts.montserrat(
                  fontSize: 13, color: AppColors.textoGris)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.negro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Reintentar',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ────────────────────────────────────
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
