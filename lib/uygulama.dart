import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cekirdek/tema/uygulama_temasi.dart';
import 'saglayicilar/tema_saglayici.dart';
import 'ekranlar/acilis/acilis_ekrani.dart';
import 'ekranlar/giris/giris_ekrani.dart';
import 'ekranlar/ana_sayfa/ana_ekran.dart';
import 'ekranlar/kartlar/kart_ekrani.dart';
import 'ekranlar/test/test_ekrani.dart';
import 'ekranlar/test/test_secim_ekrani.dart';
import 'ekranlar/istatistik/istatistik_ekrani.dart';
import 'ekranlar/kelime_listesi/kelime_listesi_ekrani.dart';

class DeHadiUygulama extends StatelessWidget {
  const DeHadiUygulama({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemaSaglayici>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'DeHadi?',
          debugShowCheckedModeBanner: false,
          theme: Tema.lightTheme,
          darkTheme: Tema.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AcilisEkrani(),
          routes: {
            '/login': (context) => const GirisEkrani(),
            '/home': (context) => const AnaEkran(),
            '/cards': (context) => const KartEkrani(),
            '/quiz': (context) => const TestEkrani(),
            '/quiz-select': (context) => const TestSecimEkrani(),
            '/stats': (context) => const IstatistikEkrani(),
            '/words': (context) => const KelimeListesiEkrani(),
          },
        );
      },
    );
  }
}
