import 'package:hive/hive.dart';

class UserService {
  static const _boxName = 'users';

  /// Registers a user with [username] and [password].
  /// Throws exception if username already exists.
  static Future<void> registerUser(String username, String password) async {
    final box = Hive.box(_boxName);
    if (box.containsKey(username)) {
      throw Exception('Username already exists');
    }
    await box.put(username, password);
  }

  /// Validates username and password. Returns true if match.
  static Future<bool> validate(String username, String password) async {
    final box = Hive.box(_boxName);
    if (!box.containsKey(username)) return false;
    final stored = box.get(username);
    return stored == password;
  }
}
