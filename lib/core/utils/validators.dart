import '../constants/app_constants.dart';

/// 입력 유효성 검사 유틸리티
class Validators {
  Validators._();

  /// 이메일 유효성 검사
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メールアドレスを入力してください';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return '有効なメールアドレスを入力してください';
    }

    return null;
  }

  /// 비밀번호 유효성 검사
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }

    if (value.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }

    return null;
  }

  /// 닉네임 유효성 검사
  static String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ニックネームを入力してください';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.nicknameMinLength) {
      return 'ニックネームを入力してください';
    }

    if (trimmed.length > AppConstants.nicknameMaxLength) {
      return 'ニックネームは${AppConstants.nicknameMaxLength}文字以内で入力してください';
    }

    // 허용 문자: 일본어, 한글, 영숫자, 언더스코어, 하이픈
    final validCharsRegex = RegExp(r'^[\p{L}\p{N}_-]+$', unicode: true);
    if (!validCharsRegex.hasMatch(trimmed)) {
      return '使用できない文字が含まれています';
    }

    return null;
  }

  /// 투고 제목 유효성 검사
  static String? validatePostTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'タイトルを入力してください';
    }

    if (value.trim().length > AppConstants.postTitleMaxLength) {
      return 'タイトルは${AppConstants.postTitleMaxLength}文字以内で入力してください';
    }

    return null;
  }

  /// 투고 본문 유효성 검사
  static String? validatePostContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '本文を入力してください';
    }

    if (value.trim().length > AppConstants.postContentMaxLength) {
      return '本文は${AppConstants.postContentMaxLength}文字以内で入力してください';
    }

    return null;
  }

  /// 댓글 유효성 검사
  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'コメントを入力してください';
    }

    if (value.trim().length > AppConstants.commentMaxLength) {
      return 'コメントは${AppConstants.commentMaxLength}文字以内で入力してください';
    }

    return null;
  }

  /// 빈 값 검사
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// 공백만 있는지 검사
  static bool isOnlyWhitespace(String? value) {
    if (value == null) return true;
    return value.trim().isEmpty && value.isNotEmpty;
  }
}
