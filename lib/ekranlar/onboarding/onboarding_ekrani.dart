import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../bilesenler/buzlu_bilesenler.dart';
import '../ana_sayfa/ana_ekran.dart';

class OnboardingEkrani extends StatefulWidget {
  const OnboardingEkrani({super.key});

  @override
  State<OnboardingEkrani> createState() => _OnboardingEkraniState();
}

class _OnboardingEkraniState extends State<OnboardingEkrani> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.school_rounded,
      title: 'Hoşgeldin!',
      description: 'DeHadi? ile her gün yeni İngilizce kelimeler öğren.\n1000 kelimelik kapsamlı bir havuz seni bekliyor.',
      color: Color(0xFF1B3B5A),
    ),
    _OnboardingPage(
      icon: Icons.auto_stories_rounded,
      title: 'Günlük Kelimeler',
      description: 'Her gün istediğin kadar kelime seç.\nKartları çevirerek öğren, "Biliyorum" veya "Tekrar Et" ile ilerle.',
      color: Color(0xFF3B82F6),
    ),
    _OnboardingPage(
      icon: Icons.quiz_rounded,
      title: 'Kendini Test Et',
      description: 'Çoktan seçmeli, yazarak cevaplama ve eşleştirme testleriyle bilgini pekiştir.',
      color: Color(0xFF8B5CF6),
    ),
    _OnboardingPage(
      icon: Icons.local_fire_department_rounded,
      title: 'Seriyi Koru',
      description: 'Her gün çalışarak serini uzat.\nBronz, gümüş ve altın rozetler kazan!',
      color: Color(0xFFF59E0B),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.lightImpact();
    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => const AnaEkran()),
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Atla',
                  style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 14),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Tema.spacingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [page.color, page.color.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: page.color.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 64, color: Colors.white),
                        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
                        const SizedBox(height: Tema.spacingXL),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Renkler.getTextPrimary(isDark),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: Tema.spacingMD),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Renkler.getTextSecondary(isDark),
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Tema.spacingLG),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Renkler.getSecondary(isDark)
                              : Renkler.getSurface(isDark),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: Tema.spacingLG),
                  SizedBox(
                    width: double.infinity,
                    child: BuzluButon(
                      text: _currentPage == _pages.length - 1 ? 'Hadi Başlayalım!' : 'İleri',
                      icon: _currentPage == _pages.length - 1
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _OnboardingPage({required this.icon, required this.title, required this.description, required this.color});
}
