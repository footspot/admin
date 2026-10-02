import 'package:fs_sa/data/models/objectbox/user_entity.dart';
import 'package:fs_sa/data/services/object_box_service.dart';
import 'package:fs_sa/objectbox.g.dart';

final userLocal = UserRepository();

class UserRepository {
  final ObjectBoxService _objectBoxService = ObjectBoxService.instance;

  Box<UserEntity> get _box => _objectBoxService.userBox;

  // Create a new user
  int addUser(UserEntity user) {
    return _box.put(user);
  }

  // Get a user by ObjectBox ID
  UserEntity? getUser(int id) {
    return _box.get(id);
  }

  // Get a user by UUID (original SQL ID)
  UserEntity? getUserByUuid(String uuid) {
    final query = _box.query(UserEntity_.uuid.equals(uuid)).build();
    final user = query.findFirst();
    query.close();
    return user;
  }

  // Update a user
  int updateUser(UserEntity user) {
    if (user.id == 0) {
      throw Exception('User must have an ID to be updated');
    }
    return _box.put(user, mode: PutMode.update);
  }

  // Delete a user by ID
  bool deleteUser(int id) {
    return _box.remove(id);
  }

  // Delete a user by UUID
  bool deleteUserByUuid(String uuid) {
    final user = getUserByUuid(uuid);
    if (user != null) {
      return _box.remove(user.id);
    }
    return false;
  }

  // Get all users
  List<UserEntity> getAllUsers() {
    return _box.getAll();
  }

  // Get users by club ID
  List<UserEntity> getByClubId(int clubId) {
    final query = _box.query(UserEntity_.clubId.equals(clubId)).build();
    final users = query.find();
    query.close();
    return users;
  }

  // Get users with pagination
  List<UserEntity> getUsersWithPagination({int offset = 0, int limit = 20}) {
    final query = _box.query().build();
    query.offset = offset;
    query.limit = limit;
    final users = query.find();
    query.close();
    return users;
  }

  // Count all users
  int countAllUsers() {
    return _box.count();
  }

  // Count users by club ID
  int countUsersByClubId(int clubId) {
    final query = _box.query(UserEntity_.clubId.equals(clubId)).build();
    final count = query.count();
    query.close();
    return count;
  }
}
