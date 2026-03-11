import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../veri/depolar/kelime_deposu.dart';
import '../onboarding/onboarding_ekrani.dart';
import '../ana_sayfa/ana_ekran.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => _isValid = _nameController.text.trim().length >= 2);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_isValid) return;
    HapticFeedback.lightImpact();

    final repo = KelimeDeposu();
    await repo.setUserName(_nameController.text.trim());

    if (!mounted) return;

    final hasSeenOnboarding = repo.hasSeenOnboarding;
    if (!hasSeenOnboarding) {
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const OnboardingEkrani()));
    } else {
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const AnaEkran()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: Renkler.getHeaderGradient(isDark)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Tema.spacingLG),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(Tema.radiusLG),
                        border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('d', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white54, fontStyle: FontStyle.italic, height: 1)),
                            Text('H', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                          ],
                        ),
                      ),
                    ).animate().scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.elasticOut).fadeIn(duration: 300.ms),

                    const SizedBox(height: 20),

                    // Hoşgeldin başlık
                    const Text(
                      'Hoşgeldin!',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15),

                    const SizedBox(height: 8),

                    Text(
                      'İngilizce öğrenmeye başlamak için\nadını gir',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), height: 1.5),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 40),

                    // Giriş kartı
                    Container(
                      padding: const EdgeInsets.all(Tema.spacingLG),
                      decoration: BoxDecoration(
                        color: Renkler.getCard(isDark),
                        borderRadius: BorderRadius.circular(Tema.cardRadius),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adın',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Renkler.getTextSecondary(isDark)),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _nameController,
                            focusNode: _focusNode,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Renkler.getTextPrimary(isDark),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Adını yaz...',
                              hintStyle: TextStyle(color: Renkler.getTextSecondary(isDark).withOpacity(0.5), fontWeight: FontWeight.w400),
                              prefixIcon: Icon(Icons.person_outline_rounded, color: Renkler.getSecondary(isDark)),
                              filled: true,
                              fillColor: Renkler.getSurface(isDark),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Tema.radiusMD), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Tema.radiusMD), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Tema.radiusMD),
                                borderSide: BorderSide(color: Renkler.getSecondary(isDark), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onSubmitted: (_) => _onContinue(),
                          ),
                          const SizedBox(height: Tema.spacingLG),

                          // Devam butonu
                          SizedBox(
                            width: double.infinity,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed: _isValid ? _onContinue : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isValid ? Renkler.getSecondary(isDark) : Renkler.getSurface(isDark),
                                  foregroundColor: _isValid ? Colors.white : Renkler.getTextSecondary(isDark),
                                  disabledBackgroundColor: Renkler.getSurface(isDark),
                                  disabledForegroundColor: Renkler.getTextSecondary(isDark),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tema.buttonRadius)),
                                  elevation: _isValid ? 4 : 0,
                                  shadowColor: Renkler.secondary.withOpacity(0.3),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Başlayalım', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.15),

                    const Spacer(flex: 3),

                    // Alt mesaj
                    Text(
                      'Verileriniz yalnızca bu cihazda saklanır',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                    ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: Tema.spacingLG),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
