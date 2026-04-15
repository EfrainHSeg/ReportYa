class Report {
  Report({
    required this.name,
    required this.time,
    required this.description,
    required this.riskLevel,
    required this.reportedBy,
  });

  final String name;
  final String time;
  final String description;
  final String riskLevel;
  final String reportedBy;

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time,
        'description': description,
        'riskLevel': riskLevel,
        'reportedBy': reportedBy,
      };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        name: json['name'] ?? json['nombre'] ?? '',
        time: json['time'] ?? json['hora'] ?? '',
        description: json['description'] ?? json['descripcion'] ?? '',
        riskLevel: json['riskLevel'] ?? json['nivelRiesgo'] ?? '',
        reportedBy: json['reportedBy'] ?? json['reportadoPor'] ?? '',
      );
}
