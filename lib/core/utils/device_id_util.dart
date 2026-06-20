import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdUtil {
  static const _key = 'device_id';
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_key);
    if (id != null && id.isNotEmpty) return id;

    final info = DeviceInfoPlugin();
    final androidInfo = await info.androidInfo;
    id = androidInfo.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString(_key, id);
    return id;
  }
}
