import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'uygulama.dart';
import 'veri/modeller/kelime_modeli.dart';
import 'veri/modeller/kullanici_ilerlemesi.dart';
import 'veri/depolar/kelime_deposu.dart';
import 'saglayicilar/kelime_saglayici.dart';
import 'saglayicilar/test_saglayici.dart';
import 'saglayicilar/seri_saglayici.dart';
import 'saglayicilar/tema_saglayici.dart';
import 'cekirdek/araclar/hata_yonetimi.dart';
import 'cekirdek/araclar/bildirim_yoneticisi.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      HataYonetimi.logHata('FlutterError', details.exception, details.stack);
    };

    try {
      await Hive.initFlutter();

      Hive.registerAdapter(KelimeModeliAdapter());
      Hive.registerAdapter(KullaniciIlerlemesiAdapter());
      Hive.registerAdapter(SeriVerisiAdapter());

      final wordRepository = KelimeDeposu();
      await wordRepository.init();

      final bildirimYoneticisi = BildirimYoneticisi();
      await bildirimYoneticisi.init();
      if (wordRepository.getNotificationEnabled()) {
        await bildirimYoneticisi.gunlukHatirlatmaAyarla(
          wordRepository.getNotificationHour(),
          wordRepository.getNotificationMinute(),
        );
      }

      final themeProvider = TemaSaglayici();
      await themeProvider.init();

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => themeProvider),
            ChangeNotifierProvider(create: (_) => KelimeSaglayici(wordRepository)),
            ChangeNotifierProvider(create: (_) => TestSaglayici(wordRepository)),
            ChangeNotifierProvider(create: (_) => SeriSaglayici(wordRepository)),
          ],
          child: const DeHadiUygulama(),
        ),
      );
    } catch (e, st) {
      HataYonetimi.logHata('main', e, st);
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Uygulama başlatılamadı: $e'),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    HataYonetimi.logHata('runZonedGuarded', error, stack);
  });
}
