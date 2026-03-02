import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallPermissions {
  static const _kPermissionsPromptSeen = 'call_permissions_prompt_seen';

  Future<bool> areAndroidCallPermissionsGranted() async {
    final phone = await Permission.phone.status;
    return phone.isGranted;
  }

  Future<bool> requestAndroidCallPermissions() async {
    final statuses = await [
      Permission.phone,
    ].request();

    final phone = statuses[Permission.phone];
    return phone?.isGranted == true;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted || status.isLimited;
  }

  Future<void> markPromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPermissionsPromptSeen, true);
  }

  Future<bool> hasSeenPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPermissionsPromptSeen) ?? false;
  }
}
