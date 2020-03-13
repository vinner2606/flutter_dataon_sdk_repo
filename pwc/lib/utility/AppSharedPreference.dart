import 'package:pwc/utility/PlatwareException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreference {
  static AppSharedPreference _appSharedPreference;
  static SharedPreferences _prefs;
  static String LAST_PROPERTY_SYNC_TIME = "last_property_sync_time";
  static String KEY_LAST_DATA_SYNC_TIME = "last_data_sync_time";
  static String KEY_LAST_DATA_SYNC_COUNT = "last_data_sync_count";

  AppSharedPreference._internal();

  static Future<AppSharedPreference> getInstance() async {
    if (_appSharedPreference == null) {
      _prefs = await SharedPreferences.getInstance();
      _appSharedPreference = AppSharedPreference._internal();
    }
    return _appSharedPreference;
  }

  Future<bool> putValue(String key, Object value) {
    if (value is String) {
      return _prefs.setString(key, value);
    } else if (value is int) {
      return _prefs.setInt(key, value);
    } else if (value is bool) {
      return _prefs.setBool(key, value);
    } else if (value is double) {
      return _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return _prefs.setStringList(key, value);
    } else {
      throw new InValidTypeOfValueException();
    }
  }

  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  Object getValue(String key, {Object defaultValue = ""}) {
    Object value = _prefs.get(key);
    if (value != null) {
      if (value is String) {
        return value;
      } else if (value is int) {
        return value;
      } else if (value is bool) {
        return value;
      } else if (value is double) {
        return value;
      } else if (value is List<String>) {
        return value;
      } else {
        throw new InValidTypeOfValueException();
      }
    } else {
      return defaultValue;
    }
  }

  Future<bool> clearAll() {
    return _prefs.clear();
  }
}
