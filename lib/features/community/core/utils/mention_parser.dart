/// 댓글에서 @멘션을 파싱하는 유틸리티
class MentionParser {
  /// 텍스트에서 @멘션을 추출 (예: "@ユーザー名" 또는 "@test")
  /// 반환: 멘션된 사용자 이름 리스트
  static List<String> extractMentions(String text) {
    final mentions = <String>[];
    final regex = RegExp(r'@(\w+)', unicode: true);
    final matches = regex.allMatches(text);

    for (final match in matches) {
      final mention = match.group(1);
      if (mention != null && mention.isNotEmpty) {
        mentions.add(mention);
      }
    }

    return mentions;
  }

  /// 텍스트를 멘션 포함 위젯으로 변환할 수 있도록 파싱
  /// 반환: (일반 텍스트, 멘션된 사용자 이름) 튜플 리스트
  static List<({String text, bool isMention, String? mentionName})> parseText(
    String text,
  ) {
    final parts = <({String text, bool isMention, String? mentionName})>[];
    final regex = RegExp(r'@(\w+)', unicode: true);
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // 멘션 이전 텍스트
      if (match.start > lastIndex) {
        parts.add((
          text: text.substring(lastIndex, match.start),
          isMention: false,
          mentionName: null,
        ));
      }

      // 멘션 텍스트
      final mentionName = match.group(1);
      if (mentionName != null) {
        parts.add((
          text: match.group(0)!,
          isMention: true,
          mentionName: mentionName,
        ));
      }

      lastIndex = match.end;
    }

    // 마지막 텍스트
    if (lastIndex < text.length) {
      parts.add((
        text: text.substring(lastIndex),
        isMention: false,
        mentionName: null,
      ));
    }

    return parts;
  }
}
