// * Plain Dart model for an Intersport regional partner.
// * Mirrors public.intersport_partners (Footspot Supabase project), with the
// * computed linked_clubs_count returned by intersport-pdg-list-partners.
class IntersportPartner {
  final String id;
  final String name;
  final String region;
  final String baseUrl;
  final String shopUrlPrefix;
  final String status;
  final DateTime registeredAt;
  final DateTime? suspendedAt;
  final int linkedClubsCount;

  IntersportPartner({
    required this.id,
    required this.name,
    required this.region,
    required this.baseUrl,
    required this.shopUrlPrefix,
    required this.status,
    required this.registeredAt,
    this.suspendedAt,
    this.linkedClubsCount = 0,
  });

  bool get isActive => status == 'active';

  factory IntersportPartner.fromJson(Map<String, dynamic> json) {
    return IntersportPartner(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      baseUrl: json['base_url'] as String,
      shopUrlPrefix: json['shop_url_prefix'] as String,
      status: json['status'] as String,
      registeredAt: DateTime.parse(json['registered_at'] as String),
      suspendedAt:
          json['suspended_at'] == null
              ? null
              : DateTime.parse(json['suspended_at'] as String),
      linkedClubsCount: (json['linked_clubs_count'] as num?)?.toInt() ?? 0,
    );
  }
}
