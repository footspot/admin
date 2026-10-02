import 'package:fs_sa/data/models/objectbox/club_entity.dart';
import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ClubSubscriptionEntity {
  @Id(assignable: true)
  int id;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  int members;
  int membersLimit;
  double priceMember;

  // Relation to Club entity
  final club = ToOne<ClubEntity>();

  String get createdAtFormat => DateFormat('EEE d MMM yy').format(createdAt);

  String get updatedAtFormat => DateFormat('EEE d MMM yy').format(updatedAt);

  String clubInfos;

  ClubSubscriptionEntity({
    this.id = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.membersLimit,
    required this.priceMember,
    required this.clubInfos,
  });

  // Named constructor for manual instantiation with enum
  ClubSubscriptionEntity.create({
    this.id = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.membersLimit,
    required this.priceMember,
    required this.clubInfos,
  });

  factory ClubSubscriptionEntity.fromJson(Map<String, dynamic> json) {
    final subscription = ClubSubscriptionEntity.create(
      id: json['id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      members: json['members'],
      membersLimit: json['members_limit'],
      priceMember: json['price_member'].toDouble(),
      clubInfos: json['club_infos'],
    );

    // Set the club relation if provided
    if (json['club'] != null) {
      subscription.club.target = ClubEntity.fromJson(json['club']);
    }

    return subscription;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'members': members,
      'members_limit': membersLimit,
      'price_member': priceMember,
      'club_infos': clubInfos,
      'club': club.target?.toJson(),
    };
  }

  static List<ClubSubscriptionEntity> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) =>
              ClubSubscriptionEntity.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
