import 'package:fs_sa/data/models/enums/stock_enum.dart';

class Club {
  final int id;
  final DateTime createdAt;
  final String? name;
  final int clubNumber;
  final String? currentSaison;
  final String? logoPath;
  final StockTypeEnum stockType;

  Club({
    required this.id,
    required this.createdAt,
    this.name,
    required this.clubNumber,
    this.currentSaison,
    this.logoPath,
    required this.stockType,
  });
}
