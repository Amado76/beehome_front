import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppPreferencesRepository {
  Future<String?> locale();
  Future<void> setLocale(String? value);
  Future<String?> selectedFamilyId();
  Future<void> setSelectedFamilyId(String? value);
}

class LocalAppPreferencesRepository implements AppPreferencesRepository {
  LocalAppPreferencesRepository(this._preferences);

  final SharedPreferencesAsync _preferences;
  static const String _localeKey = 'beehome.locale';
  static const String _familyKey = 'beehome.selectedFamilyId';

  Future<void> _set(String key, String? value) => value == null
      ? _preferences.remove(key)
      : _preferences.setString(key, value);

  @override
  Future<String?> locale() => _preferences.getString(_localeKey);
  @override
  Future<void> setLocale(String? value) => _set(_localeKey, value);
  @override
  Future<String?> selectedFamilyId() => _preferences.getString(_familyKey);
  @override
  Future<void> setSelectedFamilyId(String? value) => _set(_familyKey, value);
}

class MemoryAppPreferencesRepository implements AppPreferencesRepository {
  String? _locale;
  String? _family;
  @override
  Future<String?> locale() async => _locale;
  @override
  Future<void> setLocale(String? value) async => _locale = value;
  @override
  Future<String?> selectedFamilyId() async => _family;
  @override
  Future<void> setSelectedFamilyId(String? value) async => _family = value;
}
