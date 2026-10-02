import 'package:fs_sa/data/models/objectbox/club_entity.dart';
import 'package:fs_sa/data/services/object_box_service.dart';
import 'package:fs_sa/objectbox.g.dart';

class ClubRepository {
  final ObjectBoxService _objectBoxService = ObjectBoxService.instance;

  Box<ClubEntity> get _box => _objectBoxService.clubBox;

  /// Save a club
  Future<int> save(ClubEntity club) async {
    return _box.put(club);
  }

  /// Save multiple clubs
  Future<List<int>> saveAll(List<ClubEntity> clubs) async {
    return _box.putMany(clubs);
  }

  /// Get a club by ID
  Future<ClubEntity?> getById(int id) async {
    return _box.get(id);
  }

  /// Get all clubs
  Future<List<ClubEntity>> getAll() async {
    return _box.getAll();
  }

  /// Get a club by club number (unique)
  Future<ClubEntity?> getByClubNumber(int clubNumber) async {
    final query = _box.query(ClubEntity_.clubNumber.equals(clubNumber)).build();
    final entity = query.findFirst();
    query.close();
    return entity;
  }

  /// Get clubs by stock type
  // Future<List<ClubEntity>> getByStockType(StockTypeEnum stockType) async {
  //   final query = _box
  //       .query(ClubEntity_._stockType.equals(stockType.index))
  //       .build();
  //   final entities = query.find();
  //   query.close();
  //   return entities;
  // }

  /// Search clubs by name (case-insensitive)
  Future<List<ClubEntity>> searchByName(String name) async {
    final query =
        _box
            .query(ClubEntity_.name.contains(name, caseSensitive: false))
            .build();
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Get clubs created after a specific date
  Future<List<ClubEntity>> getCreatedAfter(DateTime date) async {
    final query =
        _box
            .query(
              ClubEntity_.createdAt.greaterThan(date.millisecondsSinceEpoch),
            )
            .build();
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Get clubs created between two dates
  Future<List<ClubEntity>> getCreatedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query =
        _box
            .query(
              ClubEntity_.createdAt.between(
                startDate.millisecondsSinceEpoch,
                endDate.millisecondsSinceEpoch,
              ),
            )
            .build();
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Update a club
  Future<void> update(ClubEntity club) async {
    _box.put(club);
  }

  /// Delete a club by ID
  Future<bool> deleteById(int id) async {
    return _box.remove(id);
  }

  /// Delete a club by club number
  Future<bool> deleteByClubNumber(int clubNumber) async {
    final club = await getByClubNumber(clubNumber);
    if (club != null) {
      return _box.remove(club.id);
    }
    return false;
  }

  /// Delete multiple clubs by IDs
  Future<void> deleteByIds(List<int> ids) async {
    _box.removeMany(ids);
  }

  /// Delete all clubs
  Future<void> deleteAll() async {
    _box.removeAll();
  }

  /// Count total clubs
  Future<int> count() async {
    return _box.count();
  }

  /// Count clubs by stock type
  // Future<int> countByStockType(StockTypeEnum stockType) async {
  //   final query = _box
  //       .query(ClubEntity_._stockType.equals(stockType.index))
  //       .build();
  //   final count = query.count();
  //   query.close();
  //   return count;
  // }

  /// Check if a club exists by ID
  Future<bool> exists(int id) async {
    return _box.get(id) != null;
  }

  /// Check if a club exists by club number
  Future<bool> existsByClubNumber(int clubNumber) async {
    final club = await getByClubNumber(clubNumber);
    return club != null;
  }

  /// Get clubs with pagination
  Future<List<ClubEntity>> getPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    final query = _box.query().build();
    query.offset = offset;
    query.limit = limit;
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Get the most recent clubs
  Future<List<ClubEntity>> getMostRecent({int limit = 10}) async {
    final query =
        _box
            .query()
            .order(ClubEntity_.createdAt, flags: Order.descending)
            .build();
    query.limit = limit;
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Get clubs ordered by name
  Future<List<ClubEntity>> getOrderedByName({bool ascending = true}) async {
    final query =
        _box
            .query()
            .order(ClubEntity_.name, flags: ascending ? 0 : Order.descending)
            .build();
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Stream all clubs (reactive updates)
  Stream<List<ClubEntity>> watchAll() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  /// Stream clubs by stock type (reactive updates)
  // Stream<List<ClubEntity>> watchByStockType(StockTypeEnum stockType) {
  //   return _box
  //       .query(ClubEntity_._stockType.equals(stockType.index))
  //       .watch(triggerImmediately: true)
  //       .map((query) => query.find());
  // }

  /// Stream search results by name (reactive updates)
  Stream<List<ClubEntity>> watchSearchByName(String name) {
    return _box
        .query(ClubEntity_.name.contains(name, caseSensitive: false))
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
}
