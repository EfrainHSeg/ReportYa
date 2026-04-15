import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/auth/presentation/views/sign_in_view.dart';
import 'package:reportya/features/units/presentation/views/select_unit_view.dart';

class ProfileView extends StatelessWidget {
  final void Function(int index) onNavigate;
  const ProfileView({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final name = user?.displayName ?? email.split('@')[0];
    final photoUrl = user?.photoURL;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header amarillo ──────────────────
          _ProfileHeader(name: name, email: email, photoUrl: photoUrl),

          const SizedBox(height: 8),

          // ── Sección Navegación ───────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(label: 'PRINCIPAL'),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Inicio',
                  iconBg: const Color(0xFFFFF3CD),
                  iconColor: AppColors.naranjaFerreyros,
                  isActive: true,
                  onTap: () => onNavigate(0),
                ),
                _NavItem(
                  icon: Icons.description_rounded,
                  label: 'Mis Reportes',
                  iconBg: const Color(0xFFFFF8E7),
                  iconColor: const Color(0xFFE6A817),
                  onTap: () => onNavigate(1),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estadísticas',
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: AppColors.aprobado,
                  onTap: () => onNavigate(2),
                ),
                _NavItemBadge(
                  icon: Icons.notifications_rounded,
                  label: 'Notificaciones',
                  iconBg: const Color(0xFFEDE7F6),
                  iconColor: const Color(0xFF7C3AED),
                  badge: 3,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                const _SectionLabel(label: 'INFORMACIÓN'),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.location_city_rounded,
                  label: 'Unidades de trabajo',
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectUnitView(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                const _SectionLabel(label: 'CUENTA'),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Perfil',
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFE53935),
                  onTap: () {},
                ),
                _NavItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Cambiar contraseña',
                  iconBg: const Color(0xFFF5F5F5),
                  iconColor: AppColors.textoGrisOscuro,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── Footer ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.naranjaFerreyros,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ferreyros',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.negro,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.negro,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CAT',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ReportYa v1.0.0',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppColors.textoGris,
                  ),
                ),
                const SizedBox(height: 16),

                // Cerrar sesión
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInView()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 14),
                        Text(
                          'Cerrar sesión',
                          style: GoogleFonts.montserrat(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  const _ProfileHeader(
      {required this.name, required this.email, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.amarilloCat,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DiagPainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + punto verde
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.naranjaFerreyros,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: photoUrl != null
                          ? Image.network(photoUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.person_rounded,
                              size: 32, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.aprobado,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.amarilloCat, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nombre
                Text(
                  name,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.negro,
                  ),
                ),
                const SizedBox(height: 2),

                // Email
                Text(
                  email,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.textoGrisOscuro,
                  ),
                ),
                const SizedBox(height: 10),

                // Badge rol
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.negro,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'INSPECTOR DE CAMPO',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item navegación ──────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF8E7) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.naranjaFerreyros : AppColors.negro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Item navegación con badge ─────────────────
class _NavItemBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final int badge;
  final VoidCallback onTap;

  const _NavItemBadge({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.negro,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.naranjaFerreyros,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$badge',
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
    );
  }
}

// ── Label sección ─────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textoGris,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ── Painter diagonal ─────────────────────────
class _DiagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const spacing = 18.0;
    final total = size.width + size.height;
    for (double i = -total; i < total; i += spacing) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
