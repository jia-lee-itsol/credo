# AppLocalizations 자동 생성 가이드

## 개요

`app_localizations.dart` 파일은 JSON 파일에서 자동으로 생성됩니다. 이 스크립트를 사용하면 번역 JSON 파일을 수정한 후 Dart 코드를 자동으로 생성할 수 있습니다.

## 사용법

```bash
python3 scripts/generate_localizations.py
```

## 주의사항

현재 자동 생성 스크립트는 기본적인 구조만 생성합니다. 다음 특수 메서드들은 수동으로 추가해야 합니다:

### 1. PrayerTranslations.meditationGuideTitle

```dart
String meditationGuideTitle(String key) {
  final guides = _getValue('meditationGuides');
  if (guides is Map<String, dynamic>) {
    return guides[key] as String? ?? key;
  }
  return key;
}
```

### 2. MassTranslations.liturgicalDay

```dart
String liturgicalDay(String key) {
  final days = _getValue('liturgicalDays');
  if (days is Map<String, dynamic>) {
    return days[key] as String? ?? key;
  }
  return key;
}
```

### 3. hasData 속성 (MeditationtipsTranslations, PracticaltipsTranslations 등)

```dart
bool get hasData => _data != null && _data is Map<String, dynamic>;
```

### 4. LocalizationService.loadTranslationsSync

`LocalizationService`에 다음 메서드를 추가해야 합니다:

```dart
Map<String, dynamic> loadTranslationsSync(Locale locale) {
  final languageCode = locale.languageCode;
  final cached = getCachedTranslations(languageCode);
  if (cached != null) {
    return cached;
  }
  // 동기 로드가 필요한 경우 rootBundle.loadString을 사용
  // 하지만 일반적으로는 비동기 로드를 권장합니다
  throw UnimplementedError('loadTranslationsSync는 캐시된 데이터만 반환합니다');
}
```

## 향후 개선 사항

1. 특수 메서드 자동 감지 및 생성
2. `hasData` 속성 자동 추가
3. `loadTranslationsSync` 메서드 자동 생성
4. 기존 코드와의 병합 기능

## 파일 구조

- `assets/l10n/app_*.json`: 번역 JSON 파일
- `lib/core/utils/app_localizations.dart`: 생성된 Dart 파일
- `scripts/generate_localizations.py`: 자동 생성 스크립트

