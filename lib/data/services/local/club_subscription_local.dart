import 'package:fs_sa/data/models/objectbox/club_sub_entity.dart';
import 'package:fs_sa/data/services/object_box_service.dart';
import 'package:fs_sa/objectbox.g.dart';

class ClubSubscriptionRepository {
  final ObjectBoxService _objectBoxService = ObjectBoxService.instance;

  Box<ClubSubscriptionEntity> get _box => _objectBoxService.clubSubscriptionBox;

  /// Save a club subscription
  Future<int> save(ClubSubscriptionEntity clubSubscription) async {
    return _box.put(clubSubscription);
  }

  /// Save multiple club subscriptions
  Future<List<int>> saveAll(
    List<ClubSubscriptionEntity> clubSubscriptions,
  ) async {
    return _box.putMany(clubSubscriptions);
  }

  /// Get a club subscription by ID
  Future<ClubSubscriptionEntity?> getById(int id) async {
    return _box.get(id);
  }

  /// Get all club subscriptions
  Future<List<ClubSubscriptionEntity>> getAll() async {
    return _box.getAll();
  }

  /// Get club subscriptions by club relation
  Future<List<ClubSubscriptionEntity>> getByClubId(int clubId) async {
    final query =
        _box.query(ClubSubscriptionEntity_.club.equals(clubId)).build();
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Search club subscriptions by name (case-insensitive)
  // Future<List<ClubSubscriptionEntity>> searchByName(String name) async {
  //   final query =
  //       _box
  //           .query(
  //             ClubSubscriptionEntity_.club.n.contains(
  //               name,
  //               caseSensitive: false,
  //             ),
  //           )
  //           .build();
  //   final entities = query.find();
  //   query.close();
  //   return entities;
  // }

  /// Get club subscriptions with member count greater than specified value
  Future<List<ClubSubscriptionEntity>> getByMinMembers(int minMembers) async {
    final query =
        _box
            .query(ClubSubscriptionEntity_.members.greaterThan(minMembers))
            .build();
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Get club subscriptions within price range
  Future<List<ClubSubscriptionEntity>> getByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    final query =
        _box
            .query(
              ClubSubscriptionEntity_.priceMember.between(minPrice, maxPrice),
            )
            .build();
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Update a club subscription
  Future<void> update(ClubSubscriptionEntity clubSubscription) async {
    _box.put(clubSubscription);
  }

  /// Delete a club subscription by ID
  Future<bool> deleteById(int id) async {
    return _box.remove(id);
  }

  /// Delete multiple club subscriptions by IDs
  Future<void> deleteByIds(List<int> ids) async {
    _box.removeMany(ids);
  }

  /// Delete all club subscriptions
  Future<void> deleteAll() async {
    _box.removeAll();
  }

  /// Count total club subscriptions
  Future<int> count() async {
    return _box.count();
  }

  /// Check if a club subscription exists by ID
  Future<bool> exists(int id) async {
    return _box.get(id) != null;
  }

  /// Get club subscriptions with pagination
  Future<List<ClubSubscriptionEntity>> getPaginated({
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

  /// Get the most recent club subscriptions
  Future<List<ClubSubscriptionEntity>> getMostRecent({int limit = 10}) async {
    final query =
        _box
            .query()
            .order(ClubSubscriptionEntity_.createdAt, flags: Order.descending)
            .build();
    query.limit = limit;
    final entities = query.find();
    query.close();
    return entities;
  }

  /// Stream all club subscriptions (reactive updates)
  Stream<List<ClubSubscriptionEntity>> watchAll() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  /// Stream club subscriptions by club ID (reactive updates)
  Stream<List<ClubSubscriptionEntity>> watchByClubId(int clubId) {
    return _box
        .query(ClubSubscriptionEntity_.club.equals(clubId))
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
}
