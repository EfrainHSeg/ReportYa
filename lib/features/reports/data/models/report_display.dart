class ReportDisplay {
  final String id;
  final String title;
  final String area;
  final String areaCode;
  final String riskLabel;
  final String riskColorHex;
  final String status;
  final DateTime createdAt;
  final int imageCount;
  final List<String> imageUrls;

  const ReportDisplay({
    required this.id,
    required this.title,
    required this.area,
    required this.areaCode,
    required this.riskLabel,
    required this.riskColorHex,
    required this.status,
    required this.createdAt,
    required this.imageCount,
    required this.imageUrls,
  });

  factory ReportDisplay.fromRow(Map<String, dynamic> row) {
    final area   = row['areas']        as Map<String, dynamic>? ?? {};
    final risk   = row['risk_levels']  as Map<String, dynamic>? ?? {};
    final images = row['report_images'] as List? ?? [];
    return ReportDisplay(
      id:           row['id']     as String,
      title:        row['title']  as String? ?? 'Sin título',
      area:         area['name']  as String? ?? '',
      areaCode:     area['code']  as String? ?? '',
      riskLabel:    risk['label'] as String? ?? '',
      riskColorHex: risk['color_hex'] as String? ?? '#F59E0B',
      status:       row['status'] as String? ?? 'draft',
      createdAt:    DateTime.parse(row['created_at'] as String).toLocal(),
      imageCount:   images.length,
      imageUrls:    images
          .take(3)
          .map((i) => i['url'] as String? ?? '')
          .where((u) => u.isNotEmpty)
          .toList(),
    );
  }
}
