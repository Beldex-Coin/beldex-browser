import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DownloadNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _channelId = 2001;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings,
    onDidReceiveNotificationResponse: (NotificationResponse response)async {
      final String? taskId = response.payload;

      if(taskId != null && taskId.isNotEmpty){
        try{
          await FlutterDownloader.open(taskId: taskId);
        }catch(e){
          print('Error opening file: $e');
        }
      }
    },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'download_channel',
      'Downloads',
      description: 'Download progress',
      importance: Importance.low,
      showBadge: false,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show / Update progress
  static Future<void> showProgress({
    required int id,
    required String title,
    required int progress,
  }) async {
    final android = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download progress',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );

    await _plugin.show(
      id,
      title,
      '$progress%',
      NotificationDetails(android: android),
    );
  }

  /// Completed notification
  static Future<void> showCompleted({
    required int id,
    required String title,
    required String taskId,required String message,
  }) async {
    final android = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      importance: Importance.low,
      priority: Priority.low,
      autoCancel: true,
    );

    await _plugin.show(
      id,
      title,
      message,
      //'Download completed',
      NotificationDetails(android: android),
      payload: taskId
    );
  }


/// Cancel or failed notification
  static Future<void> showCancelOrFailed({
    required int id,
    required String title,
    required String text,
    required String taskId
  }) async {
    final android = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      importance: Importance.low,
      priority: Priority.low,
      autoCancel: true,
    );

    await _plugin.show(
      id,
      title,
      '$text',
      NotificationDetails(android: android),
      payload: taskId
    );
  }




  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

static Future<void> cancelAllNotifications()async{
   await _plugin.cancelAll();
}
  
}
