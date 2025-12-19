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

  /// 성인 번역
  SaintsTranslations get saints => SaintsTranslations(_getValue('saints'));

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
  String? get offlineMode => _getString('offlineMode');
  String get shareLink => _getString('shareLink') ?? 'リンク';
  String get shareAppLink => _getString('shareAppLink') ?? 'アプリリンク';
  String get confirm => _getString('confirm') ?? '確認';

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
  String get googleSignInCanceled =>
      _getString('googleSignInCanceled') ?? 'Googleログインがキャンセルされました。';
  String get googleSignInFailed =>
      _getString('googleSignInFailed') ?? 'Googleログインに失敗しました。';
  String get googleAuthInfoFailed =>
      _getString('googleAuthInfoFailed') ?? 'Google認証情報の取得に失敗しました。';
  String googleSignInError(String error) {
    final template =
        _getString('googleSignInError') ?? 'Googleログイン中にエラーが発生しました: {error}';
    return template.replaceAll('{error}', error);
  }

  String get appleSignInFailed =>
      _getString('appleSignInFailed') ?? 'Appleログインに失敗しました。';
  String get appleSignInCanceled =>
      _getString('appleSignInCanceled') ?? 'Appleログインがキャンセルされました。';

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

  LanguageNamesTranslations get names =>
      LanguageNamesTranslations(_getValue('names'));

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

/// 언어 이름 번역
class LanguageNamesTranslations {
  final dynamic _data;

  LanguageNamesTranslations(this._data);

  String get japanese => _getString('japanese') ?? '日本語';
  String get english => _getString('english') ?? 'English';
  String get chinese => _getString('chinese') ?? '中文';
  String get vietnamese => _getString('vietnamese') ?? 'Tiếng Việt';
  String get korean => _getString('korean') ?? '한국어';
  String get spanish => _getString('spanish') ?? 'Español';
  String get portuguese => _getString('portuguese') ?? 'Português';

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
  String get contentDisclaimer =>
      _getString('contentDisclaimer') ?? '本コンテンツは公式ミサ典礼文を代替するものではなく、信仰生活を助けるための案内および黙想用資料です。';
  String get title => _getString('title') ?? '日々の黙想';
  String get shareReading => _getString('shareReading') ?? '今日のミサの読書をシェア';

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
  String? get sharePost => _getString('sharePost');
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
  String get searchPost => _getString('searchPost') ?? '投稿を検索';
  String get pinned => _getString('pinned') ?? '固定';
  String get noticesTitle => _getString('noticesTitle') ?? 'お知らせ';
  String get noOfficialNotices =>
      _getString('noOfficialNotices') ?? '公式お知らせがありません';
  String get createNotice => _getString('createNotice') ?? 'お知らせを作成';
  String get attachments => _getString('attachments') ?? '添付ファイル';
  String get attachmentsDescription =>
      _getString('attachmentsDescription') ??
      '画像は最大3枚、PDFは最大2個まで添付できます（合計5個まで）';
  String get pdfFiles => _getString('pdfFiles') ?? 'PDFファイル';
  String get addFile => _getString('addFile') ?? 'ファイルを追加';
  String get addButton => _getString('addButton') ?? '追加';
  String get pdfFileTooLarge =>
      _getString('pdfFileTooLarge') ??
      'PDFファイルのサイズは10MBを超えることはできません';
  String get pdfSelectFailed =>
      _getString('pdfSelectFailed') ?? 'PDFファイルの選択に失敗しました';
  String get tapToOpen => _getString('tapToOpen') ?? 'タップして開く';

  String maxImagesReached({required int max}) {
    final template = _getString('maxImagesReached') ?? '画像は最大{max}枚まで添付できます';
    return template.replaceAll('{max}', max.toString());
  }

  String maxPdfsReached({required int max}) {
    final template = _getString('maxPdfsReached') ?? 'PDFは最大{max}個まで添付できます';
    return template.replaceAll('{max}', max.toString());
  }

  CommunityFilterTranslations get filter =>
      CommunityFilterTranslations(_getValue('filter'));

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

  String get title => _getString('title') ?? '';
  String get parish => _getString('parish') ?? '';
  String get parishNotSet => _getString('parishNotSet') ?? '';
  String get parishLoadFailed => _getString('parishLoadFailed') ?? '';
  String get searchOtherParishes => _getString('searchOtherParishes') ?? '';
  String get todayMass => _getString('todayMass') ?? '';
  String get todayBibleReadingAndPrayer =>
      _getString('todayBibleReadingAndPrayer') ?? '';
  String get recentNotices => _getString('recentNotices') ?? '';
  String get noNotices => _getString('noNotices') ?? '';
  String get postAdded => _getString('postAdded') ?? '投稿が追加されました';
  String get commentAdded => _getString('commentAdded') ?? 'コメントがつきました';
  String get noticeAdded => _getString('noticeAdded') ?? 'お知らせが投稿されました';
  String get newPostAdded => _getString('newPostAdded') ?? '新規投稿が投稿されました';
  String get commentOnMyPost => _getString('commentOnMyPost') ?? '自分の投稿にコメントがつきました';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 커뮤니티 필터 번역
class CommunityFilterTranslations {
  final dynamic _data;

  CommunityFilterTranslations(this._data);

  String get latest => _getString('latest') ?? '最新';
  String get popular => _getString('popular') ?? '人気';
  String get myPosts => _getString('myPosts') ?? '私の投稿';

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
  String get post => _getString('post') ?? '投稿';
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
  String get favoriteParishes => favoriteParishesSection.title;
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
  String get clearCache => _getString('clearCache') ?? 'キャッシュを削除';
  String get clearCacheDescription =>
      _getString('clearCacheDescription') ?? '聖人データや画像のキャッシュを削除します';
  String get clearCacheConfirm =>
      _getString('clearCacheConfirm') ?? 'キャッシュを削除しますか？聖人データが再読み込みされます。';
  String get customerService =>
      _getString('customerService') ?? 'お問い合わせ';
  String get customerServiceDescription =>
      _getString('customerServiceDescription') ?? 'ご意見・ご要望をお聞かせください';

  ProfileGodparentTranslations get godparent =>
      ProfileGodparentTranslations(_getValue('godparent'));
  ProfileFavoriteParishesTranslations get favoriteParishesSection =>
      ProfileFavoriteParishesTranslations(_getValue('favoriteParishes'));
  ProfileNotificationsTranslations get notifications =>
      ProfileNotificationsTranslations(_getValue('notifications'));
  ProfileBasicInfoTranslations get basicInfo =>
      ProfileBasicInfoTranslations(_getValue('basicInfo'));
  ProfileParishInfoTranslations get parishInfo =>
      ProfileParishInfoTranslations(_getValue('parishInfo'));
  ProfileSacramentDatesTranslations get sacramentDates =>
      ProfileSacramentDatesTranslations(_getValue('sacramentDates'));
  ProfileBaptismalNameRequiredTranslations get baptismalNameRequired =>
      ProfileBaptismalNameRequiredTranslations(_getValue('baptismalNameRequired'));
  ProfileBaptismalNameChangeTranslations get baptismalNameChange =>
      ProfileBaptismalNameChangeTranslations(_getValue('baptismalNameChange'));

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
  String get title => _getString('title') ?? '代父母・代子・代女';
  String get label => _getString('label') ?? '代父母 (1名のみ)';
  String get userIdCopied => _getString('userIdCopied') ?? 'ユーザーIDをコピーしました';
  String get noGodchildren => _getString('noGodchildren') ?? '登録された代子・代女がありません';
  String get unknown => _getString('unknown') ?? '不明';
  String get addGodchild => _getString('addGodchild') ?? '代子・代女を追加';

  String godchildrenLabel({required int count}) {
    final template = _getString('godchildrenLabel') ?? '代子・代女 ({count}人)';
    return template.replaceAll('{count}', count.toString());
  }

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 기본 정보 번역
class ProfileBasicInfoTranslations {
  final dynamic _data;

  ProfileBasicInfoTranslations(this._data);

  String get title => _getString('title') ?? '基本情報';
  String get emailCannotChange =>
      _getString('emailCannotChange') ?? 'メールアドレスは変更できません';
  String get userIdCannotChange =>
      _getString('userIdCannotChange') ??
      'ユーザーIDは変更できません（長押しでコピー）';
  String get baptismNameCannotChange =>
      _getString('baptismNameCannotChange') ?? '洗礼名は変更できません';
  String get baptismNameHint =>
      _getString('baptismNameHint') ?? '洗礼名を入力してください';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 교회 정보 번역
class ProfileParishInfoTranslations {
  final dynamic _data;

  ProfileParishInfoTranslations(this._data);

  String get title => _getString('title') ?? '教会情報';
  String get feastDayNameHint =>
      _getString('feastDayNameHint') ?? 'ペトロ、マリア、ヨハネ...';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 성사 날짜 번역
class ProfileSacramentDatesTranslations {
  final dynamic _data;

  ProfileSacramentDatesTranslations(this._data);

  String get title => _getString('title') ?? '聖事の日付';
  String get baptismDate => _getString('baptismDate') ?? '洗礼日';
  String get confirmationDate => _getString('confirmationDate') ?? '堅信日';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 세례명 등록 권유 번역
class ProfileBaptismalNameRequiredTranslations {
  final dynamic _data;

  ProfileBaptismalNameRequiredTranslations(this._data);

  String get title =>
      _getString('title') ?? '洗礼名の登録をお願いします';
  String get message =>
      _getString('message') ??
      '洗礼名を登録すると、あなたの守護聖人の祝日を確認できます。';
  String get description =>
      _getString('description') ??
      'プロフィール編集ページで洗礼名を登録してください。';
  String get goToProfile =>
      _getString('goToProfile') ?? 'プロフィール編集へ';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 세례명 변경 확인 번역
class ProfileBaptismalNameChangeTranslations {
  final dynamic _data;

  ProfileBaptismalNameChangeTranslations(this._data);

  String get title => _getString('title') ?? '洗礼名の変更';
  String get message =>
      _getString('message') ?? '洗礼名は一度設定すると変更できません。';
  String get description =>
      _getString('description') ??
      '本当に変更しますか？この操作は取り消せません。';

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

  String registeredCount(int count) {
    final template = _getString('registeredCount') ?? '{count}件登録済み';
    return template.replaceAll('{count}', count.toString());
  }

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 프로필 알림 번역
class ProfileNotificationsTranslations {
  final dynamic _data;

  ProfileNotificationsTranslations(this._data);

  String get enabled => _getString('enabled') ?? '通知を有効にする';
  String get enabledDescription =>
      _getString('enabledDescription') ?? 'すべての通知をオン/オフにします';
  String get categories => _getString('categories') ?? '通知カテゴリ';
  String get notices => _getString('notices') ?? 'お知らせ';
  String get noticesDescription =>
      _getString('noticesDescription') ?? '教会からのお知らせを受け取ります';
  String get comments => _getString('comments') ?? 'コメント';
  String get commentsDescription =>
      _getString('commentsDescription') ?? '投稿へのコメントを受け取ります';
  String get likes => _getString('likes') ?? 'いいね';
  String get likesDescription =>
      _getString('likesDescription') ?? '投稿へのいいねを受け取ります';
  String get dailyMass => _getString('dailyMass') ?? '毎日のミサ';
  String get dailyMassDescription =>
      _getString('dailyMassDescription') ?? '毎日のミサの読み物の通知を受け取ります';
  String get quietHours => _getString('quietHours') ?? 'おやすみモード';
  String get quietHoursDescription =>
      _getString('quietHoursDescription') ??
      '指定した時間帯は通知を受け取りません';
  String get quietHoursStart => _getString('quietHoursStart') ?? '開始時刻';
  String get quietHoursEnd => _getString('quietHoursEnd') ?? '終了時刻';
  String get saved => _getString('saved') ?? '通知設定を保存しました';
  String get testNotification =>
      _getString('testNotification') ?? 'テスト通知を送信';
  String get testNotificationDescription =>
      _getString('testNotificationDescription') ??
      'FCM通知が正常に動作するかテストします';
  String get testNotificationSent =>
      _getString('testNotificationSent') ?? 'テスト通知が送信されました';

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
  String? get shareParish => _getString('shareParish');
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
      ParishDetailTranslations(_getValue('detailSection'));

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
  String get address => _getString('address') ?? '住所';
  String get phone => _getString('phone') ?? '電話';
  String get fax => _getString('fax') ?? 'FAX';
  String get website => _getString('website') ?? 'ウェブサイト';
  String get massTime => _getString('massTime') ?? 'ミサ時間';
  String get massTimeNotice =>
      _getString('massTimeNotice') ?? '※ ミサ時間は各本堂のホームページでご確認ください';
  String get noMassTimeInfoInList =>
      _getString('noMassTimeInfoInList') ?? 'ミサ時間情報がありません';

  ParishWeekdaysTranslations get weekdays =>
      ParishWeekdaysTranslations(_getValue('weekdays'));

  ParishLanguagesTranslations get languages =>
      ParishLanguagesTranslations(_getValue('languages'));

  ParishSundayNoteTranslations get sundayNote =>
      ParishSundayNoteTranslations(_getValue('sundayNote'));

  String get other => _getString('other') ?? 'その他';
  String get withSignLanguage => _getString('withSignLanguage') ?? '手話付き';

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

/// 교회 상세 요일 번역
class ParishWeekdaysTranslations {
  final dynamic _data;

  ParishWeekdaysTranslations(this._data);

  String get monday => _getString('monday') ?? '月';
  String get tuesday => _getString('tuesday') ?? '火';
  String get wednesday => _getString('wednesday') ?? '水';
  String get thursday => _getString('thursday') ?? '木';
  String get friday => _getString('friday') ?? '金';
  String get mondayToFriday => _getString('mondayToFriday') ?? '月-金';
  String get saturday => _getString('saturday') ?? '土';
  String get sunday => _getString('sunday') ?? '主日';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 교회 상세 언어 번역
class ParishLanguagesTranslations {
  final dynamic _data;

  ParishLanguagesTranslations(this._data);

  String get english => _getString('english') ?? '英語';
  String get spanish => _getString('spanish') ?? 'スペイン語';
  String get chinese => _getString('chinese') ?? '中国語';
  String get filipino => _getString('filipino') ?? 'フィリピン語';
  String get portuguese => _getString('portuguese') ?? 'ポルトガル語';
  String get korean => _getString('korean') ?? '韓国語';
  String get vietnamese => _getString('vietnamese') ?? 'ベトナム語';
  String get indonesian => _getString('indonesian') ?? 'インドネシア語';
  String get polish => _getString('polish') ?? 'ポーランド語';
  String get french => _getString('french') ?? 'フランス語';
  String get german => _getString('german') ?? 'ドイツ語';
  String get italian => _getString('italian') ?? 'イタリア語';

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// 교회 상세 주일 표기 번역
class ParishSundayNoteTranslations {
  final dynamic _data;

  ParishSundayNoteTranslations(this._data);

  String get first => _getString('first') ?? '第1日曜';
  String get second => _getString('second') ?? '第2日曜';
  String get third => _getString('third') ?? '第3日曜';
  String get fourth => _getString('fourth') ?? '第4日曜';
  String get secondAndFourth => _getString('secondAndFourth') ?? '第2・第4日曜';
  String get firstAndThird => _getString('firstAndThird') ?? '第1・第3日曜';

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
  String everyoneMeditation(int count) {
    final template = _getString('everyoneMeditation') ?? 'みんなの黙想 ({count})';
    return template.replaceAll('{count}', count.toString());
  }

  String get noMeditationYet => _getString('noMeditationYet') ?? 'まだ黙想がありません';
  String get errorOccurred => _getString('errorOccurred') ?? 'エラーが発生しました';
  String get permissionDenied =>
      _getString('permissionDenied') ?? '権限がありません。ログイン状態を確認してください。';
  String get networkError => _getString('networkError') ?? 'ネットワークエラーが発生しました。';
  String get anonymous => _getString('anonymous') ?? '匿名';
  String get loginToShare => _getString('loginToShare') ?? 'ログインして黙想を共有しましょう';

  PrayerGuideTranslations get morning {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('morning')) {
      return PrayerGuideTranslations(guides['morning']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get meal {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('meal')) {
      return PrayerGuideTranslations(guides['meal']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get evening {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('evening')) {
      return PrayerGuideTranslations(guides['evening']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get difficult {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('difficult')) {
      return PrayerGuideTranslations(guides['difficult']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get thanksgiving {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('thanksgiving')) {
      return PrayerGuideTranslations(guides['thanksgiving']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get meditation {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('meditation')) {
      return PrayerGuideTranslations(guides['meditation']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get repentance {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('repentance')) {
      return PrayerGuideTranslations(guides['repentance']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get peace {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('peace')) {
      return PrayerGuideTranslations(guides['peace']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get forgiveness {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('forgiveness')) {
      return PrayerGuideTranslations(guides['forgiveness']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get love {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('love')) {
      return PrayerGuideTranslations(guides['love']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get patience {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('patience')) {
      return PrayerGuideTranslations(guides['patience']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get waiting {
    final guides = _getValue('guides');
    if (guides is Map<String, dynamic> && guides.containsKey('waiting')) {
      return PrayerGuideTranslations(guides['waiting']);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get meditationTips {
    final tips = _getValue('meditationTips');
    if (tips is Map<String, dynamic>) {
      return PrayerGuideTranslations(tips);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get practicalTips {
    final tips = _getValue('practicalTips');
    if (tips is Map<String, dynamic>) {
      return PrayerGuideTranslations(tips);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get meditationJournal {
    final journal = _getValue('meditationJournal');
    if (journal is Map<String, dynamic>) {
      return PrayerGuideTranslations(journal);
    }
    return PrayerGuideTranslations(null);
  }

  PrayerGuideTranslations get prayerAfterMeditation {
    final prayer = _getValue('prayerAfterMeditation');
    if (prayer is Map<String, dynamic>) {
      return PrayerGuideTranslations(prayer);
    }
    return PrayerGuideTranslations(null);
  }

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

  /// 데이터가 유효한지 확인
  bool get hasData =>
      _data is Map<String, dynamic> && (_data as Map).isNotEmpty;
}

/// 교회 필터 번역
class ParishFilterTranslations {
  final dynamic _data;

  ParishFilterTranslations(this._data);

  String get title => _getString('title') ?? 'フィルター';
  String get button => _getString('button') ?? 'フィルター';
  String get sortByDistance => _getString('sortByDistance') ?? '距離順';
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

/// 성인 번역
class SaintsTranslations {
  final dynamic _data;

  SaintsTranslations(this._data);

  String get feastDay => _getString('feastDay') ?? '祝日';
  String get yourBaptismalName =>
      _getString('yourBaptismalName') ?? 'あなたの洗礼名の祝日です';
  String get solemnity => _getString('solemnity') ?? '大祝日';
  String get feast => _getString('feast') ?? '祝日';
  String get memorial => _getString('memorial') ?? '記念日';
  String get todaySaints => _getString('todaySaints') ?? '今日の聖人';
  String get todaySaintsSubtitle =>
      _getString('todaySaintsSubtitle') ?? '今日記念される聖人たち';
  String get biography => _getString('biography') ?? '生涯';
  String get achievements => _getString('achievements') ?? '主な業績';
  String get patronage => _getString('patronage') ?? '守護';
  String get prayer => _getString('prayer') ?? '祈り';
  String get howToHonor => _getString('howToHonor') ?? '聖人を敬う方法';
  String get detailLoadFailed =>
      _getString('detailLoadFailed') ?? '詳細情報の読み込みに失敗しました';
  String get noSaintsToday =>
      _getString('noSaintsToday') ?? '今日記念される聖人はいません';
  String? get generatingMessage => _getString('generatingMessage');
  String get loadFailed => _getString('loadFailed') ?? '読み込みに失敗しました';
  String get sourceNote =>
      _getString('sourceNote') ??
      '📖 ローマ殉教録と教会の伝統に基づき、今日記念される聖人です。';
  String get liturgyTakesPrecedence =>
      _getString('liturgyTakesPrecedence') ??
      '⛪ 今日は典礼が優先される日です。';
  String get optionalMemorial => _getString('optionalMemorial') ?? '任意記念日';

  String andMore({required int count}) {
    final template = _getString('andMore') ?? '他{count}人';
    return template.replaceAll('{count}', count.toString());
  }

  String? _getString(String key) {
    if (_data is Map<String, dynamic>) {
      return _data[key] as String?;
    }
    return null;
  }
}

/// AppLocalizations 로드 델리게이트 (내부용)
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

    // 번역 데이터가 비어있지 않은지 확인
    if (translations.isEmpty) {
      // 빈 데이터인 경우, 기본 로케일로 재시도
      if (locale.languageCode != 'ja') {
        return await load(const Locale('ja', 'JP'));
      }
    }

    final appLocalizations = AppLocalizations(locale, translations);
    _cache[locale] = appLocalizations;
    return appLocalizations;
  }

  AppLocalizations loadSync(Locale locale) {
    // 캐시에 해당 로케일이 있으면 반환
    if (_cache.containsKey(locale)) {
      return _cache[locale]!;
    }

    // LocalizationService의 캐시 확인
    final cached = LocalizationService.instance.getCachedTranslations(
      locale.languageCode,
    );
    if (cached != null && cached.isNotEmpty) {
      final appLocalizations = AppLocalizations(locale, cached);
      _cache[locale] = appLocalizations;
      return appLocalizations;
    }

    // 캐시에 없으면 이전 로케일의 캐시를 확인하지 않고 빈 맵 반환
    // 비동기 provider가 로드되면 자동으로 업데이트됨
    // 빈 데이터를 반환하면 fallback 값들이 사용됨
    return AppLocalizations(locale, {});
  }

  void clearCache() {
    _cache.clear();
  }
}

/// AppLocalizations 캐시 무효화 (언어 변경 시 사용)
void clearAppLocalizationsCache() {
  _AppLocalizationsDelegate.instance.clearCache();
  LocalizationService.instance.clearCache();
}

/// Flutter LocalizationsDelegate 구현
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return const [
      'ja',
      'en',
      'ko',
      'zh',
      'vi',
      'es',
      'pt',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return await _AppLocalizationsDelegate.instance.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
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
