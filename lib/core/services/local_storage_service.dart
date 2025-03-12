import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  final EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();

  Future<void> saveData(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<String?> getData(String key) async {
    return await _preferences.getString(key);
  }

  Future<void> removeData(String key) async {
    await _preferences.remove(key);
  }
}
