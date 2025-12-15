import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/services/openai_service.dart';
import '../../core/services/logger_service.dart';

/// 묵상 가이드 Provider
/// 날짜, 독서 타입, 언어별로 묵상 가이드를 생성하고 Firestore에 캐싱합니다.
final meditationGuideProvider = FutureProvider.family<String, MeditationGuideParams>((
  ref,
  params,
) async {
  // Firestore에서 캐시 확인 (하루에 한 번만 생성, 나머지는 캐싱)
  final cacheKey = _getCacheKey(params);
  try {
    final cachedGuide = await _getCachedGuide(cacheKey, params.dateKey);
    if (cachedGuide != null) {
      AppLogger.debug(
        '[MeditationGuideProvider] 캐시에서 묵상 가이드 로드: ${params.readingType} (${params.language})',
      );
      // 캐시된 guide에 참고 말씀이 없으면 추가
      final guideWithReference = _ensureReferenceInGuide(
        cachedGuide,
        params.reference,
        params.language,
      );
      return guideWithReference;
    }
  } catch (e) {
    // 캐시 조회 실패해도 계속 진행 (GPT로 생성)
    AppLogger.warning(
      '[MeditationGuideProvider] 캐시 조회 실패, GPT로 생성 진행: ${params.readingType} (${params.language})',
    );
  }

  // 캐시가 없으면 GPT로 생성 (하루에 한 번만)
  try {
    AppLogger.debug(
      '[MeditationGuideProvider] GPT로 묵상 가이드 생성 시작: ${params.readingType} (${params.language})',
    );
    final openAIService = OpenAIService();
    final guide = await openAIService.generateMeditationGuide(
      readingType: params.readingType,
      reference: params.reference,
      title: params.title,
      language: params.language,
    );

    // 묵상 가이드 하단에 참고 말씀 추가
    final guideWithReference = _addReferenceToGuide(
      guide,
      params.reference,
      params.language,
    );

    // Firestore에 캐싱 (에러가 발생해도 guide는 반환)
    try {
      await _cacheGuide(cacheKey, guideWithReference, params);
      AppLogger.debug(
        '[MeditationGuideProvider] 묵상 가이드 생성 및 캐싱 완료: ${params.readingType} (${params.language})',
      );
    } catch (e) {
      // 캐싱 실패해도 guide는 반환
      AppLogger.warning(
        '[MeditationGuideProvider] 캐싱 실패했지만 guide는 반환: ${params.readingType} (${params.language})',
      );
    }

    return guideWithReference;
  } catch (e, stackTrace) {
    AppLogger.error(
      '[MeditationGuideProvider] 묵상 가이드 생성 실패: ${params.readingType} (${params.language})',
      e,
      stackTrace,
    );
    // 에러 발생 시 기본 메시지 반환 (참고 말씀 추가)
    final defaultGuide = _getDefaultMeditationGuide(params.language);
    return _addReferenceToGuide(
      defaultGuide,
      params.reference,
      params.language,
    );
  }
});

/// 묵상 가이드 파라미터
class MeditationGuideParams {
  final String dateKey; // YYYY-MM-DD 형식
  final String
  readingType; // 'firstReading', 'psalm', 'secondReading', 'gospel'
  final String reference; // 성경 구절 참조
  final String? title; // 독서 제목
  final String language; // 언어 코드: 'ja', 'ko', 'en' 등

  const MeditationGuideParams({
    required this.dateKey,
    required this.readingType,
    required this.reference,
    this.title,
    required this.language,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationGuideParams &&
          runtimeType == other.runtimeType &&
          dateKey == other.dateKey &&
          readingType == other.readingType &&
          reference == other.reference &&
          title == other.title &&
          language == other.language;

  @override
  int get hashCode =>
      dateKey.hashCode ^
      readingType.hashCode ^
      reference.hashCode ^
      (title?.hashCode ?? 0) ^
      language.hashCode;
}

/// 캐시 키 생성
String _getCacheKey(MeditationGuideParams params) {
  return '${params.dateKey}_${params.readingType}_${params.language}';
}

/// Firestore에서 캐시된 묵상 가이드 가져오기
/// 같은 날짜에 생성된 캐시가 있으면 반환 (하루에 한 번만 생성)
Future<String?> _getCachedGuide(String cacheKey, String dateKey) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('meditation_guides')
        .doc(cacheKey)
        .get();

    if (doc.exists) {
      final data = doc.data();
      final cachedDateKey = data?['dateKey'] as String?;
      final guide = data?['guide'] as String?;

      // 같은 날짜에 생성된 캐시가 있으면 반환
      if (cachedDateKey == dateKey && guide != null && guide.isNotEmpty) {
        AppLogger.debug('[MeditationGuideProvider] 같은 날짜의 캐시 발견: $dateKey');
        // 캐시된 guide에는 이미 참고 말씀이 포함되어 있으므로 그대로 반환
        return guide;
      } else {
        // 날짜가 다르면 캐시 무효 (새로운 날짜의 묵상 가이드 생성 필요)
        AppLogger.debug(
          '[MeditationGuideProvider] 날짜가 다른 캐시 발견 (무시): 캐시=$cachedDateKey, 요청=$dateKey',
        );
        return null;
      }
    }
    return null;
  } catch (e, stackTrace) {
    AppLogger.error(
      '[MeditationGuideProvider] 캐시 조회 실패: $cacheKey',
      e,
      stackTrace,
    );
    return null;
  }
}

/// 묵상 가이드 하단에 참고 말씀 추가
String _addReferenceToGuide(String guide, String reference, String language) {
  final referenceText = _formatReference(reference, language);
  return '$guide\n\n$referenceText';
}

/// 묵상 가이드에 참고 말씀이 있는지 확인하고, 없으면 추가
String _ensureReferenceInGuide(
  String guide,
  String reference,
  String language,
) {
  // 이미 참고 말씀이 포함되어 있는지 확인
  final referenceKeywords = _getReferenceKeywords(language);
  final hasReference = referenceKeywords.any(
    (keyword) => guide.contains(keyword),
  );

  if (hasReference) {
    // 이미 참고 말씀이 있으면 그대로 반환
    return guide;
  }

  // 참고 말씀이 없으면 추가
  return _addReferenceToGuide(guide, reference, language);
}

/// 언어별 참고 말씀 키워드
List<String> _getReferenceKeywords(String language) {
  switch (language) {
    case 'ja':
      return ['参考箇所', '聖書箇所'];
    case 'ko':
      return ['참고 말씀', '참고구절'];
    case 'en':
      return ['Reference:', 'Bible Reference'];
    case 'zh':
      return ['参考经文', '参考'];
    case 'vi':
      return ['Tham khảo', 'Tham khảo:'];
    case 'es':
      return ['Referencia', 'Referencia:'];
    case 'pt':
      return ['Referência', 'Referência:'];
    default:
      return ['参考箇所', '聖書箇所'];
  }
}

/// 참고 말씀 포맷팅 (장절 형식으로만 표시, 언어 변환 포함)
String _formatReference(String reference, String language) {
  // reference를 현재 언어로 변환
  final translatedReference = _translateBibleReference(reference, language);
  final cleanReference = translatedReference.trim();

  switch (language) {
    case 'ja':
      return '参考箇所：$cleanReference';
    case 'ko':
      return '참고 말씀：$cleanReference';
    case 'en':
      return 'Reference: $cleanReference';
    case 'zh':
      return '参考经文：$cleanReference';
    case 'vi':
      return 'Tham khảo: $cleanReference';
    case 'es':
      return 'Referencia: $cleanReference';
    case 'pt':
      return 'Referência: $cleanReference';
    default:
      return '参考箇所：$cleanReference';
  }
}

/// 성경 참조 구절을 현재 언어로 변환
/// 예: "マタイ 21:23-27" (일본어) -> "마태오 21:23-27" (한국어)
String _translateBibleReference(String reference, String targetLanguage) {
  // 일본어 성경 책 이름 매핑
  final bookNameMap = _getBibleBookNameMap();

  // reference에서 책 이름과 장절 분리
  // 예: "マタイ 21:23-27" -> ["マタイ", "21:23-27"]
  final parts = reference.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) {
    // 형식이 맞지 않으면 그대로 반환
    return reference;
  }

  // 책 이름 추출 (첫 번째 부분)
  final bookNameJa = parts[0];
  // 장절 추출 (나머지 부분)
  final chapterVerse = parts.sublist(1).join(' ');

  // 책 이름 변환
  String? translatedBookName;
  if (targetLanguage == 'ja') {
    // 일본어는 그대로
    translatedBookName = bookNameJa;
  } else {
    // 다른 언어로 변환
    translatedBookName = bookNameMap[bookNameJa]?[targetLanguage] ?? bookNameJa;
  }

  return '$translatedBookName $chapterVerse';
}

/// 일본어 성경 책 이름을 다른 언어로 변환하는 매핑
Map<String, Map<String, String>> _getBibleBookNameMap() {
  return {
    // 구약
    '創世記': {
      'ko': '창세기',
      'en': 'Genesis',
      'zh': '创世纪',
      'vi': 'Sáng Thế Ký',
      'es': 'Génesis',
      'pt': 'Gênesis',
    },
    '出エジプト記': {
      'ko': '탈출기',
      'en': 'Exodus',
      'zh': '出谷纪',
      'vi': 'Xuất Hành',
      'es': 'Éxodo',
      'pt': 'Êxodo',
    },
    'レビ記': {
      'ko': '레위기',
      'en': 'Leviticus',
      'zh': '肋未纪',
      'vi': 'Lêvi',
      'es': 'Levítico',
      'pt': 'Levítico',
    },
    '民数記': {
      'ko': '민수기',
      'en': 'Numbers',
      'zh': '户籍纪',
      'vi': 'Dân Số',
      'es': 'Números',
      'pt': 'Números',
    },
    '申命記': {
      'ko': '신명기',
      'en': 'Deuteronomy',
      'zh': '申命纪',
      'vi': 'Đệ Nhị Luật',
      'es': 'Deuteronomio',
      'pt': 'Deuteronômio',
    },
    'ヨシュア記': {
      'ko': '여호수아',
      'en': 'Joshua',
      'zh': '若苏厄书',
      'vi': 'Giôsuê',
      'es': 'Josué',
      'pt': 'Josué',
    },
    '士師記': {
      'ko': '판관기',
      'en': 'Judges',
      'zh': '民长纪',
      'vi': 'Thẩm Phán',
      'es': 'Jueces',
      'pt': 'Juízes',
    },
    'ルツ記': {
      'ko': '룻기',
      'en': 'Ruth',
      'zh': '卢德传',
      'vi': 'Rút',
      'es': 'Rut',
      'pt': 'Rute',
    },
    'サムエル記上': {
      'ko': '사무엘기 상',
      'en': '1 Samuel',
      'zh': '撒慕尔纪上',
      'vi': '1 Samuen',
      'es': '1 Samuel',
      'pt': '1 Samuel',
    },
    'サムエル記下': {
      'ko': '사무엘기 하',
      'en': '2 Samuel',
      'zh': '撒慕尔纪下',
      'vi': '2 Samuen',
      'es': '2 Samuel',
      'pt': '2 Samuel',
    },
    '列王記上': {
      'ko': '열왕기 상',
      'en': '1 Kings',
      'zh': '列王纪上',
      'vi': '1 Các Vua',
      'es': '1 Reyes',
      'pt': '1 Reis',
    },
    '列王記下': {
      'ko': '열왕기 하',
      'en': '2 Kings',
      'zh': '列王纪下',
      'vi': '2 Các Vua',
      'es': '2 Reyes',
      'pt': '2 Reis',
    },
    '歴代誌上': {
      'ko': '역대기 상',
      'en': '1 Chronicles',
      'zh': '编年纪上',
      'vi': '1 Sử Ký',
      'es': '1 Crónicas',
      'pt': '1 Crônicas',
    },
    '歴代誌下': {
      'ko': '역대기 하',
      'en': '2 Chronicles',
      'zh': '编年纪下',
      'vi': '2 Sử Ký',
      'es': '2 Crónicas',
      'pt': '2 Crônicas',
    },
    'エズラ記': {
      'ko': '에즈라기',
      'en': 'Ezra',
      'zh': '厄斯德拉上',
      'vi': 'Êxơra',
      'es': 'Esdras',
      'pt': 'Esdras',
    },
    'ネヘミヤ記': {
      'ko': '느헤미야',
      'en': 'Nehemiah',
      'zh': '厄斯德拉下',
      'vi': 'Nêhêmia',
      'es': 'Nehemías',
      'pt': 'Neemias',
    },
    'エステル記': {
      'ko': '에스테르',
      'en': 'Esther',
      'zh': '艾斯德尔传',
      'vi': 'Êxtơ',
      'es': 'Ester',
      'pt': 'Ester',
    },
    'ヨブ記': {
      'ko': '욥기',
      'en': 'Job',
      'zh': '约伯传',
      'vi': 'Gióp',
      'es': 'Job',
      'pt': 'Jó',
    },
    '詩編': {
      'ko': '시편',
      'en': 'Psalms',
      'zh': '圣咏集',
      'vi': 'Thánh Vịnh',
      'es': 'Salmos',
      'pt': 'Salmos',
    },
    '箴言': {
      'ko': '잠언',
      'en': 'Proverbs',
      'zh': '箴言',
      'vi': 'Châm Ngôn',
      'es': 'Proverbios',
      'pt': 'Provérbios',
    },
    'コヘレトの言葉': {
      'ko': '코헬렛',
      'en': 'Ecclesiastes',
      'zh': '训道篇',
      'vi': 'Truyền Đạo',
      'es': 'Eclesiastés',
      'pt': 'Eclesiastes',
    },
    '雅歌': {
      'ko': '아가',
      'en': 'Song of Songs',
      'zh': '雅歌',
      'vi': 'Nhã Ca',
      'es': 'Cantares',
      'pt': 'Cantares',
    },
    'イザヤ': {
      'ko': '이사야',
      'en': 'Isaiah',
      'zh': '依撒意亚',
      'vi': 'I-sai-a',
      'es': 'Isaías',
      'pt': 'Isaías',
    },
    'エレミヤ': {
      'ko': '예레미야',
      'en': 'Jeremiah',
      'zh': '耶肋米亚',
      'vi': 'Giê-rê-mi-a',
      'es': 'Jeremías',
      'pt': 'Jeremias',
    },
    '哀歌': {
      'ko': '예레미야 애가',
      'en': 'Lamentations',
      'zh': '哀歌',
      'vi': 'Ca Thương',
      'es': 'Lamentaciones',
      'pt': 'Lamentações',
    },
    'エゼキエル': {
      'ko': '에제키엘',
      'en': 'Ezekiel',
      'zh': '厄则克耳',
      'vi': 'Ê-xê-ki-ên',
      'es': 'Ezequiel',
      'pt': 'Ezequiel',
    },
    'ダニエル': {
      'ko': '다니엘',
      'en': 'Daniel',
      'zh': '达尼尔',
      'vi': 'Đa-ni-en',
      'es': 'Daniel',
      'pt': 'Daniel',
    },
    'ホセア': {
      'ko': '호세아',
      'en': 'Hosea',
      'zh': '欧瑟亚',
      'vi': 'Ô-sê',
      'es': 'Oseas',
      'pt': 'Oséias',
    },
    'ヨエル': {
      'ko': '요엘',
      'en': 'Joel',
      'zh': '岳厄尔',
      'vi': 'Giô-ên',
      'es': 'Joel',
      'pt': 'Joel',
    },
    'アモス': {
      'ko': '아모스',
      'en': 'Amos',
      'zh': '亚毛斯',
      'vi': 'A-mốt',
      'es': 'Amós',
      'pt': 'Amós',
    },
    'オバデヤ': {
      'ko': '오바드야',
      'en': 'Obadiah',
      'zh': '亚北底亚',
      'vi': 'Áp-đia',
      'es': 'Abdías',
      'pt': 'Obadias',
    },
    'ヨナ': {
      'ko': '요나',
      'en': 'Jonah',
      'zh': '约纳',
      'vi': 'Giô-na',
      'es': 'Jonás',
      'pt': 'Jonas',
    },
    'ミカ': {
      'ko': '미카',
      'en': 'Micah',
      'zh': '米该亚',
      'vi': 'Mi-chê',
      'es': 'Miqueas',
      'pt': 'Miquéias',
    },
    'ナホム': {
      'ko': '나훔',
      'en': 'Nahum',
      'zh': '纳鸿',
      'vi': 'Na-hum',
      'es': 'Nahúm',
      'pt': 'Naum',
    },
    'ハバクク': {
      'ko': '하바쿡',
      'en': 'Habakkuk',
      'zh': '哈巴谷',
      'vi': 'Ha-ba-cúc',
      'es': 'Habacuc',
      'pt': 'Habacuque',
    },
    'ゼファニヤ': {
      'ko': '스바니야',
      'en': 'Zephaniah',
      'zh': '索福尼亚',
      'vi': 'Xô-phô-ni-a',
      'es': 'Sofonías',
      'pt': 'Sofonias',
    },
    'ハガイ': {
      'ko': '하까이',
      'en': 'Haggai',
      'zh': '哈盖',
      'vi': 'A-ghê',
      'es': 'Hageo',
      'pt': 'Ageu',
    },
    'ゼカリヤ': {
      'ko': '즈카리야',
      'en': 'Zechariah',
      'zh': '匝加利亚',
      'vi': 'Xa-cha-ri-a',
      'es': 'Zacarías',
      'pt': 'Zacarias',
    },
    'マラキ': {
      'ko': '말라키',
      'en': 'Malachi',
      'zh': '玛拉基亚',
      'vi': 'Ma-la-chi',
      'es': 'Malaquías',
      'pt': 'Malaquias',
    },
    // 신약
    'マタイ': {
      'ko': '마태오',
      'en': 'Matthew',
      'zh': '玛窦福音',
      'vi': 'Mátthêu',
      'es': 'Mateo',
      'pt': 'Mateus',
    },
    'マルコ': {
      'ko': '마르코',
      'en': 'Mark',
      'zh': '马尔谷福音',
      'vi': 'Mác-cô',
      'es': 'Marcos',
      'pt': 'Marcos',
    },
    'ルカ': {
      'ko': '루카',
      'en': 'Luke',
      'zh': '路加福音',
      'vi': 'Lu-ca',
      'es': 'Lucas',
      'pt': 'Lucas',
    },
    'ヨハネ': {
      'ko': '요한',
      'en': 'John',
      'zh': '若望福音',
      'vi': 'Gioan',
      'es': 'Juan',
      'pt': 'João',
    },
    '使徒言行録': {
      'ko': '사도행전',
      'en': 'Acts',
      'zh': '宗徒大事录',
      'vi': 'Công Vụ',
      'es': 'Hechos',
      'pt': 'Atos',
    },
    'ローマ': {
      'ko': '로마',
      'en': 'Romans',
      'zh': '罗马书',
      'vi': 'Rôma',
      'es': 'Romanos',
      'pt': 'Romanos',
    },
    'コリントの信徒への手紙一': {
      'ko': '고린토인들에게 보낸 첫째 편지',
      'en': '1 Corinthians',
      'zh': '格林多前书',
      'vi': '1 Côrintô',
      'es': '1 Corintios',
      'pt': '1 Coríntios',
    },
    'コリントの信徒への手紙二': {
      'ko': '고린토인들에게 보낸 둘째 편지',
      'en': '2 Corinthians',
      'zh': '格林多后书',
      'vi': '2 Côrintô',
      'es': '2 Corintios',
      'pt': '2 Coríntios',
    },
    'ガラテヤ': {
      'ko': '갈라티아인들에게 보낸 편지',
      'en': 'Galatians',
      'zh': '迦拉达书',
      'vi': 'Galát',
      'es': 'Gálatas',
      'pt': 'Gálatas',
    },
    'エフェソ': {
      'ko': '에페소인들에게 보낸 편지',
      'en': 'Ephesians',
      'zh': '厄弗所书',
      'vi': 'Êphêsô',
      'es': 'Efesios',
      'pt': 'Efésios',
    },
    'フィリピ': {
      'ko': '필리피인들에게 보낸 편지',
      'en': 'Philippians',
      'zh': '斐理伯书',
      'vi': 'Philípphê',
      'es': 'Filipenses',
      'pt': 'Filipenses',
    },
    'コロサイ': {
      'ko': '콜로새인들에게 보낸 편지',
      'en': 'Colossians',
      'zh': '哥罗森书',
      'vi': 'Côlôxê',
      'es': 'Colosenses',
      'pt': 'Colossenses',
    },
    'テサロニケの信徒への手紙一': {
      'ko': '테살로니카인들에게 보낸 첫째 편지',
      'en': '1 Thessalonians',
      'zh': '得撒洛尼前书',
      'vi': '1 Têxalônica',
      'es': '1 Tesalonicenses',
      'pt': '1 Tessalonicenses',
    },
    'テサロニケの信徒への手紙二': {
      'ko': '테살로니카인들에게 보낸 둘째 편지',
      'en': '2 Thessalonians',
      'zh': '得撒洛尼后书',
      'vi': '2 Têxalônica',
      'es': '2 Tesalonicenses',
      'pt': '2 Tessalonicenses',
    },
    'テモテへの手紙一': {
      'ko': '티모테오에게 보낸 첫째 편지',
      'en': '1 Timothy',
      'zh': '弟茂德前书',
      'vi': '1 Timôthê',
      'es': '1 Timoteo',
      'pt': '1 Timóteo',
    },
    'テモテへの手紙二': {
      'ko': '티모테오에게 보낸 둘째 편지',
      'en': '2 Timothy',
      'zh': '弟茂德后书',
      'vi': '2 Timôthê',
      'es': '2 Timoteo',
      'pt': '2 Timóteo',
    },
    'テトス': {
      'ko': '티토에게 보낸 편지',
      'en': 'Titus',
      'zh': '弟铎书',
      'vi': 'Títô',
      'es': 'Tito',
      'pt': 'Tito',
    },
    'フィレモン': {
      'ko': '필레몬에게 보낸 편지',
      'en': 'Philemon',
      'zh': '费肋孟书',
      'vi': 'Philêmon',
      'es': 'Filemón',
      'pt': 'Filemom',
    },
    'ヘブライ': {
      'ko': '히브리인들에게 보낸 편지',
      'en': 'Hebrews',
      'zh': '希伯来书',
      'vi': 'Hêbrơ',
      'es': 'Hebreos',
      'pt': 'Hebreus',
    },
    'ヤコブ': {
      'ko': '야고보',
      'en': 'James',
      'zh': '雅各伯书',
      'vi': 'Giacôbê',
      'es': 'Santiago',
      'pt': 'Tiago',
    },
    'ペトロの手紙一': {
      'ko': '베드로의 첫째 편지',
      'en': '1 Peter',
      'zh': '伯多禄前书',
      'vi': '1 Phêrô',
      'es': '1 Pedro',
      'pt': '1 Pedro',
    },
    'ペトロの手紙二': {
      'ko': '베드로의 둘째 편지',
      'en': '2 Peter',
      'zh': '伯多禄后书',
      'vi': '2 Phêrô',
      'es': '2 Pedro',
      'pt': '2 Pedro',
    },
    'ヨハネの手紙一': {
      'ko': '요한의 첫째 편지',
      'en': '1 John',
      'zh': '若望一书',
      'vi': '1 Gioan',
      'es': '1 Juan',
      'pt': '1 João',
    },
    'ヨハネの手紙二': {
      'ko': '요한의 둘째 편지',
      'en': '2 John',
      'zh': '若望二书',
      'vi': '2 Gioan',
      'es': '2 Juan',
      'pt': '2 João',
    },
    'ヨハネの手紙三': {
      'ko': '요한의 셋째 편지',
      'en': '3 John',
      'zh': '若望三书',
      'vi': '3 Gioan',
      'es': '3 Juan',
      'pt': '3 João',
    },
    'ユダ': {
      'ko': '유다의 편지',
      'en': 'Jude',
      'zh': '犹达书',
      'vi': 'Giuđa',
      'es': 'Judas',
      'pt': 'Judas',
    },
    'ヨハネの黙示録': {
      'ko': '요한 묵시록',
      'en': 'Revelation',
      'zh': '默示录',
      'vi': 'Khải Huyền',
      'es': 'Apocalipsis',
      'pt': 'Apocalipse',
    },
  };
}

/// Firestore에 묵상 가이드 캐싱
Future<void> _cacheGuide(
  String cacheKey,
  String guide,
  MeditationGuideParams params,
) async {
  try {
    await FirebaseFirestore.instance
        .collection('meditation_guides')
        .doc(cacheKey)
        .set({
          'guide': guide,
          'dateKey': params.dateKey,
          'readingType': params.readingType,
          'reference': params.reference,
          'title': params.title,
          'language': params.language,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  } catch (e, stackTrace) {
    AppLogger.error(
      '[MeditationGuideProvider] 캐시 저장 실패: $cacheKey',
      e,
      stackTrace,
    );
    // 캐시 저장 실패해도 에러를 던지지 않음 (이미 guide는 반환됨)
  }
}

/// 기본 묵상 가이드 (에러 발생 시)
String _getDefaultMeditationGuide(String language) {
  switch (language) {
    case 'ja':
      return '''今日のテーマ：神様の言葉を聞く

今日の問い：
・私は今、何を急いでいるだろうか
・神様の言葉に耳を傾けているだろうか

今日の黙想：
静かな時間の中で、
自分の心の動きを見つめてみましょう。
神様の言葉があなたの心에 어떻게響いているか感じてみてください。''';
    case 'ko':
      return '''오늘의 주제：하느님의 말씀을 듣기

오늘의 질문：
・나는 지금 무엇을 서두르고 있을까
・하느님의 말씀에 귀 기울이고 있을까

오늘의 묵상：
고요한 시간 속에서,
자신의 마음의 움직임을 살펴보세요.
하느님의 말씀이 당신의 마음에 어떻게 울려 퍼지는지 느껴보세요.''';
    case 'en':
      return '''Today's Theme: Listening to God's Word

Today's Questions:
・What am I rushing about now?
・Am I listening to God's word?

Today's Meditation:
In a quiet moment,
observe the movements of your heart.
Feel how God's word resonates in your heart.''';
    default:
      return _getDefaultMeditationGuide('ja');
  }
}
