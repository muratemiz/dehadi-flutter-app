import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../veri/depolar/kelime_deposu.dart';
import '../ana_sayfa/ana_ekran.dart';
import '../onboarding/onboarding_ekrani.dart';
import '../giris/giris_ekrani.dart';

class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({super.key});

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final repo = KelimeDeposu();

    if (!repo.hasUser) {
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const GirisEkrani()));
    } else if (!repo.hasSeenOnboarding) {
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const OnboardingEkrani()));
    } else {
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const AnaEkran()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: Renkler.getHeaderGradient(isDark)),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Tema.radiusXL),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('d', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w300, color: Colors.white54, fontStyle: FontStyle.italic, height: 1)),
                      Text('H', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                    ],
                  ),
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: Tema.spacingXL),
              const Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('de', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white54, letterSpacing: 1, fontStyle: FontStyle.italic)),
                  Text('HADİ', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3)),
                  Text('?', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white70)),
                ],
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: Tema.spacingMD),
              Text(
                'İngilizce Öğren',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.7)),
              ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
              const Spacer(flex: 3),
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ).animate(delay: 900.ms).fadeIn(duration: 300.ms),
              const SizedBox(height: Tema.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }
}
