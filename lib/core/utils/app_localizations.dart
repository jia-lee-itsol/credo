import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/localization_service.dart';
import '../../shared/providers/locale_provider.dart';

/// 앱 다국어 지원 유틸리티
///
/// 사용 예:
/// ```dart
/// final l10n = ref.watch(appLocalizationsProvider);
/// Text(l10n.language.settings)
/// Text(l10n.language.switched(language: '日本語'))
/// ```
class AppLocalizations {
  final Locale locale;
  final Map<String, dynamic> _translations;

  AppLocalizations(this.locale, this._translations);

  /// BuildContext에서 AppLocalizations 가져오기
  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return _AppLocalizationsDelegate.instance.loadSync(locale);
  }

  /// 중첩된 키 접근을 위한 getter
  dynamic _getValue(String key) {
    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map<String, dynamic>) {
        value = value[k];
      } else {
        return null;
      }
    }

    return value;
  }

  /// 공통 번역
  CommonTranslations get common => CommonTranslations(_getValue('common'));

  /// 네비게이션 번역
  NavigationTranslations get navigation =>
      NavigationTranslations(_getValue('navigation'));

  /// 언어 설정 번역
  LanguageTranslations get language =>
      LanguageTranslations(_getValue('language'));

  /// 인증 번역
  AuthTranslations get auth => AuthTranslations(_getValue('auth'));

  /// 검증 번역
  ValidationTranslations get validation =>
      ValidationTranslations(_getValue('validation'));

  /// 커뮤니티 번역
  CommunityTranslations get community =>
      CommunityTranslations(_getValue('community'));

  /// 신고 번역
  ReportTranslations get report => ReportTranslations(_getValue('report'));

  /// 이미지 번역
  ImageTranslations get image => ImageTranslations(_getValue('image'));

  /// 프로필 번역
  ProfileTranslations get profile => ProfileTranslations(_getValue('profile'));

  /// 교회 번역
  ParishTranslations get parish => ParishTranslations(_getValue('parish'));

  /// 미사 번역
  MassTranslations get mass => MassTranslations(_getValue('mass'));

  /// QR 코드 번역
  QrTranslations get qr => QrTranslations(_getValue('qr'));

  /// 위치 번역
  LocationTranslations get location =>
      LocationTranslations(_getValue('location'));

  /// 검색 번역
  SearchTranslations get search => SearchTranslations(_getValue('search'));

  /// 앱 정보 번역
  AppTranslations get app => AppTranslations(_getValue('app'));
}

/// 앱 정보 번역
class AppTranslations {
  final dynamic _data;

  AppTranslations(this._data);

  String get name => _getString('name') ?? 'Credo';
  String get description =>
      _getString('description') ?? '日本全国のカトリック教会と信者をつなぐコミュニティアプリです。';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 공통 번역
class CommonTranslations {
  final dynamic _data;

  CommonTranslations(this._data);

  String get ok => _getString('ok') ?? 'OK';
  String get cancel => _getString('cancel') ?? 'Cancel';
  String get save => _getString('save') ?? 'Save';
  String get delete => _getString('delete') ?? 'Delete';
  String get edit => _getString('edit') ?? 'Edit';
  String get close => _getString('close') ?? 'Close';
  String get loading => _getString('loading') ?? 'Loading...';
  String get error => _getString('error') ?? 'Error';
  String get success => _getString('success') ?? 'Success';
  String get retry => _getString('retry') ?? 'Retry';
  String get search => _getString('search') ?? '検索';
  String get select => _getString('select') ?? '選択';
  String get add => _getString('add') ?? '追加';
  String get remove => _getString('remove') ?? '削除';
  String get send => _getString('send') ?? '送信';
  String get reset => _getString('reset') ?? 'リセット';
  String get apply => _getString('apply') ?? '適用';
  String get login => _getString('login') ?? 'ログイン';
  String get logout => _getString('logout') ?? 'ログアウト';
  String get guest => _getString('guest') ?? 'ゲスト';
  String get user => _getString('user') ?? 'ユーザー';
  String get required => _getString('required') ?? '必須';
  String get optional => _getString('optional') ?? '任意';
  String get notSet => _getString('notSet') ?? '未設定';
  String get small => _getString('small') ?? '小';
  String get medium => _getString('medium') ?? '中';
  String get large => _getString('large') ?? '大';
  String get extraLarge => _getString('extraLarge') ?? '特大';
  String get sampleText => _getString('sampleText') ?? 'サンプルテキスト';
  String get or => _getString('or') ?? 'または';
  String get pageNotFound => _getString('pageNotFound') ?? 'ページが見つかりません';
  String get backToHome => _getString('backToHome') ?? 'ホームへ戻る';
  String get noMassTimeInfo => _getString('noMassTimeInfo') ?? 'ミサ時間情報がありません';
  String get favoriteAdded => _getString('favoriteAdded') ?? 'お気に入りに追加しました';
  String get favoriteRemoved =>
      _getString('favoriteRemoved') ?? 'お気に入りから削除しました';
  String get commentHint => _getString('commentHint') ?? 'コメントを入力...';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 네비게이션 번역
class NavigationTranslations {
  final dynamic _data;

  NavigationTranslations(this._data);

  String get home => _getString('home') ?? 'ホーム';
  String get meditation => _getString('meditation') ?? '黙想';
  String get share => _getString('share') ?? '共有';
  String get church => _getString('church') ?? '教会';
  String get community => _getString('community') ?? 'コミュニティ';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 인증 번역
class AuthTranslations {
  final dynamic _data;

  AuthTranslations(this._data);

  String get signIn => _getString('signIn') ?? 'ログイン';
  String get signUp => _getString('signUp') ?? '新規登録';
  String get signOut => _getString('signOut') ?? 'ログアウト';
  String get signOutSuccess => _getString('signOutSuccess') ?? 'ログアウトしました';
  String get signInFailed => _getString('signInFailed') ?? 'ログインに失敗しました';
  String get signUpFailed => _getString('signUpFailed') ?? '登録に失敗しました';
  String get accountCreated => _getString('accountCreated') ?? 'アカウントを作成しました';
  String get loginRequired => _getString('loginRequired') ?? 'ログインが必要です';
  String get loginRequiredMessage =>
      _getString('loginRequiredMessage') ?? '投稿するにはログインが必要です。';
  String get loginRequiredQuestion =>
      _getString('loginRequiredQuestion') ?? '投稿するにはログインが必要です。ログインしますか？';
  String get continueAsGuest => _getString('continueAsGuest') ?? 'ゲストとして続ける';
  String get alreadyHaveAccount =>
      _getString('alreadyHaveAccount') ?? 'すでにアカウントをお持ちですか？';
  String get noAccount => _getString('noAccount') ?? 'アカウントをお持ちでないですか？';
  String get forgotPassword => _getString('forgotPassword') ?? 'パスワードをお忘れですか？';
  String get passwordReset => _getString('passwordReset') ?? 'パスワードリセット';
  String get passwordResetEmailSent =>
      _getString('passwordResetEmailSent') ?? 'パスワードリセットメールを送信しました';
  String get passwordResetEmailFailed =>
      _getString('passwordResetEmailFailed') ?? 'パスワードリセットメールの送信に失敗しました';
  String get email => _getString('email') ?? 'メールアドレス';
  String get emailHint => _getString('emailHint') ?? 'メールアドレスを入力してください';
  String get password => _getString('password') ?? 'パスワード';
  String get passwordConfirm => _getString('passwordConfirm') ?? 'パスワード（確認）';
  String get passwordMismatch =>
      _getString('passwordMismatch') ?? 'パスワードが一致しません';
  String get saveEmail => _getString('saveEmail') ?? 'メールアドレスを保存';
  String get nickname => _getString('nickname') ?? 'ニックネーム';
  String get parish => _getString('parish') ?? '所属教会';
  String get selectParish => _getString('selectParish') ?? '選択してください（任意）';
  String get selectParishTitle => _getString('selectParishTitle') ?? '所属教会を選択';
  String get baptismName => _getString('baptismName') ?? '洗礼名（任意）';
  String get baptismNameHint => _getString('baptismNameHint') ?? '洗礼名を入力してください';
  String get feastDay => _getString('feastDay') ?? '守護聖人の祝日（任意）';
  String get selectFeastDay => _getString('selectFeastDay') ?? '選択してください（任意）';
  String get selectFeastDayTitle =>
      _getString('selectFeastDayTitle') ?? '守護聖人の祝日を選択';
  String get createAccount => _getString('createAccount') ?? 'アカウントを作成';
  String get termsRequired =>
      _getString('termsRequired') ?? '利用規約とプライバシーポリシーに同意してください';
  String get subtitle => _getString('subtitle') ?? '信仰でつながる';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 검증 번역
class ValidationTranslations {
  final dynamic _data;

  ValidationTranslations(this._data);

  String get emailRequired => _getString('emailRequired') ?? 'メールアドレスを入力してください';
  String get emailInvalid =>
      _getString('emailInvalid') ?? '有効なメールアドレスを入力してください';
  String get passwordRequired =>
      _getString('passwordRequired') ?? 'パスワードを入力してください';
  String get passwordMinLength =>
      _getString('passwordMinLength') ?? 'パスワードは8文字以上で入力してください';
  String get nicknameRequired =>
      _getString('nicknameRequired') ?? 'ニックネームを入力してください';
  String nicknameMaxLength(int max) {
    final template =
        _getString('nicknameMaxLength') ?? 'ニックネームは{max}文字以内で入力してください';
    return template.replaceAll('{max}', max.toString());
  }

  String get invalidCharacters =>
      _getString('invalidCharacters') ?? '使用できない文字が含まれています';
  String get titleRequired => _getString('titleRequired') ?? 'タイトルを入力してください';
  String titleMaxLength(int max) {
    final template = _getString('titleMaxLength') ?? 'タイトルは{max}文字以内で入力してください';
    return template.replaceAll('{max}', max.toString());
  }

  String get contentRequired => _getString('contentRequired') ?? '本文を入力してください';
  String contentMaxLength(int max) {
    final template = _getString('contentMaxLength') ?? '本文は{max}文字以内で入力してください';
    return template.replaceAll('{max}', max.toString());
  }

  String get commentRequired =>
      _getString('commentRequired') ?? 'コメントを入力してください';
  String commentMaxLength(int max) {
    final template =
        _getString('commentMaxLength') ?? 'コメントは{max}文字以内で入力してください';
    return template.replaceAll('{max}', max.toString());
  }

  String get baptismNameRequired =>
      _getString('baptismNameRequired') ?? '洗礼名を入力してください';
  String get monthInvalid =>
      _getString('monthInvalid') ?? '有効な月（1-12）を入力してください';
  String get dayInvalid => _getString('dayInvalid') ?? '有効な日（1-31）を入力してください';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 언어 설정 번역
class LanguageTranslations {
  final dynamic _data;

  LanguageTranslations(this._data);

  String get settings => _getString('settings') ?? 'Language Settings';

  String switched({required String language}) {
    final template = _getString('switched') ?? '{language}に切り替えました';
    return template.replaceAll('{language}', language);
  }

  String switchedButProfileUpdateFailed({
    required String language,
    required String error,
  }) {
    final template =
        _getString('switchedButProfileUpdateFailed') ??
        '{language}に切り替えましたが、プロフィールの更新に失敗しました: {error}';
    return template
        .replaceAll('{language}', language)
        .replaceAll('{error}', error);
  }

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 미사 번역
class MassTranslations {
  final dynamic _data;

  MassTranslations(this._data);

  String get noDataToday => _getString('noDataToday') ?? '本日の黙想情報がありません';
  String get noDataWeekday => _getString('noDataWeekday') ?? '平日の黙想情報は現在準備中です';
  String get bibleNotice =>
      _getString('bibleNotice') ?? '※聖書の本文は、教会でお聞きになるか、公式の聖書をお読みください。';
  String get title => _getString('title') ?? '日々の黙想';

  String liturgicalDay(String key) {
    final days = _getValue('liturgicalDays');
    if (days is Map<String, dynamic>) {
      return days[key] as String? ?? key;
    }
    return key;
  }

  String get sunday => liturgicalDay('sunday');
  String get solemnity => liturgicalDay('solemnity');
  String get feast => liturgicalDay('feast');
  String get advent => liturgicalDay('advent');
  String get christmas => liturgicalDay('christmas');
  String get lent => liturgicalDay('lent');
  String get easter => liturgicalDay('easter');
  String get ordinary => liturgicalDay('ordinary');

  PrayerTranslations get prayer => PrayerTranslations(_getValue('prayer'));

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }

  dynamic _getValue(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key];
    }
    return null;
  }
}

/// 커뮤니티 번역
class CommunityTranslations {
  final dynamic _data;

  CommunityTranslations(this._data);

  String get title => _getString('title') ?? 'コミュニティ';
  String get newPost => _getString('newPost') ?? '新規投稿';
  String get postCreated => _getString('postCreated') ?? '投稿しました';
  String get postCreateFailed =>
      _getString('postCreateFailed') ?? '投稿に失敗しました。ネットワーク接続を確認してください。';
  String get postDeleted => _getString('postDeleted') ?? '投稿を削除しました';
  String get postDeleteFailed =>
      _getString('postDeleteFailed') ?? '投稿の削除に失敗しました';
  String get postDeleteConfirmTitle =>
      _getString('postDeleteConfirmTitle') ?? '削除確認';
  String get postDeleteConfirmMessage =>
      _getString('postDeleteConfirmMessage') ??
      'この投稿を削除してもよろしいですか？\nこの操作は取り消せません。';
  String get postHidden => _getString('postHidden') ?? '投稿を非表示にしました';
  String get postShow => _getString('postShow') ?? '投稿を表示しました';
  String get postHideFailed => _getString('postHideFailed') ?? '非表示処理に失敗しました';
  String get postShowFailed => _getString('postShowFailed') ?? '表示処理に失敗しました';
  String get postHideConfirmTitle =>
      _getString('postHideConfirmTitle') ?? '非表示確認';
  String get postHideConfirmMessage =>
      _getString('postHideConfirmMessage') ??
      'この投稿を非表示にしてもよろしいですか？\n非表示にした投稿は一覧に表示されなくなります。';
  String get postShowConfirmTitle =>
      _getString('postShowConfirmTitle') ?? '表示確認';
  String get postShowConfirmMessage =>
      _getString('postShowConfirmMessage') ??
      'この投稿を表示してもよろしいですか？\n表示すると一覧に再度表示されます。';
  String get postHideNoPermission =>
      _getString('postHideNoPermission') ??
      'この投稿を非表示にする権限がありません。自分の所属教会の投稿のみ非表示にできます。';
  String get postShowNoPermission =>
      _getString('postShowNoPermission') ??
      'この投稿を表示する権限がありません。自分の所属教会の投稿のみ表示できます。';
  String get editPost => _getString('editPost') ?? '編集する';
  String get deletePost => _getString('deletePost') ?? '削除する';
  String get hidePost => _getString('hidePost') ?? '非表示にする';
  String get showPost => _getString('showPost') ?? '表示する';
  String get reportPost => _getString('reportPost') ?? '通報する';
  String get commentPosted => _getString('commentPosted') ?? 'コメントを投稿しました';
  String get commentPostFailed =>
      _getString('commentPostFailed') ?? 'コメント投稿に失敗しました';
  String get likeFailed => _getString('likeFailed') ?? 'いいね処理に失敗しました';
  String get shareMeditation => _getString('shareMeditation') ?? '黙想を共有しました';
  String get noSearchResults => _getString('noSearchResults') ?? '検索結果がありません';
  String get errorOccurred => _getString('errorOccurred') ?? 'エラーが発生しました';
  String get swipeToRefresh => _getString('swipeToRefresh') ?? '下にスワイプして再読み込み';
  String get official => _getString('official') ?? '公式';
  String get officialAccountSettings =>
      _getString('officialAccountSettings') ?? '公式アカウント設定';
  String get registerAsNotice => _getString('registerAsNotice') ?? 'お知らせとして登録';
  String get registerAsNoticeSubtitle =>
      _getString('registerAsNoticeSubtitle') ?? '教会メンバー全員に通知されます';
  String get pinToTop => _getString('pinToTop') ?? '上部に固定';
  String get pinToTopSubtitle =>
      _getString('pinToTopSubtitle') ?? '投稿リストの最上部に表示されます';
  String get guidelines =>
      _getString('guidelines') ??
      '投稿することで、コミュニティガイドラインに同意したものとみなされます。他のユーザーを尊重し、適切な内容を投稿してください。';

  CommunityHomeTranslations get home =>
      CommunityHomeTranslations(_getValue('home'));

  NotificationLabelsTranslations get notificationLabels =>
      NotificationLabelsTranslations(_getValue('notificationLabels'));

  String postsCount(int count) {
    final template = _getString('postsCount') ?? '{count}件の投稿';
    return template.replaceAll('{count}', count.toString());
  }

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }

  dynamic _getValue(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key];
    }
    return null;
  }
}

/// 커뮤니티 홈 번역
class CommunityHomeTranslations {
  final dynamic _data;

  CommunityHomeTranslations(this._data);

  String get title => _getString('title') ?? 'コミュニティ';
  String get parish => _getString('parish') ?? '所属教会';
  String get parishNotSet => _getString('parishNotSet') ?? '所属教会が設定されていません';
  String get parishLoadFailed =>
      _getString('parishLoadFailed') ?? '所属教会の情報を読み込めませんでした';
  String get searchOtherParishes =>
      _getString('searchOtherParishes') ?? '他の教会のコミュニティを探す';
  String get todayMass => _getString('todayMass') ?? '今日のミサ';
  String get todayBibleReadingAndPrayer =>
      _getString('todayBibleReadingAndPrayer') ?? '今日の聖書朗読と祈り';
  String get recentNotices => _getString('recentNotices') ?? '最近のお知らせ';
  String get noNotices => _getString('noNotices') ?? 'お知らせはありません';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 알림 라벨 번역
class NotificationLabelsTranslations {
  final dynamic _data;

  NotificationLabelsTranslations(this._data);

  String get mention => _getString('mention') ?? 'メンション';
  String get notice => _getString('notice') ?? 'お知らせ';
  String get comment => _getString('comment') ?? 'コメント';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 신고 번역
class ReportTranslations {
  final dynamic _data;

  ReportTranslations(this._data);

  String get title => _getString('title') ?? '通報する';
  String get reasonRequired => _getString('reasonRequired') ?? '通報理由を選択してください';
  String get reasonInputRequired =>
      _getString('reasonInputRequired') ?? '通報理由を入力してください';
  String reportFailed(String error) {
    final template = _getString('reportFailed') ?? '通報に失敗しました';
    return '$template: $error';
  }

  String get reportSuccess =>
      _getString('reportSuccess') ?? '通報しました。ご報告ありがとうございます。';
  String get reasonHint => _getString('reasonHint') ?? '通報理由を入力してください';

  ReportReasonsTranslations get reasons =>
      ReportReasonsTranslations(_getValue('reasons'));

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }

  dynamic _getValue(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key];
    }
    return null;
  }
}

/// 신고 사유 번역
class ReportReasonsTranslations {
  final dynamic _data;

  ReportReasonsTranslations(this._data);

  String get spam => _getString('spam') ?? 'スパム';
  String get inappropriate => _getString('inappropriate') ?? '不適切なコンテンツ';
  String get harassment => _getString('harassment') ?? '誹謗中傷';
  String get other => _getString('other') ?? 'その他';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 이미지 번역
class ImageTranslations {
  final dynamic _data;

  ImageTranslations(this._data);

  String get title => _getString('title') ?? '画像';
  String get add => _getString('add') ?? '画像を追加';
  String get addButton => _getString('addButton') ?? '追加';
  String get max3Images => _getString('max3Images') ?? '最大3枚まで添付できます';
  String get camera => _getString('camera') ?? 'カメラ';
  String get gallery => _getString('gallery') ?? 'ギャラリー';
  String get selectFailed => _getString('selectFailed') ?? '画像の選択に失敗しました';
  String get permissionRequired =>
      _getString('permissionRequired') ?? 'アクセス許可が必要です';
  String get cameraPermissionMessage =>
      _getString('cameraPermissionMessage') ??
      'カメラを使用するために、設定からカメラへのアクセスを許可してください。';
  String get galleryPermissionMessage =>
      _getString('galleryPermissionMessage') ??
      'フォトライブラリを使用するために、設定からフォトライブラリへのアクセスを許可してください。';
  String get openSettings => _getString('openSettings') ?? '設定を開く';
  String get permissionDeniedMessage =>
      _getString('permissionDeniedMessage') ??
      '設定アプリからカメラ/フォトライブラリへのアクセスを許可してください';
  String get permissionDeniedMessageAlt =>
      _getString('permissionDeniedMessageAlt') ??
      '設定からカメラ/ストレージへのアクセスを許可してください';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 번역
class ProfileTranslations {
  final dynamic _data;

  ProfileTranslations(this._data);

  String get myPage => _getString('myPage') ?? 'マイページ';
  String get editProfile => _getString('editProfile') ?? 'プロフィール編集';
  String get profileUpdated => _getString('profileUpdated') ?? 'プロフィールを更新しました';
  String get updateFailed => _getString('updateFailed') ?? '更新に失敗しました';
  String get favoriteParishes => _getString('favoriteParishes') ?? 'よく行く教会';
  String get notificationSettings =>
      _getString('notificationSettings') ?? '通知設定';
  String get notificationSettingsComingSoon =>
      _getString('notificationSettingsComingSoon') ?? '通知設定は準備中です';
  String get languageSettings => _getString('languageSettings') ?? '言語設定';
  String get termsOfService => _getString('termsOfService') ?? '利用規約';
  String get termsOfServiceComingSoon =>
      _getString('termsOfServiceComingSoon') ?? '利用規約は準備中です';
  String get privacyPolicy => _getString('privacyPolicy') ?? 'プライバシーポリシー';
  String get privacyPolicyComingSoon =>
      _getString('privacyPolicyComingSoon') ?? 'プライバシーポリシーは準備中です';
  String get aboutApp => _getString('aboutApp') ?? 'アプリについて';
  String get shareProfileQR =>
      _getString('shareProfileQR') ?? 'プロフィールをQRコードで共有';
  String get userId => _getString('userId') ?? 'ユーザーID';
  String get userIdCopied => _getString('userIdCopied') ?? 'ユーザーIDをコピーしました';
  String get loginRequired => _getString('loginRequired') ?? 'ログインが必要です';
  String get pleaseLogin => _getString('pleaseLogin') ?? 'ログインしてください';
  String get fontSize => _getString('fontSize') ?? '文字サイズ';
  String get directInput => _getString('directInput') ?? 'その他（直接入力）';
  String get directInputTitle =>
      _getString('directInputTitle') ?? '洗礼名と祝日を直接入力';
  String get directInputDialogTitle =>
      _getString('directInputDialogTitle') ?? '洗礼名と祝日を入力';
  String get month => _getString('month') ?? '月';
  String get day => _getString('day') ?? '日';

  ProfileGodparentTranslations get godparent =>
      ProfileGodparentTranslations(_getValue('godparent'));
  ProfileFavoriteParishesTranslations get favoriteParishesSection =>
      ProfileFavoriteParishesTranslations(_getValue('favoriteParishes'));

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }

  dynamic _getValue(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key];
    }
    return null;
  }
}

/// 프로필 대부모 번역
class ProfileGodparentTranslations {
  final dynamic _data;

  ProfileGodparentTranslations(this._data);

  String get add => _getString('add') ?? '追加';
  String get remove => _getString('remove') ?? '削除';
  String get searchUser =>
      _getString('searchUser') ?? 'メールアドレスまたはユーザーIDで検索してください';
  String get userNotFound => _getString('userNotFound') ?? 'ユーザーが見つかりませんでした';
  String get userFound => _getString('userFound') ?? 'ユーザーが見つかりました';
  String get nickname => _getString('nickname') ?? 'ニックネーム';
  String get email => _getString('email') ?? 'メール';
  String get userId => _getString('userId') ?? 'ユーザーID';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 즐겨찾기 교회 번역
class ProfileFavoriteParishesTranslations {
  final dynamic _data;

  ProfileFavoriteParishesTranslations(this._data);

  String get title => _getString('title') ?? 'よく行く教会';
  String get searchParish => _getString('searchParish') ?? '教会を検索';
  String get noParishes => _getString('noParishes') ?? '登録された教会がありません';
  String get addParishMessage =>
      _getString('addParishMessage') ?? '教会を検索して追加してください';
  String get cannotDeleteParish =>
      _getString('cannotDeleteParish') ?? '所属教会は削除できません';
  String get deleted => _getString('deleted') ?? '削除しました';
  String get deleteTitle => _getString('deleteTitle') ?? '削除';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 교회 번역
class ParishTranslations {
  final dynamic _data;

  ParishTranslations(this._data);

  String get detail => _getString('detail') ?? '教会詳細';
  String get notFound => _getString('notFound') ?? '教会情報が見つかりませんでした';
  String get favoriteAdded => _getString('favoriteAdded') ?? 'お気に入りに追加しました';
  String get favoriteRemoved =>
      _getString('favoriteRemoved') ?? 'お気に入りから削除しました';
  String get cannotRemoveParish =>
      _getString('cannotRemoveParish') ?? '所属教会はお気に入りから削除できません';
  String get openInMap => _getString('openInMap') ?? '地図アプリで開く';
  String get community => _getString('community') ?? 'コミュニティ';
  String get search => _getString('search') ?? '教会を探す';
  String get locationPermissionRequired =>
      _getString('locationPermissionRequired') ?? '位置情報の許可が必要です';
  String get locationPermissionMessage =>
      _getString('locationPermissionMessage') ?? '設定から位置情報の許可を有効にしてください。';
  String get locationUsage => _getString('locationUsage') ?? '位置情報の利用';
  String get locationUsageMessage =>
      _getString('locationUsageMessage') ??
      '近くの教会を探すために位置情報の利用を許可してください。\n教会までの距離表示にも使用されます。';
  String get notNow => _getString('notNow') ?? '今はしない';
  String get allow => _getString('allow') ?? '許可する';
  String get locationFailed =>
      _getString('locationFailed') ?? '位置情報を取得できませんでした';
  String get searchFromCurrentLocation =>
      _getString('searchFromCurrentLocation') ?? '現在地から教会を検索';

  ParishFilterTranslations get filter =>
      ParishFilterTranslations(_getValue('filter'));
  ParishEmptyTranslations get empty =>
      ParishEmptyTranslations(_getValue('empty'));
  ParishDetailTranslations get detailSection =>
      ParishDetailTranslations(_getValue('detail'));

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }

  dynamic _getValue(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key];
    }
    return null;
  }
}

/// 교회 상세 번역
class ParishDetailTranslations {
  final dynamic _data;

  ParishDetailTranslations(this._data);

  String get noMassTimeInfo => _getString('noMassTimeInfo') ?? 'ミサ時間情報がありません';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 기도 번역
class PrayerTranslations {
  final dynamic _data;

  PrayerTranslations(this._data);

  String get title => _getString('title') ?? '黙想のガイド';
  String get morningMeditation => _getString('morningMeditation') ?? '朝の黙想';
  String get shareHint => _getString('shareHint') ?? '今日の黙想を共有しましょう...';

  PrayerGuideTranslations get morning =>
      PrayerGuideTranslations(_getValue('guides')?['morning']);
  PrayerGuideTranslations get meal =>
      PrayerGuideTranslations(_getValue('guides')?['meal']);
  PrayerGuideTranslations get evening =>
      PrayerGuideTranslations(_getValue('guides')?['evening']);
  PrayerGuideTranslations get difficult =>
      PrayerGuideTranslations(_getValue('guides')?['difficult']);
  PrayerGuideTranslations get thanksgiving =>
      PrayerGuideTranslations(_getValue('guides')?['thanksgiving']);
  PrayerGuideTranslations get meditation =>
      PrayerGuideTranslations(_getValue('guides')?['meditation']);

  String meditationGuideTitle(String key) {
    final guides = _getValue('meditationGuides');
    if (guides is Map<String, dynamic>) {
      return guides[key] as String? ?? key;
    }
    return key;
  }

  String readingLabel(String key) {
    final readings = _getValue('readings');
    if (readings is Map<String, dynamic>) {
      return readings[key] as String? ?? key;
    }
    return key;
  }

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }

  dynamic _getValue(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key];
    }
    return null;
  }
}

/// 기도 가이드 번역
class PrayerGuideTranslations {
  final dynamic _data;

  PrayerGuideTranslations(this._data);

  String get title => _getString('title') ?? '';
  String get subtitle => _getString('subtitle') ?? '';
  String get content => _getString('content') ?? '';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 교회 필터 번역
class ParishFilterTranslations {
  final dynamic _data;

  ParishFilterTranslations(this._data);

  String get title => _getString('title') ?? 'フィルター';
  String get reset => _getString('reset') ?? 'リセット';
  String get prefecture => _getString('prefecture') ?? '都道府県';
  String get mass => _getString('mass') ?? 'ミサ';
  String get options => _getString('options') ?? 'オプション';
  String get apply => _getString('apply') ?? '適用';
  String get todayMass => _getString('todayMass') ?? '今日のミサあり';
  String get foreignMass => _getString('foreignMass') ?? '外国語ミサあり';
  String get cathedralOnly => _getString('cathedralOnly') ?? '大聖堂のみ';
  String get cathedralOnlySubtitle =>
      _getString('cathedralOnlySubtitle') ?? '大聖堂のみを表示';
  String get massTimeAvailable => _getString('massTimeAvailable') ?? 'ミサ時間あり';
  String get massTimeAvailableSubtitle =>
      _getString('massTimeAvailableSubtitle') ?? 'ミサ時間情報がある教会のみを表示';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 교회 빈 상태 번역
class ParishEmptyTranslations {
  final dynamic _data;

  ParishEmptyTranslations(this._data);

  String get notFound => _getString('notFound') ?? '教会データが見つかりませんでした';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// QR 코드 번역
class QrTranslations {
  final dynamic _data;

  QrTranslations(this._data);

  String get invalid => _getString('invalid') ?? '無効なQRコードです';
  String get ownProfile => _getString('ownProfile') ?? '自分のプロフィールです';
  String get userNotFound => _getString('userNotFound') ?? 'ユーザーが見つかりませんでした';
  String get scanError => _getString('scanError') ?? 'スキャンエラー';
  String get userFound => _getString('userFound') ?? 'ユーザーが見つかりました';
  String get startScan => _getString('startScan') ?? 'スキャン開始';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 위치 번역
class LocationTranslations {
  final dynamic _data;

  LocationTranslations(this._data);

  String get permissionRequired =>
      _getString('permissionRequired') ?? '位置情報の許可が必要です';
  String get permissionMessage =>
      _getString('permissionMessage') ?? '設定から位置情報の許可を有効にしてください。';
  String get openSettings => _getString('openSettings') ?? '設定を開く';
  String get usagePurpose => _getString('usagePurpose') ?? '位置情報の使用目的';
  String get purposeNearbySearch =>
      _getString('purposeNearbySearch') ?? '現在地から近い教会の検索';
  String get purposeDistanceDisplay =>
      _getString('purposeDistanceDisplay') ?? '教会までの距離表示';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 검색 번역
class SearchTranslations {
  final dynamic _data;

  SearchTranslations(this._data);

  String get userNotFound => _getString('userNotFound') ?? 'ユーザーが見つかりませんでした';
  String get userSearchHint =>
      _getString('userSearchHint') ?? 'メールアドレスまたはユーザーID';
  String get userSearchRequired =>
      _getString('userSearchRequired') ?? 'メールアドレスまたはユーザーIDを入力してください';
  String get parishSearchHint => _getString('parishSearchHint') ?? '教会名で検索';
  String get saintSearchHint => _getString('saintSearchHint') ?? '聖人名で検索';
  String get noResults => _getString('noResults') ?? '検索結果がありません';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// AppLocalizations 로드 델리게이트
class _AppLocalizationsDelegate {
  static final _AppLocalizationsDelegate instance =
      _AppLocalizationsDelegate._();
  _AppLocalizationsDelegate._();

  final Map<Locale, AppLocalizations> _cache = {};

  Future<AppLocalizations> load(Locale locale) async {
    if (_cache.containsKey(locale)) {
      return _cache[locale]!;
    }

    final translations = await LocalizationService.instance.loadTranslations(
      locale,
    );
    final appLocalizations = AppLocalizations(locale, translations);
    _cache[locale] = appLocalizations;
    return appLocalizations;
  }

  AppLocalizations loadSync(Locale locale) {
    if (_cache.containsKey(locale)) {
      return _cache[locale]!;
    }

    // LocalizationService의 캐시 확인
    final cached = LocalizationService.instance.getCachedTranslations(
      locale.languageCode,
    );
    if (cached != null) {
      final appLocalizations = AppLocalizations(locale, cached);
      _cache[locale] = appLocalizations;
      return appLocalizations;
    }

    // 캐시에 없으면 기본값 사용 (나중에 비동기 로드로 업데이트됨)
    return AppLocalizations(locale, {});
  }

  void clearCache() {
    _cache.clear();
  }
}

/// AppLocalizations Provider (Riverpod) - 비동기
final appLocalizationsProvider = FutureProvider<AppLocalizations>((ref) async {
  final locale = ref.watch(localeProvider);
  return await _AppLocalizationsDelegate.instance.load(locale);
});

/// AppLocalizations Provider (Riverpod) - 동기 (캐시된 데이터 사용)
final appLocalizationsSyncProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return _AppLocalizationsDelegate.instance.loadSync(locale);
});
