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
      
      // 언어별 접두사 및 예시
      String prefixRequirement = '';
      String example = '';
      switch (targetLanguage) {
        case 'ko':
          prefixRequirement = '- "성" 접두사를 반드시 포함하여 반환하세요 (예: "성 요한", "성 마리아")';
          example = '성 요한, 성 마리아';
          break;
        case 'zh':
          prefixRequirement = '- "聖" 접두사를 반드시 포함하여 반환하세요 (예: "聖若望", "聖瑪利亞")';
          example = '聖若望, 聖瑪利亞';
          break;
        case 'vi':
          prefixRequirement = '- "Thánh" 접두사를 반드시 포함하여 반환하세요 (예: "Thánh Gioan", "Thánh Maria")';
          example = 'Thánh Gioan, Thánh Maria';
          break;
        case 'es':
          prefixRequirement = '- "San" 또는 "Santa" 접두사를 반드시 포함하여 반환하세요 (예: "San Juan", "Santa María")';
          example = 'San Juan, Santa María';
          break;
        case 'pt':
          prefixRequirement = '- "São" 또는 "Santa" 접두사를 반드시 포함하여 반환하세요 (예: "São João", "Santa Maria")';
          example = 'São João, Santa Maria';
          break;
      }

      final prompt =
          '''다음 가톨릭 성인 이름을 $languageName로 정확하게 번역해주세요.

일본어 이름: $japaneseName
${englishName != null ? '영어 이름: $englishName' : ''}

중요:
- 위에 제공된 정확한 성인 이름을 번역하세요. 다른 유사한 이름의 성인과 혼동하지 마세요.
- 전체 이름을 정확히 번역하세요 (예: "프란치스카 사베리아 카브리니"는 "프란치스코 하비에르"와 다른 성인입니다).
- 이름의 모든 부분(이름, 중간 이름, 성)을 정확히 번역하세요.

요구사항:
- 가톨릭 교회에서 공식적으로 사용하는 $languageName 성인 이름을 사용하세요
- 가톨릭 전례에서 사용하는 표준 $languageName 이름을 사용하세요
${prefixRequirement.isNotEmpty ? '$prefixRequirement' : ''}
${example.isNotEmpty ? '- 예시 형식: $example' : ''}
- 번역된 이름만 반환하세요 (설명이나 추가 텍스트 없이)

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
                  '당신은 가톨릭 성인 이름 번역 전문가입니다. 제공된 정확한 성인 이름을 다른 유사한 이름과 혼동하지 않고, 각 언어의 표준 가톨릭 용어를 사용하여 정확하게 번역합니다. 이름의 모든 부분을 정확히 번역합니다.',
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

      // 월 이름 변환
      final monthNames = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final monthName = monthNames[month];

      final prompt =
          '''$year년 $month월 $day일 ($monthName $day)의 가톨릭 성인을 로마 순교록(Roman Martyrology)과 교회 전례력에 따라 정확하게 알려주세요.

중요:
- $month월 $day일에 실제로 기념되는 정확한 성인만 포함하세요
- 유사한 이름의 다른 성인과 혼동하지 마세요 (예: 12월 22일은 "프란치스카 사베리아 카브리니"이며 "프란치스코 하비에르"와는 다른 성인입니다)
- 성인의 전체 이름을 정확히 제공하세요

요구사항:
- $month월 $day일에 기념하는 성인만 포함
- 성인의 직함(교황, 주교, 순교자, 동정녀, 수녀 등)을 이름에 포함
- $languageName와 영어 이름 모두 제공
- 가톨릭 교회에서 공식적으로 인정하는 성인만 포함

JSON 형식으로만 응답 (마크다운 없이):
{"saints": [{"name": "$languageName 이름", "nameEn": "English name", "type": "optional_memorial", "imageUrl": null}], "liturgyTakesPrecedence": false, "liturgicalNote": ""}''';

      AppLogger.debug('[OpenAIService] 성인 검색 프롬프트: $monthName $day, $year ($languageCode)');

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
                  '''당신은 가톨릭 전례력 전문가입니다. 로마 순교록(Roman Martyrology)과 교회 전례력에 따라 정확한 성인 정보를 제공합니다.

중요:
- 요청받은 정확한 날짜의 성인만 포함하세요
- 비슷한 이름의 성인을 혼동하지 마세요
  * 예: 12월 22일은 "프란치스카 사베리아 카브리니" (Francesca Saveria Cabrini)이며, "프란치스코 하비에르" (Francis Xavier, 12월 3일)와는 완전히 다른 성인입니다
  * 예: Anastasius와 Anastasia는 다른 성인입니다
- 각 성인의 축일을 반드시 확인하세요
- 성인의 전체 이름을 정확히 제공하세요 (이름, 중간 이름, 성 모두 포함)
- JSON 형식으로만 응답하세요 (마크다운 없이)''',
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

  /// 오늘의 묵상 한마디 생성
  ///
  /// [gospelReference] 오늘의 복음 참조 (예: "마태오 1:18-24")
  /// [gospelTitle] 오늘의 복음 제목
  /// [saintNames] 오늘의 성인 이름 목록
  /// [language] 언어 코드: 'ja', 'ko', 'en' 등
  ///
  /// 반환: 묵상 한마디 텍스트
  Future<String> generateDailyReflection({
    String? gospelReference,
    String? gospelTitle,
    List<String>? saintNames,
    required String language,
  }) async {
    try {
      final apiKey = OpenAIApiKey.apiKey;
      if (apiKey == null) {
        throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
      }

      final languageName = _getLanguageName(language);

      // 프롬프트 생성
      final buffer = StringBuffer();
      buffer.writeln('오늘의 묵상 한마디를 작성해주세요.');
      buffer.writeln();

      if (gospelReference != null && gospelReference.isNotEmpty) {
        buffer.writeln('오늘의 복음: $gospelReference');
        if (gospelTitle != null && gospelTitle.isNotEmpty) {
          buffer.writeln('복음 제목: $gospelTitle');
        }
      }

      if (saintNames != null && saintNames.isNotEmpty) {
        buffer.writeln('오늘의 성인: ${saintNames.join(', ')}');
      }

      buffer.writeln();
      buffer.writeln('요구사항:');
      buffer.writeln('- $languageName로 작성하세요');
      buffer.writeln('- 2-3문장으로 간결하게 작성하세요');
      buffer.writeln('- 오늘 하루를 시작하며 마음에 새길 수 있는 따뜻한 메시지');
      buffer.writeln('- 복음의 핵심 메시지나 성인의 가르침을 바탕으로 작성');
      buffer.writeln('- 일상생활에 적용할 수 있는 실천적인 내용 포함');
      buffer.writeln('- 묵상 한마디만 반환하세요 (제목이나 설명 없이)');

      final prompt = buffer.toString();

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
                  '당신은 가톨릭 신앙의 묵상 가이드를 작성하는 전문가입니다. 하루를 시작하며 마음에 새길 수 있는 따뜻하고 영감을 주는 짧은 묵상 한마디를 작성합니다.',
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
              '[OpenAIService] 묵상 한마디 생성 성공 ($language)',
            );
            return content.trim();
          }
        }
      }

      throw Exception('GPT 응답에서 내용을 찾을 수 없습니다.');
    } catch (e, stackTrace) {
      AppLogger.error(
        '[OpenAIService] 묵상 한마디 생성 실패 ($language)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
