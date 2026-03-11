import 'package:flutter/material.dart';

/// Global hata yakalama ve kullanıcıya gösterme yardımcıları.
class HataYonetimi {
  static void snackBarGoster(BuildContext context, String mesaj) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void logHata(String kaynak, Object hata, [StackTrace? iz]) {
    debugPrint('[$kaynak] HATA: $hata');
    if (iz != null) debugPrint(iz.toString());
  }
}
