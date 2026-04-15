class Worksite {
  final String id;
  final String name;
  final String location;
  final String? website;

  const Worksite({
    required this.id,
    required this.name,
    required this.location,
    this.website,
  });

  factory Worksite.fromRow(Map<String, dynamic> row) {
    return Worksite(
      id:       row['id']       as String,
      name:     row['name']     as String,
      location: row['location'] as String? ?? '',
      website:  row['website']  as String?,
    );
  }
}
