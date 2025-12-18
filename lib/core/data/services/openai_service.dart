import 'package:dio/dio.dart';
import '../../utils/openai_api_key.dart';
import '../../services/logger_service.dart';

/// OpenAI API 서비스
/// GPT를 사용하여 묵상 가이드를 생성합니다.
class OpenAIService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.openai.com/v1';

  OpenAIService({Dio? dio}) : _dio = dio ?? Dio();

  /// 묵상 가이드 생성
  ///
  /// [readingType] 독서 타입: 'firstReading', 'psalm', 'secondReading', 'gospel'
  /// [reference] 성경 구절 참조 (예: "イザヤ 48:17-19")
  /// [title] 독서 제목
  /// [language] 언어 코드: 'ja', 'ko', 'en' 등
  ///
  /// 반환: 묵상 가이드 텍스트 (성경 문구는 포함하지 않음)
  Future<String> generateMeditationGuide({
    required String readingType,
    required String reference,
    String? title,
    required String language,
  }) async {
    try {
      final apiKey = OpenAIApiKey.apiKey;
      if (apiKey == null) {
        throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
      }

      // 언어별 프롬프트 설정
      final languageName = _getLanguageName(language);
      final readingTypeName = _getReadingTypeName(readingType, language);

      final prompt =
          '''당신은 가톨릭 신앙의 묵상 가이드를 작성하는 전문가입니다.

오늘의 $readingTypeName는 "$reference"입니다.
${title != null ? '제목: $title' : ''}

다음 형식으로 묵상 가이드를 작성해주세요. 성경 본문을 직접 인용하지 말고, 그 의미와 메시지를 바탕으로 묵상 가이드를 작성해주세요.

형식:
${language == 'ja'
              ? '今日のテーマ：[주제]\n\n今日の問い：\n・[질문 1]\n・[질문 2]\n\n今日の黙想：\n[묵상 내용]'
              : language == 'ko'
              ? '오늘의 주제：[주제]\n\n오늘의 질문：\n・[질문 1]\n・[질문 2]\n\n오늘의 묵상：\n[묵상 내용]'
              : 'Today\'s Theme: [Theme]\n\nToday\'s Questions:\n・[Question 1]\n・[Question 2]\n\nToday\'s Meditation:\n[Meditation content]'}

요구사항:
- 성경 본문을 직접 인용하지 마세요
- 성경 구절의 의미와 메시지를 바탕으로 묵상 가이드를 작성하세요
- 실용적이고 개인적인 묵상을 도울 수 있는 내용으로 작성하세요
- $languageName로 작성하세요
- 간결하고 명확하게 작성하세요''';

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 가톨릭 신앙의 묵상 가이드를 작성하는 전문가입니다. 성경 본문을 직접 인용하지 않고, 그 의미와 메시지를 바탕으로 실용적인 묵상 가이드를 작성합니다.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            AppLogger.debug(
              '[OpenAIService] 묵상 가이드 생성 성공: $readingType ($language)',
            );
            return content.trim();
          }
        }
      }

      throw Exception('GPT 응답에서 내용을 찾을 수 없습니다.');
    } catch (e, stackTrace) {
      AppLogger.error(
        '[OpenAIService] 묵상 가이드 생성 실패: $readingType ($language)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 언어 코드를 언어 이름으로 변환
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '일본어';
      case 'ko':
        return '한국어';
      case 'en':
        return '영어';
      case 'zh':
        return '중국어';
      case 'vi':
        return '베트남어';
      case 'es':
        return '스페인어';
      case 'pt':
        return '포르투갈어';
      default:
        return '일본어';
    }
  }

  /// 독서 타입을 언어별 이름으로 변환
  String _getReadingTypeName(String readingType, String language) {
    switch (readingType) {
      case 'firstReading':
        switch (language) {
          case 'ja':
            return '第1朗読';
          case 'ko':
            return '제1독서';
          case 'en':
            return 'First Reading';
          default:
            return '第1朗読';
        }
      case 'psalm':
        switch (language) {
          case 'ja':
            return '答唱詩編';
          case 'ko':
            return '화답송';
          case 'en':
            return 'Responsorial Psalm';
          default:
            return '答唱詩編';
        }
      case 'secondReading':
        switch (language) {
          case 'ja':
            return '第2朗読';
          case 'ko':
            return '제2독서';
          case 'en':
            return 'Second Reading';
          default:
            return '第2朗読';
        }
      case 'gospel':
        switch (language) {
          case 'ja':
            return '福音';
          case 'ko':
            return '복음';
          case 'en':
            return 'Gospel';
          default:
            return '福音';
        }
      default:
        return readingType;
    }
  }

  /// 성인 이름 번역
  ///
  /// [japaneseName] 일본어 성인 이름
  /// [englishName] 영어 성인 이름 (있으면 제공)
  /// [targetLanguage] 대상 언어 코드: 'ko', 'zh', 'vi', 'es', 'pt'
  ///
  /// 반환: 번역된 성인 이름
  Future<String> translateSaintName({
    required String japaneseName,
    String? englishName,
    required String targetLanguage,
  }) async {
    try {
      final apiKey = OpenAIApiKey.apiKey;
      if (apiKey == null) {
        throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
      }

      final languageName = _getLanguageName(targetLanguage);

      final prompt =
          '''다음 가톨릭 성인 이름을 $languageName로 번역해주세요.

일본어: $japaneseName
${englishName != null ? '영어: $englishName' : ''}

요구사항:
- 가톨릭 교회에서 공식적으로 사용하는 $languageName 성인 이름을 사용하세요
- 성인 이름의 표준 번역을 사용하세요
- "聖" (성) 같은 접두사는 $languageName 관례에 맞게 번역하세요
- 번역된 이름만 반환하세요 (설명 없이)

$languageName 이름:''';

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 가톨릭 성인 이름 번역 전문가입니다. 각 언어의 표준 가톨릭 용어를 사용하여 정확하게 번역합니다.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 100,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            AppLogger.debug(
              '[OpenAIService] 성인 이름 번역 성공: $japaneseName -> $targetLanguage',
            );
            return content.trim();
          }
        }
      }

      throw Exception('GPT 응답에서 내용을 찾을 수 없습니다.');
    } catch (e, stackTrace) {
      AppLogger.error(
        '[OpenAIService] 성인 이름 번역 실패: $japaneseName ($targetLanguage)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// ChatGPT를 사용하여 특정 날짜의 성인 축일 검색
  ///
  /// [date] 검색할 날짜
  /// [languageCode] 언어 코드: 'ja', 'ko', 'en', 'zh', 'vi', 'es', 'pt'
  ///
  /// 반환: 성인 이름 목록 (JSON 형식 문자열)
  Future<String> searchSaintsForDate({
    required DateTime date,
    required String languageCode,
  }) async {
    try {
      final apiKey = OpenAIApiKey.apiKey;
      if (apiKey == null) {
        throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
      }

      final languageName = _getLanguageName(languageCode);
      final month = date.month;
      final day = date.day;
      final year = date.year;

      final prompt =
          '''What saints are celebrated on $month/$day according to the Catholic liturgical calendar?

RULES:
1. First, list saints from the GENERAL ROMAN CALENDAR (Universal):
   - Solemnities (대축일/solemnity)
   - Feasts (축일/feast)
   - Obligatory Memorials (의무 기념일/obligatory_memorial)

2. Then, also include well-known saints celebrated regionally or as Optional Memorials:
   - Optional Memorials (선택 기념일/optional_memorial)
   - Mark these with type "optional_memorial"

3. Set "liturgyTakesPrecedence" to true if this date falls during:
   - Advent weekdays (Dec 17-24)
   - Christmas Octave
   - Lent weekdays
   - Holy Week
   - Easter Octave
   - Other major liturgical celebrations that supersede saint memorials

Provide names in $languageName with English reference.

Return ONLY valid JSON (no markdown, no explanation):
{"saints": [{"name": "성인 이름 in $languageName", "nameEn": "English name", "type": "solemnity|feast|obligatory_memorial|optional_memorial", "imageUrl": null}], "liturgyTakesPrecedence": true|false, "liturgicalNote": "explanation if liturgy takes precedence"}''';

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are an expert in the Catholic Liturgical Calendar.

Your task is to identify saints celebrated on a given date:

1. UNIVERSAL celebrations (General Roman Calendar):
   - Solemnities (대축일): Highest rank
   - Feasts (축일): Second rank
   - Obligatory Memorials (의무 기념일): Third rank

2. OPTIONAL celebrations (also include these):
   - Optional Memorials (선택 기념일): Can be celebrated optionally
   - Well-known regional saints

Always indicate if liturgy takes precedence on that date (Advent Dec 17-24, Lent weekdays, Holy Week, Octaves, etc.).

Return only valid JSON without markdown formatting.''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,
          'max_tokens': 1000,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            AppLogger.debug(
              '[OpenAIService] 성인 검색 성공: $year-$month-$day ($languageCode)',
            );
            return content.trim();
          }
        }
      }

      throw Exception('GPT 응답에서 내용을 찾을 수 없습니다.');
    } catch (e, stackTrace) {
      AppLogger.error(
        '[OpenAIService] 성인 검색 실패: $date ($languageCode)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// ChatGPT를 사용하여 특정 날짜의 전례력 정보 확인
  ///
  /// [date] 확인할 날짜
  /// [languageCode] 언어 코드
  ///
  /// 반환: 전례력 정보 (JSON 형식 문자열)
  Future<String> getLiturgyInfoForDate({
    required DateTime date,
    required String languageCode,
  }) async {
    try {
      final apiKey = OpenAIApiKey.apiKey;
      if (apiKey == null) {
        throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
      }

      final month = date.month;
      final day = date.day;
      final year = date.year;

      final prompt = '''$year년 $month월 $day일 가톨릭 전례력을 확인해주세요.

요구사항:
- 해당 날짜의 전례 시즌을 확인해주세요 (ordinary, advent, christmas, lent, easter, pentecost)
- 전례 색상을 확인해주세요 (green, purple, gold, red, white)
- 특별한 축일이 있는지 확인해주세요 (성금요일, 수난 주일, 순교자 축일 등)
- JSON 형식으로 반환해주세요
- 형식: {"season": "ordinary|advent|christmas|lent|easter|pentecost", "colorType": "green|purple|gold|red|white", "specialDay": true|false, "specialDayType": "martyr|passion|saint|null", "seasonName": "시즌 이름"}
- 설명이나 추가 텍스트 없이 JSON만 반환해주세요''';

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 가톨릭 전례력 전문가입니다. 정확한 전례 시즌과 색상 정보를 제공합니다. JSON 형식으로만 응답합니다.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 300,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            AppLogger.debug('[OpenAIService] 전례력 확인 성공: $year-$month-$day');
            return content.trim();
          }
        }
      }

      throw Exception('GPT 응답에서 내용을 찾을 수 없습니다.');
    } catch (e, stackTrace) {
      AppLogger.error('[OpenAIService] 전례력 확인 실패: $date', e, stackTrace);
      rethrow;
    }
  }

  /// 성인 축일 축하 메시지 생성
  ///
  /// [saintName] 성인 이름
  /// [userBaptismalName] 사용자 세례명 (옵션)
  /// [language] 언어 코드: 'ja', 'ko', 'en' 등
  ///
  /// 반환: 축하 메시지 텍스트
  Future<String> generateFeastDayMessage({
    required String saintName,
    String? userBaptismalName,
    required String language,
  }) async {
    try {
      final apiKey = OpenAIApiKey.apiKey;
      if (apiKey == null) {
        throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
      }

      // 언어별 프롬프트 설정
      final languageName = _getLanguageName(language);

      String prompt;
      if (userBaptismalName != null &&
          (saintName.toLowerCase().contains(userBaptismalName.toLowerCase()) ||
              userBaptismalName.toLowerCase().contains(
                saintName.toLowerCase(),
              ))) {
        // 세례명이 성인 이름과 일치하는 경우
        prompt =
            '''당신은 가톨릭 신앙의 축하 메시지를 작성하는 전문가입니다.

오늘은 성인 $saintName의 축일입니다. 사용자의 세례명이 $userBaptismalName으로 이 성인과 같습니다.

$languageName로 간결하고 따뜻한 축하 메시지를 작성해주세요. 
- 2-3문장 정도로 간결하게
- 축일을 축하하는 따뜻한 메시지
- 성인의 삶과 가르침에서 영감을 받은 내용
- 개인적인 축하 메시지 느낌
- $languageName로 작성하세요''';
      } else {
        // 일반적인 축일 축하 메시지
        prompt =
            '''당신은 가톨릭 신앙의 축하 메시지를 작성하는 전문가입니다.

오늘은 성인 $saintName의 축일입니다.

$languageName로 간결하고 따뜻한 축하 메시지를 작성해주세요. 
- 2-3문장 정도로 간결하게
- 축일을 축하하는 따뜻한 메시지
- 성인의 삶과 가르침에서 영감을 받은 내용
- $languageName로 작성하세요''';
      }

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 가톨릭 신앙의 축하 메시지를 작성하는 전문가입니다. 간결하고 따뜻한 축하 메시지를 작성합니다.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.8,
          'max_tokens': 200,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            AppLogger.debug(
              '[OpenAIService] 축하 메시지 생성 성공: $saintName ($language)',
            );
            return content.trim();
          }
        }
      }

      throw Exception('GPT 응답에서 내용을 찾을 수 없습니다.');
    } catch (e, stackTrace) {
      AppLogger.error(
        '[OpenAIService] 축하 메시지 생성 실패: $saintName ($language)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
