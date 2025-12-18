import 'bible_reference_translator.dart';

/// 묵상 가이드 포맷팅 유틸리티
class MeditationGuideFormatter {
  /// 묵상 가이드 하단에 참고 말씀 추가
  static String addReferenceToGuide(String guide, String reference, String language) {
    final referenceText = formatReference(reference, language);
    return '$guide\n\n$referenceText';
  }

  /// 묵상 가이드에 참고 말씀이 있는지 확인하고, 없으면 추가
  static String ensureReferenceInGuide(
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
    return addReferenceToGuide(guide, reference, language);
  }

  /// 언어별 참고 말씀 키워드
  static List<String> _getReferenceKeywords(String language) {
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
  static String formatReference(String reference, String language) {
    // reference를 현재 언어로 변환
    final translatedReference = BibleReferenceTranslator.translateBibleReference(
      reference,
      language,
    );
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
}

