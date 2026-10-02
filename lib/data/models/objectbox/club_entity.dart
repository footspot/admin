import 'package:fs_sa/data/models/enums/stock_enum.dart';
import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ClubEntity {
  @Id(assignable: true)
  int id;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  String? name;

  @Unique()
  int clubNumber;

  String? logoPath;
  int? sid;
  String? ppmail;

  String get dateCreatedFormat =>
      DateFormat('dd.MM.yy HH:mm:ss').format(createdAt);

  String get dateUpdatedFormat =>
      DateFormat('dd.MM.yy HH:mm:ss').format(updatedAt);

  // ObjectBox doesn't directly support enums, so we store as int
  int _stockType;

  @Transient()
  StockTypeEnum get stockType {
    return StockTypeEnum.values[_stockType];
  }

  set stockType(StockTypeEnum value) {
    if (!StockTypeEnum.values.contains(value))
      _stockType = StockTypeEnum.unknown.index;
    else
      _stockType = value.index;
  }

  // Default constructor for ObjectBox (only uses persisted fields)
  ClubEntity({
    this.id = 0,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    required this.clubNumber,
    this.logoPath,
    this.ppmail,
    this.sid,
    int stockType = 0, // Use int directly for ObjectBox
  }) : _stockType = stockType;

  // Named constructor for manual instantiation with enum
  ClubEntity.create({
    this.id = 0,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    required this.clubNumber,
    this.logoPath,
    this.ppmail,
    this.sid,
    required StockTypeEnum stockType,
  }) : _stockType = stockType.index;

  factory ClubEntity.fromJson(Map<String, dynamic> json) {
    return ClubEntity.create(
      id: json['id'] ?? 0,
      name: json['name'],
      logoPath: json['logo_path'],
      clubNumber: json['club_number'],
      stockType: StockTypeEnum.values.firstWhere(
        (e) => e.name == json['stock_type'],
        orElse: () => StockTypeEnum.unknown,
      ),
      ppmail: json['ppmail'],
      sid: json['sid'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_path': logoPath,
      'club_number': clubNumber,
      'ppmail': ppmail,
      'sid': sid,
      'stock_type': StockTypeEnum.values[_stockType].index,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
