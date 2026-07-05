import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background/terminated state এ message আসলে এই top-level function চলে।
// main() এর বাইরে top-level এ থাকা লাগবে।
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification payload থাকলে OS নিজেই tray তে দেখায়, এখানে extra কিছু লাগে না।
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'campusgo_default',
    'CampusGo Notifications',
    description: 'Job, Tutor, Book, Notice, Group update',
    importance: Importance.high,
  );

  /// login এর পর একবার call করো (AuthWrapper / HomeScreen initState)
  static Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // App খোলা অবস্থায় (foreground) message আসলে local notification দেখাও
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // সব user এই topic এ subscribed — নতুন Job/Tutor/Book/Notice broadcast এর জন্য
    await _messaging.subscribeToTopic('all_updates');

    await _saveTokenForCurrentUser();
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;
    await _local.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> _saveTokenForCurrentUser() async {
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  /// Logout করার আগে call করো — যাতে পুরনো device notification না পায়
  static Future<void> clearToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _messaging.unsubscribeFromTopic('all_updates');
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': FieldValue.delete(),
    });
  }
}