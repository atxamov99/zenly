import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'location_task_handler.dart';

class LocationService {
  static const _notificationChannelId = 'location_channel';

  Future<bool> requestPermissions() async {
    final fine = await Permission.locationWhenInUse.request();
    if (!fine.isGranted) return false;

    final background = await Permission.locationAlways.request();
    if (!background.isGranted) return false;

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _notificationChannelId,
        channelName: 'Blink Joylashuv',
        channelDescription:
            'Blink joylashuvingizni do\'stlaringiz bilan ulashmoqda',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  Future<bool> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }

    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Blink',
      notificationText: 'Joylashuvingiz do\'stlaringizga ulashilmoqda',
      callback: startLocationCallback,
    );

    return result is ServiceRequestSuccess;
  }

  Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }

  Future<bool> isRunning() => FlutterForegroundTask.isRunningService;
}
