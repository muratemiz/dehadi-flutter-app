import 'package:hive/hive.dart';

part 'kelime_modeli.g.dart';

/// ─── KELİME MODELİ ───
/// Her kelimenin veritabanında nasıl saklandığını tanımlar.
/// Yeni alan eklemek istersen: @HiveField(9) ile yeni alan ekle ve
/// build_runner çalıştır: flutter pub run build_runner build
///
/// ► KATEGORİ EKLEMEK: category alanına yeni değerler yazabilirsin
///   Mevcut kategoriler: 'general', 'business', 'academic'
///   Örnek: 'travel', 'food', 'technology' gibi yeni kategori eklenebilir.
///
/// ► SEVİYE EKLEMEK: level alanında CEFR seviyeleri kullanılır
///   Mevcut: A1, A2, B1, B2, C1, C2
@HiveType(typeId: 0)
class KelimeModeli extends HiveObject {
  @HiveField(0)
  final String id;             // Benzersiz kelime ID'si

  @HiveField(1)
  final String word;           // İngilizce kelime

  @HiveField(2)
  final String meaning;        // Türkçe anlamı

  @HiveField(3)
  final String? definition;    // İngilizce açıklaması (opsiyonel)

  @HiveField(4)
  final String? exampleSentence; // İngilizce örnek cümle (opsiyonel)

  @HiveField(5)
  final String level;          // Zorluk seviyesi: A1, A2, B1, B2, C1, C2

  @HiveField(6)
  final String category;       // Kategori: general, business, academic vb.

  @HiveField(7)
  final String? definitionTr;  // Türkçe açıklama (opsiyonel)

  @HiveField(8)
  final String? exampleSentenceTr; // Türkçe örnek cümle (opsiyonel)

  KelimeModeli({
    required this.id,
    required this.word,
    required this.meaning,
    this.definition,
    this.exampleSentence,
    this.level = 'B1',         // Varsayılan seviye — değiştirilebilir
    this.category = 'general', // Varsayılan kategori — değiştirilebilir
    this.definitionTr,
    this.exampleSentenceTr,
  });

  factory KelimeModeli.fromJson(Map<String, dynamic> json) {
    return KelimeModeli(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      definition: json['definition'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      level: json['level'] as String? ?? 'B1',
      category: json['category'] as String? ?? 'general',
      definitionTr: json['definitionTr'] as String?,
      exampleSentenceTr: json['exampleSentenceTr'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'definition': definition,
      'exampleSentence': exampleSentence,
      'level': level,
      'category': category,
      'definitionTr': definitionTr,
      'exampleSentenceTr': exampleSentenceTr,
    };
  }

  @override
  String toString() {
    return 'KelimeModeli(id: $id, word: $word, meaning: $meaning)';
  }
}
