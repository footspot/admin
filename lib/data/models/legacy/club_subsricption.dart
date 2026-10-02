import 'package:fs_sa/data/models/enums/stock_enum.dart';
import 'package:fs_sa/data/models/legacy/club.dart';

class ClubSubscription {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int members;
  final Club club;
  final int membersLimit;
  final double priceMember;
  final String? clubName;
  final int? clubNumber;
  final String? logoPath;
  final String? rulesPath;
  final String? ppmail;
  final StockTypeEnum stockType;
  final int? sid;

  ClubSubscription({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.club,
    required this.membersLimit,
    required this.priceMember,
    required this.stockType,

    this.clubName,
    this.clubNumber,
    this.logoPath,
    this.rulesPath,
    this.ppmail,
    this.sid,
  });
}
