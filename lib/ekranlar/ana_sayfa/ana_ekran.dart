import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../saglayicilar/kelime_saglayici.dart';
import '../../saglayicilar/seri_saglayici.dart';
import '../../saglayicilar/tema_saglayici.dart';
import '../../bilesenler/seri_rozeti.dart';
import '../../bilesenler/ilerleme_gostergesi.dart';
import '../../bilesenler/buzlu_bilesenler.dart';
import '../kartlar/kart_ekrani.dart';
import '../test/test_secim_ekrani.dart';
import '../istatistik/istatistik_ekrani.dart';
import '../kelime_listesi/kelime_listesi_ekrani.dart';
import '../giris/giris_ekrani.dart';
import '../../cekirdek/araclar/bildirim_yoneticisi.dart';
import '../../veri/depolar/kelime_deposu.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _selectedWordCount = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviders();
    });
  }

  Future<void> _initProviders() async {
    if (!mounted) return;
    await context.read<KelimeSaglayici>().init();
    if (!mounted) return;
    await context.read<SeriSaglayici>().init();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      body: Consumer2<KelimeSaglayici, SeriSaglayici>(
        builder: (context, wordProvider, streakProvider, _) {
          if (wordProvider.isLoading || streakProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Renkler.getSecondary(isDark)));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildGradientHeader(context, wordProvider, streakProvider, isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Tema.spacingLG),
                  child: Column(
                    children: [
                      const SizedBox(height: Tema.spacingLG),
                      _buildDailyWordsCard(context, wordProvider),
                      const SizedBox(height: Tema.spacingMD),
                      _buildActionButtons(context),
                      const SizedBox(height: Tema.spacingMD),
                      _buildMotivationCard(context, streakProvider),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // GRADIENT HEADER
  // ═══════════════════════════════════════════════

  Widget _buildGradientHeader(BuildContext context, KelimeSaglayici wordProvider, SeriSaglayici streakProvider, bool isDark) {
    final learnedCount = wordProvider.learnedWords.length;
    final totalCount = wordProvider.allWords.length;
    final userName = KelimeDeposu().getUserName() ?? '';

    return Container(
      decoration: BoxDecoration(
        gradient: Renkler.getHeaderGradient(isDark),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Tema.spacingLG, Tema.spacingSM, Tema.spacingLG, Tema.spacingLG),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar + isim — tıklanınca profil sheet açılır
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showProfileSheet(context, isDark, wordProvider, streakProvider);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merhaba, $userName',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Bugün ne öğreneceksin?',
                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  MiniSeriRozeti(streak: streakProvider.currentStreak, isActiveToday: streakProvider.isActiveToday),
                ],
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: Tema.spacingXL),

              // İlerleme bilgisi
              Container(
                padding: const EdgeInsets.all(Tema.spacingLG),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Tema.cardRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                      child: IlerlemeGostergesi(
                        progress: wordProvider.overallProgress,
                        radius: 40, lineWidth: 6,
                        progressColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: Tema.spacingLG),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Genel İlerleme', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                          ]),
                          const SizedBox(height: 6),
                          Text('$learnedCount / $totalCount kelime öğrenildi', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                          const SizedBox(height: 12),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: totalCount > 0 ? learnedCount / totalCount : 0,
                              child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08),

              const SizedBox(height: Tema.spacingSM),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // PROFİL & AYARLAR SHEET
  // ═══════════════════════════════════════════════

  void _showProfileSheet(BuildContext context, bool isDark, KelimeSaglayici wordProvider, SeriSaglayici streakProvider) {
    final repo = KelimeDeposu();
    final bildirim = BildirimYoneticisi();
    final userName = repo.getUserName() ?? '';
    bool notifEnabled = repo.getNotificationEnabled();
    int notifHour = repo.getNotificationHour();
    int notifMinute = repo.getNotificationMinute();
    final themeProvider = context.read<TemaSaglayici>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Renkler.getCard(isDark),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (ctx, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(Tema.spacingLG, 0, Tema.spacingLG, Tema.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Renkler.getCardBorder(isDark), borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: Tema.spacingLG),

                      // ─── PROFİL BÖLÜMÜ ───
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: Renkler.getHeaderGradient(isDark),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Renkler.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
                              ),
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Renkler.getTextPrimary(isDark))),
                            const SizedBox(height: 4),
                            Text('İngilizce Öğreniyor', style: TextStyle(fontSize: 14, color: Renkler.getTextSecondary(isDark))),
                          ],
                        ),
                      ),

                      const SizedBox(height: Tema.spacingLG),

                      // ─── İSTATİSTİK ÖZETİ ───
                      Row(
                        children: [
                          Expanded(child: _buildMiniStat(
                            isDark: isDark,
                            icon: Icons.school_rounded,
                            value: '${wordProvider.learnedWords.length}',
                            label: 'Öğrenilen',
                            color: Renkler.getSecondary(isDark),
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMiniStat(
                            isDark: isDark,
                            icon: Icons.local_fire_department_rounded,
                            value: '${streakProvider.currentStreak}',
                            label: 'Gün Seri',
                            color: Renkler.warning,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMiniStat(
                            isDark: isDark,
                            icon: Icons.quiz_rounded,
                            value: '${streakProvider.totalQuizzesTaken}',
                            label: 'Test',
                            color: Renkler.getAccent(isDark),
                          )),
                        ],
                      ),

                      const SizedBox(height: Tema.spacingLG),
                      Divider(color: Renkler.getCardBorder(isDark)),
                      const SizedBox(height: Tema.spacingSM),

                      // ─── AYARLAR ───
                      Text('Ayarlar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Renkler.getTextSecondary(isDark), letterSpacing: 0.5)),
                      const SizedBox(height: Tema.spacingMD),

                      // Profil düzenle
                      _buildSettingsItem(
                        isDark: isDark,
                        icon: Icons.edit_rounded,
                        title: 'Adımı Değiştir',
                        subtitle: userName,
                        color: Renkler.getSecondary(isDark),
                        onTap: () => _showEditNameDialog(ctx, isDark, repo, setSheetState),
                      ),
                      const SizedBox(height: 10),

                      // Karanlık mod
                      _buildSettingsToggle(
                        isDark: isDark,
                        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        title: 'Karanlık Mod',
                        subtitle: isDark ? 'Açık' : 'Kapalı',
                        color: isDark ? Renkler.warning : Renkler.getSecondary(isDark),
                        value: isDark,
                        onChanged: (val) {
                          themeProvider.toggleTheme();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Bildirimler
                      _buildSettingsToggle(
                        isDark: isDark,
                        icon: Icons.notifications_outlined,
                        title: 'Günlük Hatırlatma',
                        subtitle: notifEnabled
                            ? '${notifHour.toString().padLeft(2, '0')}:${notifMinute.toString().padLeft(2, '0')}'
                            : 'Kapalı',
                        color: Renkler.getTeal(isDark),
                        value: notifEnabled,
                        onChanged: (val) async {
                          setSheetState(() => notifEnabled = val);
                          await repo.setNotificationEnabled(val);
                          if (val) {
                            await bildirim.gunlukHatirlatmaAyarla(notifHour, notifMinute);
                          } else {
                            await bildirim.bildirimiIptalEt();
                          }
                        },
                      ),

                      // Bildirim saati
                      if (notifEnabled) ...[
                        const SizedBox(height: 10),
                        _buildSettingsItem(
                          isDark: isDark,
                          icon: Icons.access_time_rounded,
                          title: 'Hatırlatma Saati',
                          subtitle: '${notifHour.toString().padLeft(2, '0')}:${notifMinute.toString().padLeft(2, '0')}',
                          color: Renkler.getTeal(isDark),
                          onTap: () async {
                            final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay(hour: notifHour, minute: notifMinute));
                            if (picked != null) {
                              setSheetState(() { notifHour = picked.hour; notifMinute = picked.minute; });
                              await repo.setNotificationTime(picked.hour, picked.minute);
                              await bildirim.gunlukHatirlatmaAyarla(picked.hour, picked.minute);
                            }
                          },
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Bugünkü kelimeleri sıfırla
                      _buildSettingsItem(
                        isDark: isDark,
                        icon: Icons.refresh_rounded,
                        title: 'Bugünkü Kelimeleri Sıfırla',
                        subtitle: 'Bildiğin kelimeler kalır, yeni liste al',
                        color: Renkler.getAccent(isDark),
                        onTap: () => _showConfirmDialog(
                          ctx, isDark,
                          title: 'Kelimeleri Sıfırla',
                          message: '"Biliyorum" dediğin kelimeler kalıcı olarak öğrenilmiş sayılacak.\n\nCevaplanmayan ve "Tekrar Et" dediğin kelimeler havuza geri dönecek.\n\nYeni kelime sayısı seçip yeni bir listeye başlayabileceksin.',
                          confirmText: 'Sıfırla',
                          onConfirm: () async {
                            await wordProvider.resetDailyAndRefresh();
                            if (!mounted) return;
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Çıkış yap
                      _buildSettingsItem(
                        isDark: isDark,
                        icon: Icons.logout_rounded,
                        title: 'Çıkış Yap',
                        subtitle: 'Hesabı sil ve giriş ekranına dön',
                        color: Renkler.error,
                        onTap: () => _showConfirmDialog(
                          ctx, isDark,
                          title: 'Çıkış Yap',
                          message: 'Tüm öğrenme ilerlemeniz, test sonuçlarınız ve seri bilgileriniz silinecek. Giriş ekranına döneceksiniz. Bu işlem geri alınamaz.',
                          confirmText: 'Çıkış Yap',
                          isDestructive: true,
                          onConfirm: () async {
                            await repo.logout();
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(builder: (_) => const GirisEkrani()),
                              (route) => false,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: Tema.spacingXL),

                      // Uygulama bilgisi
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('de', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Renkler.getTextSecondary(isDark), fontStyle: FontStyle.italic)),
                                Text('HADİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Renkler.getSecondary(isDark))),
                                Text('?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Renkler.getAccent(isDark))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('v1.0.0', style: TextStyle(fontSize: 12, color: Renkler.getTextSecondary(isDark))),
                          ],
                        ),
                      ),
                      const SizedBox(height: Tema.spacingMD),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStat({required bool isDark, required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Tema.radiusMD),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Renkler.getTextPrimary(isDark))),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Renkler.getTextSecondary(isDark))),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({required bool isDark, required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Renkler.getSurface(isDark),
          borderRadius: BorderRadius.circular(Tema.radiusMD),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Renkler.getTextPrimary(isDark))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Renkler.getTextSecondary(isDark))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Renkler.getTextSecondary(isDark), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsToggle({required bool isDark, required IconData icon, required String title, required String subtitle, required Color color, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Renkler.getSurface(isDark),
        borderRadius: BorderRadius.circular(Tema.radiusMD),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Renkler.getTextPrimary(isDark))),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Renkler.getTextSecondary(isDark))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext ctx, bool isDark, KelimeDeposu repo, StateSetter setSheetState) {
    final controller = TextEditingController(text: repo.getUserName() ?? '');
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Renkler.getCard(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tema.cardRadius)),
        title: Text('Adını Değiştir', style: TextStyle(fontWeight: FontWeight.w700, color: Renkler.getTextPrimary(isDark))),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(fontSize: 16, color: Renkler.getTextPrimary(isDark)),
          decoration: InputDecoration(
            hintText: 'Yeni adın...',
            filled: true,
            fillColor: Renkler.getSurface(isDark),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(Tema.radiusMD), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Tema.radiusMD), borderSide: BorderSide(color: Renkler.getSecondary(isDark), width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('İptal', style: TextStyle(color: Renkler.getTextSecondary(isDark))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.length >= 2) {
                await repo.setUserName(newName);
                setSheetState(() {});
                if (mounted) setState(() {});
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Renkler.getSecondary(isDark), foregroundColor: Colors.white),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext ctx, bool isDark, {required String title, required String message, required String confirmText, bool isDestructive = false, required VoidCallback onConfirm}) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Renkler.getCard(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tema.cardRadius)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: Renkler.getTextPrimary(isDark))),
        content: Text(message, style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('İptal', style: TextStyle(color: Renkler.getTextSecondary(isDark))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Renkler.error : Renkler.getSecondary(isDark),
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // İÇERİK KARTLARI
  // ═══════════════════════════════════════════════

  Widget _buildDailyWordsCard(BuildContext context, KelimeSaglayici wordProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (wordProvider.hasTodaySelection) return _buildContinueCard(context, wordProvider, isDark);
    return _buildSelectionCard(context, wordProvider, isDark);
  }

  Widget _buildSelectionCard(BuildContext context, KelimeSaglayici wordProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(Tema.spacingLG),
      decoration: BoxDecoration(
        color: Renkler.getCard(isDark),
        borderRadius: BorderRadius.circular(Tema.cardRadius),
        border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Renkler.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Renkler.getSecondary(isDark).withOpacity(0.1), borderRadius: BorderRadius.circular(Tema.radiusMD)),
                child: Icon(Icons.school_outlined, color: Renkler.getSecondary(isDark), size: 24),
              ),
              const SizedBox(width: Tema.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bugün kaç kelime?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Renkler.getTextPrimary(isDark))),
                    const SizedBox(height: 2),
                    Text('Günlük hedefini seç', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Renkler.getTextSecondary(isDark))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(gradient: Renkler.getHeaderGradient(isDark), borderRadius: BorderRadius.circular(Tema.radiusMD)),
                child: Text('$_selectedWordCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: Tema.spacingXL),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Renkler.getSecondary(isDark),
              inactiveTrackColor: Renkler.getSecondary(isDark).withOpacity(0.12),
              thumbColor: Renkler.getSecondary(isDark),
              overlayColor: Renkler.getSecondary(isDark).withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _selectedWordCount.toDouble(), min: 5, max: 50, divisions: 9,
              onChanged: (value) { HapticFeedback.selectionClick(); setState(() => _selectedWordCount = value.round()); },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Tema.spacingMD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('5 kelime', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Renkler.getTextSecondary(isDark))),
                Text('50 kelime', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Renkler.getTextSecondary(isDark))),
              ],
            ),
          ),
          const SizedBox(height: Tema.spacingLG),
          SizedBox(width: double.infinity, child: BuzluButon(text: 'Öğrenmeye Başla', icon: Icons.play_arrow_rounded, onPressed: () async {
            await wordProvider.loadDailyWords(count: _selectedWordCount);
            if (!mounted) return;
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const KartEkrani()));
          })),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08);
  }

  Widget _buildContinueCard(BuildContext context, KelimeSaglayici wordProvider, bool isDark) {
    final dailyWords = wordProvider.dailyWords;
    final totalWords = dailyWords.length;
    final isCompleted = wordProvider.isAllCompleted;
    final completedCount = isCompleted ? totalWords : wordProvider.currentCardIndex;
    final remainingCount = totalWords - completedCount;
    final statusColor = isCompleted ? Renkler.getSuccess(isDark) : Renkler.getSecondary(isDark);

    return Container(
      padding: const EdgeInsets.all(Tema.spacingLG),
      decoration: BoxDecoration(
        color: Renkler.getCard(isDark),
        borderRadius: BorderRadius.circular(Tema.cardRadius),
        border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Renkler.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Tema.radiusMD)),
                child: Icon(isCompleted ? Icons.check_circle_outlined : Icons.auto_stories_outlined, color: statusColor, size: 24),
              ),
              const SizedBox(width: Tema.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isCompleted ? 'Tebrikler!' : 'Bugünün Kelimeleri', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Renkler.getTextPrimary(isDark))),
                    const SizedBox(height: 2),
                    Text(isCompleted ? 'Bugünlük hedefini tamamladın' : '$completedCount / $totalWords kelime tamamlandı', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Renkler.getTextSecondary(isDark))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Tema.radiusSM)),
                child: Text(isCompleted ? '✓ Bitti' : '$remainingCount kaldı', style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: Tema.spacingLG),
          Container(
            height: 8,
            decoration: BoxDecoration(color: Renkler.getSurface(isDark), borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalWords > 0 ? completedCount / totalWords : 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isCompleted ? LinearGradient(colors: [Renkler.getSuccess(isDark), Renkler.getSuccess(isDark).withOpacity(0.8)]) : Renkler.getPrimaryGradient(isDark),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: Tema.spacingLG),
          SizedBox(width: double.infinity, child: BuzluButon(
            text: isCompleted ? 'Tekrar Başla' : completedCount == 0 ? 'Öğrenmeye Başla' : '${completedCount + 1}. Kelimeden Devam Et',
            icon: isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
            onPressed: () { if (isCompleted) wordProvider.resetCards(); Navigator.push(context, CupertinoPageRoute(builder: (_) => const KartEkrani())); },
          )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08);
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(child: _ActionCard(icon: Icons.quiz_outlined, title: 'Test', subtitle: 'Kendini test et', color: Renkler.getAccent(isDark), onTap: () { HapticFeedback.lightImpact(); Navigator.push(context, CupertinoPageRoute(builder: (_) => const TestSecimEkrani())); })),
        const SizedBox(width: Tema.spacingMD),
        Expanded(child: _ActionCard(icon: Icons.menu_book_outlined, title: 'Kelimelerim', subtitle: 'Ara ve filtrele', color: Renkler.getTeal(isDark), onTap: () { HapticFeedback.lightImpact(); Navigator.push(context, CupertinoPageRoute(builder: (_) => const KelimeListesiEkrani())); })),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08);
  }

  Widget _buildMotivationCard(BuildContext context, SeriSaglayici streakProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ScaleTapWrapper(
      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const IstatistikEkrani())),
      child: Container(
        padding: const EdgeInsets.all(Tema.spacingLG),
        decoration: BoxDecoration(
          gradient: Renkler.getHeaderGradient(isDark),
          borderRadius: BorderRadius.circular(Tema.cardRadius),
          boxShadow: [BoxShadow(color: Renkler.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(Tema.radiusMD)),
              child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: Tema.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(streakProvider.getMotivationMessage(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('İstatistikleri görüntüle →', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08);
  }
}

class _ScaleTapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _ScaleTapWrapper({required this.child, required this.onTap});
  @override
  State<_ScaleTapWrapper> createState() => _ScaleTapWrapperState();
}

class _ScaleTapWrapperState extends State<_ScaleTapWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { _controller.forward(); HapticFeedback.lightImpact(); },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(animation: _scale, builder: (context, child) => Transform.scale(scale: _scale.value, child: child), child: widget.child),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) { _controller.forward(); HapticFeedback.lightImpact(); },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(Tema.spacingLG),
          decoration: BoxDecoration(
            color: Renkler.getCard(isDark),
            borderRadius: BorderRadius.circular(Tema.cardRadius),
            border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
            boxShadow: isDark ? null : [BoxShadow(color: Renkler.primary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(Tema.radiusMD)),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(height: Tema.spacingMD),
              Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Renkler.getTextPrimary(isDark))),
              const SizedBox(height: Tema.spacingXS),
              Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Renkler.getTextSecondary(isDark))),
            ],
          ),
        ),
      ),
    );
  }
}
