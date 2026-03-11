import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'dart:math';

class BildirimYoneticisi {
  static final BildirimYoneticisi _instance = BildirimYoneticisi._internal();
  factory BildirimYoneticisi() => _instance;
  BildirimYoneticisi._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'dehadi_daily';
  static const _channelName = 'Günlük Hatırlatma';

  final _messages = [
    'Bugün henüz çalışmadın! Serinizi koruyun.',
    'Günlük kelimeler seni bekliyor!',
    'Her gün 5 dakika = büyük fark!',
    'Bugünkü kelimeleri öğrenmeye ne dersin?',
    'Seriyi kırmamak için hadi bir tur!',
  ];

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      _initialized = true;
    } catch (e) {
      debugPrint('[BildirimYoneticisi.init] HATA: $e');
    }
  }

  Future<void> gunlukHatirlatmaAyarla(int hour, int minute) async {
    try {
      await _plugin.cancelAll();

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final message = _messages[Random().nextInt(_messages.length)];

      await _plugin.zonedSchedule(
        0,
        'DeHadi?',
        message,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('[BildirimYoneticisi.gunlukHatirlatmaAyarla] HATA: $e');
    }
  }

  Future<void> bildirimiIptalEt() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[BildirimYoneticisi.bildirimiIptalEt] HATA: $e');
    }
  }
}
