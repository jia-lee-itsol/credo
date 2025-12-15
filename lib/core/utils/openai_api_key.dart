import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/logger_service.dart';

/// OpenAI API 키 유틸리티
class OpenAIApiKey {
  OpenAIApiKey._();

  /// OpenAI API 키 가져오기
  /// .env 파일의 OPENAI_API_KEY 값을 반환합니다.
  static String? get apiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      AppLogger.warning('[OpenAIApiKey] OPENAI_API_KEY가 .env 파일에 설정되지 않았습니다.');
      return null;
    }
    return key;
  }

  /// OpenAI API 키가 설정되어 있는지 확인
  static bool get isConfigured {
    final key = dotenv.env['OPENAI_API_KEY'];
    return key != null && key.isNotEmpty;
  }

  /// OpenAI API 키 가져오기 (필수)
  /// 키가 없으면 Exception을 던집니다.
  static String get requiredApiKey {
    final key = apiKey;
    if (key == null) {
      throw Exception('OPENAI_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }
    return key;
  }
}
