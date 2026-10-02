import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class UserEntity {
  @Id()
  int id; // ObjectBox uses int for id by default, but we'll store UUID as string

  // Original UUID from SQL
  String? uuid;

  String? name;
  String? lastname;
  String? phone;
  String? profilePath;
  String? emailContact;
  String? pseudo;
  String? licenseNumber;
  String? fcmToken;

  int clubId;

  @Property(type: PropertyType.date)
  DateTime createdAt;
  @Property(type: PropertyType.date)
  DateTime updatedAt;
  @Property(type: PropertyType.date)
  DateTime? fcmLastDate;

  String get createdAtFormat => DateFormat('EEE d MMM yy').format(createdAt);

  String get updatedAtFormat => DateFormat('EEE d MMM yy').format(updatedAt);

  String get fcmLastDateFormat =>
      fcmLastDate != null
          ? DateFormat('EEE d MMM yy').format(fcmLastDate!)
          : 'n/c';

  int role;

  UserEntity({
    this.id = 0,
    this.uuid,
    this.name,
    this.lastname,
    this.phone,
    this.profilePath,
    this.emailContact,
    this.pseudo,
    this.licenseNumber = '0',
    this.fcmToken,
    required this.clubId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.fcmLastDate,
    required this.role,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Add fromJson constructor if needed
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uuid: json['id'],
      name: json['name'],
      lastname: json['lastname'],
      phone: json['phone'],
      role: json['role'],
      profilePath: json['profile_path'],
      emailContact: json['email_contact'],
      pseudo: json['pseudo'],
      licenseNumber: json['license_number'] ?? '0',
      fcmToken: json['fcm_token'],
      clubId: json['club_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      fcmLastDate:
          json['fcm_last_date'] != null
              ? DateTime.parse(json['fcm_last_date'])
              : null,
    );
  }

  // Add toJson method if needed
  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'role': role,
      'profile_path': profilePath,
      'email_contact': emailContact,
      'pseudo': pseudo,
      'license_number': licenseNumber,
      'fcm_token': fcmToken,
      'club_id': clubId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'fcm_last_date': fcmLastDate?.toIso8601String(),
    };
  }

  static List<UserEntity> fromJsonList(List<dynamic> jsonList) =>
      jsonList.map((json) => UserEntity.fromJson(json)).toList();
}
