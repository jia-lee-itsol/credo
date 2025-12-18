import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saint_feast_day_model.dart';
import '../../services/logger_service.dart';
import '../../utils/openai_api_key.dart';

/// 성인 상세 정보 서비스
/// ChatGPT를 사용하여 성인의 상세 정보를 가져옵니다.
class SaintDetailService {
  final Dio _dio;

  SaintDetailService({Dio? dio}) : _dio = dio ?? Dio();

  /// ChatGPT를 사용하여 성인 상세 정보 가져오기
  ///
  /// [saint] 성인 모델
  /// [languageCode] 언어 코드
  ///
  /// 반환: 성인 상세 정보 (JSON 형식)
  Future<SaintDetailInfo?> getSaintDetail(
    SaintFeastDayModel saint,
    String languageCode,
  ) async {
    try {
      final apiKey = OpenAIApiKey.apiKey;
      if (apiKey == null) {
        AppLogger.warning('[SaintDetailService] OPENAI_API_KEY가 설정되지 않았습니다.');
        return null;
      }

      // 캐시 키 생성
      final cacheKey =
          'saint_detail_${saint.month}_${saint.day}_${saint.name.hashCode}_$languageCode';

      // SharedPreferences에서 캐시 확인
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null && cachedJson.isNotEmpty) {
        AppLogger.debug(
          '[SaintDetailService] 캐시에서 성인 상세 정보 로드: ${saint.name}',
        );
        try {
          return SaintDetailInfo.fromJson(cachedJson);
        } catch (e) {
          AppLogger.warning(
            '[SaintDetailService] 캐시 파싱 실패, 새로 가져오기: ${saint.name}',
          );
        }
      }

      final saintName = saint.getName(languageCode);
      final englishName = saint.nameEn ?? saint.name;
      final languageName = _getLanguageName(languageCode);

      final prompt = '''다음 가톨릭 성인에 대한 상세 정보를 $languageName로 제공해주세요.

성인 이름: $saintName (English: $englishName)
축일: ${saint.month}월 ${saint.day}일
축일 유형: ${saint.type}

다음 정보를 포함해주세요:
1. 성인의 생애와 배경
2. 성인이 기억되는 이유 (주요 업적, 순교, 기적 등)
3. 성인의 수호 영역 (예: 학생, 여행자, 병자 등)
4. 성인과 관련된 기도문이나 명언
5. 성인을 기리는 방법

JSON 형식으로 반환해주세요:
{
  "biography": "생애와 배경",
  "achievements": "주요 업적이나 기억되는 이유",
  "patronage": ["수호 영역1", "수호 영역2"],
  "prayer": "기도문이나 명언",
  "howToHonor": "성인을 기리는 방법"
}

설명이나 추가 텍스트 없이 JSON만 반환해주세요.''';

      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
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
                  '당신은 가톨릭 성인 전문가입니다. 정확하고 상세한 성인 정보를 제공합니다. JSON 형식으로만 응답합니다.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
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
            // JSON 파싱 (코드 블록이나 마크다운 제거)
            String cleanJson = content.trim();
            if (cleanJson.startsWith('```')) {
              final lines = cleanJson.split('\n');
              cleanJson = lines
                  .where((line) => !line.trim().startsWith('```'))
                  .join('\n')
                  .trim();
            }
            // JSON 객체만 추출
            final jsonStart = cleanJson.indexOf('{');
            final jsonEnd = cleanJson.lastIndexOf('}');
            if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
              cleanJson = cleanJson.substring(jsonStart, jsonEnd + 1);
            }

            // 캐시에 저장
            await prefs.setString(cacheKey, cleanJson);

            AppLogger.debug(
              '[SaintDetailService] 성인 상세 정보 생성 성공: ${saint.name}',
            );
            return SaintDetailInfo.fromJson(cleanJson);
          }
        }
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[SaintDetailService] 성인 상세 정보 생성 실패: ${saint.name}',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// 언어 코드를 언어 이름으로 변환
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'vi':
        return 'Tiếng Việt';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      default:
        return '日本語';
    }
  }
}

/// 성인 상세 정보 모델
class SaintDetailInfo {
  final String biography;
  final String achievements;
  final List<String> patronage;
  final String prayer;
  final String howToHonor;

  const SaintDetailInfo({
    required this.biography,
    required this.achievements,
    required this.patronage,
    required this.prayer,
    required this.howToHonor,
  });

  factory SaintDetailInfo.fromJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SaintDetailInfo(
        biography: json['biography'] as String? ?? '',
        achievements: json['achievements'] as String? ?? '',
        patronage: (json['patronage'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        prayer: json['prayer'] as String? ?? '',
        howToHonor: json['howToHonor'] as String? ?? '',
      );
    } catch (e) {
      AppLogger.error(
        '[SaintDetailInfo] JSON 파싱 실패',
        e,
        null,
      );
      return const SaintDetailInfo(
        biography: '',
        achievements: '',
        patronage: [],
        prayer: '',
        howToHonor: '',
      );
    }
  }
}

