import 'package:hive/hive.dart';
import '../models/user.dart';

class ProfileService {
  static const _profileBoxName = 'userProfiles';

  /// Get user profile by username. Returns null if not found.
  static Future<User?> getUserProfile(String username) async {
    try {
      final box = Hive.box(_profileBoxName);
      final data = box.get(username);
      if (data is Map) {
        return User.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save user profile to Hive.
  static Future<void> saveUserProfile(User user) async {
    try {
      final box = Hive.box(_profileBoxName);
      await box.put(user.username, user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Get or create default user profile.
  static Future<User> getOrCreateProfile(String username) async {
    final existing = await getUserProfile(username);
    if (existing != null) return existing;

    final newUser = User(
      username: username,
      name: ' ',
      email: null,
      phone: null,
      photoPath: null,
    );
    await saveUserProfile(newUser);
    return newUser;
  }
}
