import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/dashboard/presentation/views/home_view.dart';
import 'package:reportya/features/dashboard/presentation/views/profile_view.dart';
import 'package:reportya/features/dashboard/presentation/views/stats_view.dart';
import 'package:reportya/features/reports/presentation/views/my_reports_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const HomeView(),
    const MyReportsView(),
    const StatsView(),
    ProfileView(onNavigate: (i) => setState(() => _currentIndex = i)),
  ];

  final List<String> _titles = const [
    'Inicio',
    'Reportes',
    'Estadísticas',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoBlanco,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _DashboardAppBar(
          currentIndex: _currentIndex,
          titles: _titles,
        ),
      ),
      body: SafeArea(
        top: false,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.naranjaFerreyros,
        unselectedItemColor: AppColors.textoGris,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ── AppBar personalizado ─────────────────────
class _DashboardAppBar extends StatelessWidget {
  final int currentIndex;
  final List<String> titles;

  const _DashboardAppBar({
    required this.currentIndex,
    required this.titles,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final top      = MediaQuery.of(context).padding.top;
    final user     = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final fullName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario';
    // Solo nombre + primer apellido
    final parts    = fullName.trim().split(RegExp(r'\s+'));
    final name     = parts.length >= 2 ? '${parts[0]} ${parts[1]}' : fullName;

    return Container(
      color: AppColors.amarilloCat,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, top + 10, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.negro,
                borderRadius: BorderRadius.circular(9),
              ),
              child: CustomPaint(painter: _ChartIconPainter()),
            ),
            const SizedBox(width: 8),
            // "ReportYa"
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Report',
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.negro),
                ),
                TextSpan(
                  text: 'Ya',
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.naranjaFerreyros),
                ),
              ]),
            ),
            const Spacer(),
            // Campana
            Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.negro.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      size: 20, color: AppColors.negro),
                ),
                Positioned(
                  top: 7, right: 7,
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.naranjaFerreyros,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.amarilloCat, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Avatar con iniciales
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.naranjaFerreyros,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl != null
                  ? Image.network(photoUrl, fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        _initials(name),
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painter: ícono gráfico de barras ──────────
class _ChartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double sx(double x) => x / 1024 * w;
    double sy(double y) => y / 1024 * h;

    final yellow = Paint()
      ..color = AppColors.amarilloCat
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(sx(130), sy(520), sx(185), sy(330)), const Radius.circular(3)), yellow);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(sx(420), sy(310), sx(185), sy(540)), const Radius.circular(3)), yellow);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(sx(710), sy(430), sx(185), sy(420)), const Radius.circular(3)), yellow);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(sx(100), sy(870), sx(824), sy(52)), const Radius.circular(3)), yellow);

    final line = Paint()
      ..color = AppColors.naranjaFerreyros
      ..strokeWidth = sx(50)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(sx(222), sy(460))
      ..lineTo(sx(512), sy(240))
      ..lineTo(sx(800), sy(390));
    canvas.drawPath(path, line);

    canvas.drawCircle(Offset(sx(222), sy(460)), sx(55),
        Paint()..color = AppColors.naranjaFerreyros);
    canvas.drawCircle(Offset(sx(512), sy(240)), sx(70),
        Paint()..color = AppColors.negro);
    canvas.drawCircle(Offset(sx(512), sy(240)), sx(70),
        Paint()
          ..color = AppColors.naranjaFerreyros
          ..style = PaintingStyle.stroke
          ..strokeWidth = sx(50));
    canvas.drawCircle(Offset(sx(800), sy(390)), sx(55),
        Paint()..color = AppColors.naranjaFerreyros);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

