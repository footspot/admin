// * Flow-1 integration request, hydrated by intersport-pdg-list-pending-requests
// * (status='pending') or intersport-pdg-list-history (status accepted/rejected)
// * with embedded partner / club / requester objects (PostgREST embeds).
// * The processed-state fields (status, processedAt, rejectedReason) are only
// * populated by the history endpoint; they stay null for pending requests.
class IntersportPendingRequest {
  final int id;
  final int clubId;
  final String intersportClubId;
  final String intersportClubName;
  final DateTime requestedAt;

  // * Optional enrichment fields (backend being enriched) — may be null.
  final String? intersportClubLogoUrl;
  final String? shopUrl;

  // * Only set by the history endpoint.
  final String? status;
  final DateTime? processedAt;
  final String? rejectedReason;

  final PartnerBrief? partner;
  final ClubBrief? club;
  final RequesterBrief? requester;

  IntersportPendingRequest({
    required this.id,
    required this.clubId,
    required this.intersportClubId,
    required this.intersportClubName,
    required this.requestedAt,
    this.intersportClubLogoUrl,
    this.shopUrl,
    this.status,
    this.processedAt,
    this.rejectedReason,
    this.partner,
    this.club,
    this.requester,
  });

  factory IntersportPendingRequest.fromJson(Map<String, dynamic> json) {
    return IntersportPendingRequest(
      id: (json['id'] as num).toInt(),
      clubId: (json['club_id'] as num).toInt(),
      intersportClubId: json['intersport_club_id'] as String,
      intersportClubName: json['intersport_club_name'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      intersportClubLogoUrl: json['intersport_club_logo_url'] as String?,
      shopUrl: json['shop_url'] as String?,
      status: json['status'] as String?,
      processedAt:
          json['processed_at'] == null
              ? null
              : DateTime.parse(json['processed_at'] as String),
      rejectedReason: json['rejected_reason'] as String?,
      partner:
          json['partner'] == null
              ? null
              : PartnerBrief.fromJson(json['partner'] as Map<String, dynamic>),
      club:
          json['club'] == null
              ? null
              : ClubBrief.fromJson(json['club'] as Map<String, dynamic>),
      requester:
          json['requester'] == null
              ? null
              : RequesterBrief.fromJson(
                json['requester'] as Map<String, dynamic>,
              ),
    );
  }
}

class PartnerBrief {
  final String id;
  final String name;
  final String region;

  PartnerBrief({required this.id, required this.name, required this.region});

  factory PartnerBrief.fromJson(Map<String, dynamic> json) {
    return PartnerBrief(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
    );
  }
}

class ClubBrief {
  final int id;
  final String name;

  // * Optional enrichment fields — may be null.
  final String? logoPath;
  final String? clubNumber;
  final String? city;
  final String? zipCode;

  ClubBrief({
    required this.id,
    required this.name,
    this.logoPath,
    this.clubNumber,
    this.city,
    this.zipCode,
  });

  factory ClubBrief.fromJson(Map<String, dynamic> json) {
    return ClubBrief(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      logoPath: json['logo_path'] as String?,
      // * club_number may arrive as int or string depending on the source.
      clubNumber: json['club_number']?.toString(),
      city: json['city'] as String?,
      zipCode: json['zip_code']?.toString(),
    );
  }
}

class RequesterBrief {
  final String id;
  final String? name;
  final String? lastname;
  final String? email;
  final String? phone;

  RequesterBrief({
    required this.id,
    this.name,
    this.lastname,
    this.email,
    this.phone,
  });

  factory RequesterBrief.fromJson(Map<String, dynamic> json) {
    return RequesterBrief(
      id: json['id'] as String,
      name: json['name'] as String?,
      lastname: json['lastname'] as String?,
      email: json['email_contact'] as String?,
      phone: json['phone'] as String?,
    );
  }

  String get displayName {
    final full = [name, lastname].where((s) => s != null && s.isNotEmpty).join(' ');
    if (full.isNotEmpty) return full;
    return email ?? '—';
  }
}
