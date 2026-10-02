import 'package:fs_sa/data/models/objectbox/address_entity.dart';
import 'package:fs_sa/data/models/objectbox/club_entity.dart';
import 'package:fs_sa/data/models/objectbox/club_sub_entity.dart';
import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/models/objectbox/user_entity.dart';
import 'package:fs_sa/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final objbox = ObjectBoxService.instance;

class ObjectBoxService {
  static ObjectBoxService? _instance;
  static ObjectBoxService get instance {
    _instance ??= ObjectBoxService._internal();
    return _instance!;
  }

  ObjectBoxService._internal();

  late Store _store;
  Store get store => _store;

  // Boxes for your entities
  late Box<ClubSubscriptionEntity> clubSubscriptionBox;
  late Box<ClubEntity> clubBox;
  late Box<UserEntity> userBox;
  late Box<AddressEntity> addressBox;
  late Box<LogEntity> logBox;

  /// Initialize ObjectBox database
  Future<void> initialize() async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'objectbox');

    // Create the store
    _store = await openStore(directory: dbPath);

    // Initialize boxes
    clubBox = store.box<ClubEntity>();
    clubSubscriptionBox = _store.box<ClubSubscriptionEntity>();
    addressBox = _store.box<AddressEntity>();
    logBox = _store.box<LogEntity>();
    userBox = _store.box<UserEntity>();
  }

  /// Close the database
  void close() {
    _store.close();
  }

  /// Clear all data (useful for testing or reset functionality)
  void clearAllData() {
    clubSubscriptionBox.removeAll();
    clubBox.removeAll();
    userBox.removeAll();
    addressBox.removeAll();
    logBox.removeAll();
  }
}
