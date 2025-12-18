# Credo 리팩토링 가이드

## 개요

이 문서는 `/lib` 디렉토리에 대한 종합 분석을 기반으로 Credo 코드베이스의 리팩토링 우선순위와 권장사항을 설명합니다.

**마지막 업데이트**: 2025-12-18 (단위 테스트 커버리지 확장: 총 13개 테스트 파일, 85개 테스트 케이스 완료)
**전체 코드베이스**: 약 33,275줄의 Dart 코드, 194개 파일 (자동 생성 파일 제외)

---

## 요약

Credo 코드베이스는 **기능 기반 모듈식 설계와 함께 Clean Architecture**를 구현합니다. 아키텍처 기반은 견고하지만, 유지보수성, 일관성, 코드 품질을 개선하기 위해 여러 영역에서 리팩토링이 필요합니다.

### 건강 점수: 8/10

| 카테고리 | 상태 |
|----------|--------|
| 아키텍처 | 양호 |
| 상태 관리 | 양호 |
| 에러 처리 | ✅ 개선 완료 (커뮤니티 repository 표준화 완료) |
| 로깅 | ✅ 개선 완료 (주요 파일 AppLogger 적용 완료) |
| 코드 구성 | ✅ 개선 완료 (Provider 표준화, 서비스 이동 완료) |
| 테스트 커버리지 | ✅ 진행 중 (6개 Repository/Notifier, 36개 테스트 케이스) |

---

## 우선순위 1: 중요

### 1.1 에러 처리 표준화 ✅ 완료

**문제**: Repository 간에 예외 던지기와 `Either<Failure, T>` 패턴이 혼재되어 있습니다.

**현재 상태**:
- **Community repositories**는 `throw Exception()` 사용:
  - `firestore_post_repository.dart` (6개 인스턴스)
  - `firestore_user_repository.dart`
  - `firestore_notification_repository.dart`

- **다른 repositories**는 `Either<Failure, T>` 사용:
  - `auth_repository_impl.dart`
  - `parish_repository_impl.dart`
  - `saint_feast_day_repository_impl.dart`

**해결책**: 커뮤니티 전용 실패 타입 생성 및 모든 repository를 Either 패턴으로 변경 완료.

**구현 내용**:
- `lib/features/community/domain/failures/community_failures.dart` 생성
- 커뮤니티 전용 실패 타입:
  - `PostCreationFailure`, `PostUpdateFailure`, `PostDeleteFailure`, `PostNotFoundFailure`
  - `CommentCreationFailure`
  - `NotificationCreationFailure`, `NotificationUpdateFailure`, `NotificationDeleteFailure`
  - `UserNotFoundFailure`, `UserSaveFailure`
  - `LikeToggleFailure`
  - `InsufficientPermissionFailure`
  - `ReportCreationFailure`

**완료된 작업**:
1. ✅ 커뮤니티 전용 실패 타입 생성
2. ✅ `PostRepository` 인터페이스를 `Either<Failure, T>` 반환으로 변경
3. ✅ `UserRepository` 인터페이스를 `Either<Failure, T>` 반환으로 변경
4. ✅ `NotificationRepository` 인터페이스를 `Either<Failure, T>` 반환으로 변경
5. ✅ `FirestorePostRepository` 구현 변경
6. ✅ `FirestoreUserRepository` 구현 변경
7. ✅ `FirestoreNotificationRepository` 구현 변경
8. ✅ `PostFormNotifier`에서 Either 패턴 처리
9. ✅ `PostDetailScreen`에서 Either 패턴 처리
10. ✅ `postByIdProvider` 업데이트

**작업량**: 중간 (2-3시간) ✅ 완료
**영향**: 높음

---

### 1.2 로깅 서비스 추출 ✅ 완료

**문제**: 코드베이스 전체에 `print()`와 `debugPrint()`가 385개 이상 산재되어 있습니다.

**영향받는 파일**:
- `auth_repository_impl.dart` (47개 이상의 디버그 문)
- `firestore_post_repository.dart` (76개 이상의 디버그 문)
- `firestore_notification_repository.dart`
- `firestore_user_repository.dart`
- `image_upload_service.dart`
- `home_screen.dart`
- 기타 다수...

**해결책**: 중앙화된 로깅 서비스 생성 및 적용 완료.

**구현 내용**:
- `lib/core/services/logger_service.dart` 생성
- 기능별 로깅 메서드 제공:
  - `AppLogger.auth()` - 인증 관련
  - `AppLogger.community()` - 커뮤니티 관련
  - `AppLogger.notification()` - 알림 관련
  - `AppLogger.parish()` - 성당 관련
  - `AppLogger.profile()` - 프로필 관련
  - `AppLogger.image()` - 이미지 업로드 관련
  - `AppLogger.error()` - 에러 로그
  - `AppLogger.warning()` - 경고 로그
  - `AppLogger.info()` - 정보 로그
  - `AppLogger.debug()` - 디버그 로그

**완료된 작업**:
1. ✅ `lib/core/services/logger_service.dart` 생성
2. ✅ 주요 repository 파일들의 로깅 교체:
   - `auth_repository_impl.dart`
   - `firestore_post_repository.dart`
   - `firestore_notification_repository.dart`
   - `firestore_user_repository.dart`
3. ✅ 주요 서비스 파일들의 로깅 교체:
   - `image_upload_service.dart`
4. ✅ 주요 화면 파일들의 로깅 교체:
   - `home_screen.dart`
5. ✅ debug/release 모드에 따른 조건부 로깅 구현

**작업량**: 중간 (2-3시간) ✅ 완료
**영향**: 높음 (성능 및 디버깅 가능성)

---

### 1.3 중복 정렬 로직 추출 ✅ 완료

**문제**: 동일한 게시글 정렬 로직이 4개 이상의 위치에서 반복됩니다.

**영향받는 파일**:
- `firestore_post_repository.dart` (watchOfficialNotices, watchCommunityPosts, watchAllPosts)
- `post_list_screen.dart` (presentation layer)

**해결책**: Extension 메서드 생성 및 적용 완료.

**구현 내용**:
- `lib/features/community/domain/extensions/post_extensions.dart` 생성
- `sortByPinnedAndDate()` - 핀 고정 우선, 그 다음 생성 시간순 정렬
- `sortByPinnedAndPopularity()` - 핀 고정 우선, 그 다음 인기순 정렬 (likeCount 기준)

**완료된 작업**:
1. ✅ Extension 메서드 생성
2. ✅ `firestore_post_repository.dart`의 3곳 정렬 로직 교체
3. ✅ `post_list_screen.dart`의 정렬 로직 교체

**작업량**: 낮음 (30분) ✅ 완료
**영향**: 중간

---

## 우선순위 2: 높음

### 2.1 큰 화면 파일 분할

**문제**: 여러 화면 파일이 700줄 이상으로 단일 책임 원칙을 위반합니다.

| 파일 | 줄 수 | 권장사항 | 상태 |
|------|-------|----------------|------|
| `parish_detail_screen.dart` | 1,225 → 172 | 여러 섹션을 위젯으로 분할 | ✅ 완료 |
| `sign_up_screen.dart` | 1,043 → 385 | 폼 섹션을 위젯으로 분할 | ✅ 완료 |
| `daily_mass_screen.dart` | 1,037 → 307 | 독서 섹션, 댓글 섹션 분할 | ✅ 완료 |
| `meditation_guide_provider.dart` | 877 → 127 | Provider 로직 분리 | ✅ 완료 |
| `my_page_screen.dart` | 617 → 93 | 설정 섹션을 위젯으로 분할 | ✅ 완료 |
| `edit_profile_screen.dart` | 1,106 → 457 | 3-4개 위젯으로 분할 | ✅ 완료 (649줄 감소, 59% 감소, 총 8개 위젯으로 분리) |
| `post_detail_screen.dart` | 959 → 304 | 댓글, 이미지 갤러리 추출 | ✅ 완료 (655줄 감소, 8개 위젯으로 분리) |
| `parish_list_screen.dart` | 739 → 336 | 필터 다이얼로그, 리스트 아이템 추출 | ✅ 완료 (403줄 감소, 4개 위젯으로 분리) |
| `post_list_screen.dart` | 543 → 332 | 게시글 카드 위젯 추출 | ✅ 완료 (3개 위젯으로 분리) |
| `post_create_screen.dart` | 516 → 244 | 폼 컴포넌트 추출 | ✅ 완료 (4개 위젯으로 분리) |

**리팩토링 예시** (`edit_profile_screen.dart`):

```
lib/features/profile/presentation/
├── screens/
│   └── edit_profile_screen.dart (메인 화면, ~400줄)
├── widgets/
│   ├── profile_image_picker.dart
│   ├── profile_form_fields.dart
│   ├── parish_selector_dialog.dart
│   └── profile_action_buttons.dart
```

**작업량**: 높음 (4-6시간)
**영향**: 높음 (가독성 및 테스트 가능성)

**완료된 작업**:
- ✅ `post_detail_screen.dart` 분할 완료 (959줄 → 302줄)
  - 8개 위젯으로 분리: `PostImageViewer`, `PostDetailHeader`, `PostDetailAuthorInfo`, `PostDetailImages`, `PostDetailLikeButton`, `PostDetailCommentsSection`, `PostDetailCommentInput`, `PostCommentSubmitter`
  - 코드 가독성 및 재사용성 향상
  - 각 위젯을 독립적으로 테스트 가능
- ✅ `pages` 디렉토리를 `screens`로 통합 완료
  - `post_edit_page.dart` → `post_edit_screen.dart`
  - `notice_list_page.dart` → `notice_list_screen.dart`
  - `community_list_page.dart` → `community_list_screen.dart`
  - 모든 화면이 일관된 `screens/` 디렉토리에 위치

**완료된 작업**:
- ✅ `edit_profile_screen.dart` 분할 완료 (1,106줄 → 457줄, 649줄 감소, 59% 감소)
  - 총 8개 위젯으로 분리:
    - 기존 5개: `ProfileImagePicker`, `ProfileBasicInfoSection`, `ProfileParishInfoSection`, `ProfileSacramentDatesSection`, `ProfileGodparentSection`
    - 추가 분리 3개: `FeastDaySearchSheet`, `UserSearchSheet`, `ParishSearchSheet`
  - 코드 가독성 및 재사용성 향상
  - 모든 큰 파일(>500줄) 분할 완료

**완료된 작업**:
- ✅ `parish_list_screen.dart` 분할 완료 (739줄 → 338줄)
  - 4개 위젯으로 분리: `ParishSearchBar`, `ParishFilterBottomSheet`, `ParishEmptyState`, `ParishNoResultState`
  - 코드 가독성 및 재사용성 향상

**완료된 작업**:
- ✅ `post_list_screen.dart` 분할 완료 (543줄 → 332줄, 3개 위젯으로 분리)
- ✅ `post_create_screen.dart` 분할 완료 (516줄 → 244줄, 4개 위젯으로 분리)

---

### 2.2 Freezed로 데이터 모델 표준화

**문제**: 데이터 모델에 혼재된 구현 방식.

**Freezed 사용** (좋음):
- `user_entity.dart`
- `parish_entity.dart`
- `post_entity.dart`
- `user_model.dart`
- `parish_model.dart`

**수동 구현** (마이그레이션 필요):
- ~~`lib/features/community/data/models/post.dart`~~ ✅ 완료
- ~~`lib/features/community/data/models/app_user.dart`~~ ✅ 완료
- ~~`lib/features/community/data/models/comment.dart`~~ ✅ 완료
- ~~`lib/features/community/data/models/notification.dart`~~ ✅ 완료

**완료된 작업**:
- ✅ 모든 커뮤니티 모델에 `@freezed` 어노테이션 추가
- ✅ build_runner를 통해 `copyWith`, `==`, `hashCode` 생성
- ✅ `toFirestore()` 메서드 추가 (DateTime을 Timestamp로 변환)
- ✅ DateTime 변환기 구현

**작업량**: 중간 (2-3시간) ✅ 완료
**영향**: 중간 (일관성 및 보일러플레이트 감소)

---

### 2.3 Provider 구성 표준화 ✅ 완료

**문제**: 기능 간에 Provider가 다른 레이어에 위치합니다.

**현재 불일치**:
```
features/parish/presentation/providers/   # presentation layer
features/community/data/providers/        # data layer
shared/providers/                         # global
```

**권장 구조**:
```
features/{feature}/
├── data/
│   ├── providers/        # Repository providers
│   └── repositories/
├── domain/
└── presentation/
    └── providers/        # UI state providers (Notifiers)
```

**완료된 작업**:
- ✅ Repository Provider는 `data/providers/`에 유지
  - `community_repository_providers.dart`: Repository Provider만 포함
  - `parish_providers.dart`: 이미 올바른 위치
  - `saint_feast_day_providers.dart`: 이미 올바른 위치
- ✅ UI state Provider는 `presentation/providers/`로 이동
  - `community_presentation_providers.dart` 생성
  - 모든 UI state Provider 이동 (officialNoticesProvider, communityPostsProvider, allPostsProvider, userStreamProvider, userProvider, userByDisplayNameProvider, currentAppUserProvider, postFormNotifierProvider, postByIdProvider, notificationsProvider, commentsProvider, postCountProvider, hasNewPostsProvider)
  - Repository Provider re-export 추가 (하위 호환성)
- ✅ 모든 import 경로 업데이트 (14개 파일)

**작업량**: 낮음 (1-2시간) ✅ 완료
**영향**: 중간

---

## 우선순위 3: 중간

### 3.1 테스트 커버리지 추가

**현재 상태**: 테스트 파일이 없습니다.

**권장 테스트 구조**:
```
test/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl_test.dart
│   │   └── domain/
│   │       └── usecases/
│   ├── community/
│   └── parish/
├── core/
│   └── services/
└── shared/
    └── providers/
```

**우선순위 테스트 대상**:
1. Repository 구현
2. State notifiers
3. Use cases
4. 유틸리티 함수

**작업량**: 높음 (8-12시간)
**영향**: 높음

---

### 3.2 공유 서비스를 Core로 이동 ✅ 완료

**문제**: `image_upload_service.dart`가 커뮤니티 기능에 있지만 재사용 가능합니다.

**현재 위치**:
```
lib/features/community/core/services/image_upload_service.dart
```

**권장 위치**:
```
lib/core/data/services/image_upload_service.dart
```

**완료된 작업**:
- ✅ `image_upload_service.dart`를 `core/data/services/`로 이동
- ✅ import 경로 업데이트: `post_form_notifier.dart`에서 새로운 경로 사용
- ✅ 기존 파일 삭제

**작업량**: 낮음 (30분) ✅ 완료
**영향**: 낮음-중간

---

### 3.3 주석 언어 표준화 ✅ 완료

**문제**: 혼재된 언어 주석 (한국어, 일본어, 영어).

**해결책**: 모든 주석을 한국어로 표준화 완료.

**완료된 작업**:
1. ✅ 일본어 주석을 한국어로 변경
   - `my_page_settings_section.dart`: `よく行く教회` → `자주 가는 교회`
   - `mass_time_parser.dart`: 일본어 예시 주석 한국어로 변경
   - `parish_service.dart`: 일본어 예시 한국어로 변경
2. ✅ 영어 주석을 한국어로 변경
   - `app_constants.dart`: 모든 영어 주석 한국어로 변경
   - `app_router.dart`: 라우트 주석 한국어로 변경
   - `app_routes.dart`: 주석 한국어로 변경
   - `community_presentation_providers.dart`: 주석 한국어로 변경

**작업량**: 낮음 (1-2시간) ✅ 완료
**영향**: 낮음-중간 (코드 가독성 향상)

---

## 코드 스멜 요약

| 문제 | 심각도 | 개수 | 주요 위치 | 상태 |
|-------|----------|-------|------------------|------|
| 원시 예외 던지기 | 높음 | 6개 (정상) | transaction 내부, presentation layer | ✅ 주요 서비스 완료 |
| 과도한 로깅 | 중간 | 0개 | - | ✅ 모든 print 문 AppLogger로 교체 완료 |
| 중복 정렬 | 중간 | 0 | - | ✅ Extension 추출 완료 |
| 큰 파일 (>500줄) | 중간 | 11개 | parish_detail_screen.dart, sign_up_screen.dart, daily_mass_screen.dart 등 | ⚠️ 3개 파일 즉시 분할 필요 |
| Late 변수 위험 | 중간 | 7개 이상 | Screen widgets | - |
| 불일치 모델 | 중간 | 0개 | - | ✅ 모든 커뮤니티 모델 Freezed로 마이그레이션 완료 |
| 컴파일 에러 | 높음 | 0개 | - | ✅ 모든 심각한 에러(severity 1) 수정 완료 |
| Deprecated API | 중간 | 0개 | - | ✅ RadioListTile의 deprecated onChanged를 RadioGroup으로 마이그레이션 완료 |

---

## 리팩토링 체크리스트

### Phase 1: 중요 (1주차)
- [x] `AppLogger` 서비스 생성 ✅
- [x] 모든 print 문을 logger로 교체 ✅ (주요 파일 완료)
- [x] 게시글 정렬을 extension 메서드로 추출 ✅
- [x] 커뮤니티 전용 실패 타입 생성 ✅
- [x] `firestore_post_repository.dart` 에러 처리 리팩토링 ✅
- [x] `firestore_user_repository.dart` 에러 처리 리팩토링 ✅
- [x] `firestore_notification_repository.dart` 에러 처리 리팩토링 ✅

### Phase 2: 높은 우선순위 (2주차)
- [x] `edit_profile_screen.dart` 분할 ✅ (1,484줄 → 1,105줄, 5개 위젯으로 분리)
- [x] `post_detail_screen.dart` 분할 ✅ (959줄 → 304줄, 8개 위젯으로 분리)
- [x] `parish_list_screen.dart` 분할 ✅ (739줄 → 336줄, 4개 위젯으로 분리)
- [x] `post_list_screen.dart` 분할 ✅ (543줄 → 332줄, 3개 위젯으로 분리)
- [x] `post_create_screen.dart` 분할 ✅ (516줄 → 244줄, 4개 위젯으로 분리)
- [x] `post.dart`를 Freezed로 마이그레이션 ✅
- [x] `comment.dart`를 Freezed로 마이그레이션 ✅
- [x] `notification.dart`를 Freezed로 마이그레이션 ✅
- [x] `app_user.dart`를 Freezed로 마이그레이션 ✅

### Phase 3: 새로운 큰 파일 분할 (우선순위 높음)

#### 3-1. `parish_detail_screen.dart` 분할 ✅ 완료
- **이전**: 1,225줄
- **현재**: 172줄 (약 86% 감소)
- **목표**: 400줄 이하 ✅ 달성
- **완료된 분할**:
  - `ParishDetailHeader` - 헤더 및 기본 정보 ✅
  - `ParishDetailBasicInfo` - 기본 정보 (주소, 전화, 팩스, 웹사이트) ✅
  - `ParishDetailMassTimes` - 미사 시간 섹션 ✅
  - `ParishDetailActions` - 즐겨찾기, 지도 열기 버튼 ✅
  - `MassTimeParser` - 미사 시간 파싱 유틸리티 ✅
- **작업 완료**: 이미 완료됨

#### 3-2. `sign_up_screen.dart` 분할 ✅ 완료
- **이전**: 1,043줄
- **현재**: 385줄 (약 63% 감소)
- **목표**: 300줄 이하 (거의 달성)
- **완료된 분할**:
  - `SignUpFormFields` - 기본 입력 필드 ✅
  - `SignUpParishSelector` - 성당 선택 ✅
  - `SignUpFeastDaySelector` - 축일 선택 ✅
  - `ParishSearchSheet` - 성당 검색 시트 ✅
  - `FeastDaySearchSheet` - 축일 검색 시트 ✅
  - `TermsAgreementCheckbox` - 약관 동의 ✅
  - `LoadingButton` - 제출 버튼 ✅
- **작업 완료**: 이미 완료됨

#### 3-3. `daily_mass_screen.dart` 분할 ✅ 완료
- **이전**: 1,037줄
- **현재**: 307줄 (약 70% 감소)
- **목표**: 400줄 이하 ✅ 달성
- **완료된 분할**:
  - `DailyMassHeader` - 날짜 및 제목 ✅
  - `DailyMassDisclaimerCard` - 면책 조항 카드 ✅
  - `DailyMassLiturgicalDayCard` - 전례일 카드 ✅
  - `DailyMassNoDataCard` - 데이터 없음 카드 ✅
  - `DailyMassReadings` - 독서 섹션 ✅
  - `DailyMassMeditationTips` - 묵상 가이드 ✅
  - `DailyMassComments` - 댓글 섹션 ✅
  - `DailyMassCommentInput` - 댓글 입력 ✅
  - `DailyMassLoginPrompt` - 로그인 프롬프트 ✅
- **작업 완료**: 이미 완료됨

#### 3-4. `meditation_guide_provider.dart` 분할 ✅ 완료
- **이전**: 877줄
- **현재**: 127줄 (약 85% 감소)
- **목표**: 300줄 이하 ✅ 달성
- **완료된 분할**:
  - `MeditationGuideCache` - 캐시 로직 ✅
  - `MeditationGuideFormatter` - 포맷팅 로직 ✅
  - `MeditationGuideDefaults` - 기본 묵상 가이드 ✅
  - `BibleReferenceTranslator` - 성경 참조 변환 ✅
  - `meditation_guide_provider.dart` - Provider만 유지 ✅
- **작업 완료**: 이미 완료됨

#### 3-5. `my_page_screen.dart` 분할 ✅ 완료
- **이전**: 617줄
- **현재**: 93줄 (약 85% 감소)
- **목표**: 300줄 이하 ✅ 달성
- **완료된 분할**:
  - `MyPageProfileSection` - 프로필 헤더 ✅
  - `MyPageMainParishRow` - 메인 성당 행 ✅
  - `MyPageSettingsSection` - 설정 섹션 (QR 코드, 즐겨찾기, 알림, 언어, 글씨 크기, 약관, 개인정보, 앱 정보) ✅
  - `MyPageAuthButton` - 로그인/로그아웃 버튼 ✅
  - `MyPageNavigationBar` - 네비게이션 바 ✅
  - `FontScaleSettingsTile` - 글씨 크기 설정 타일 ✅
- **작업 완료**: 추가 분할 완료

### Phase 4: 중간 우선순위 (3주차+)
- [x] `push_notification_service.dart`의 debugPrint를 AppLogger로 교체 (18개) ✅
- [x] `parish_service.dart`의 debugPrint와 throw Exception을 AppLogger/Failure로 교체 ✅
- [x] `saint_feast_day_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `prayer_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `image_upload_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `app_user.dart`의 throw Exception을 ValidationFailure로 교체 ✅
- [x] 남은 print 문 AppLogger로 교체 ✅ (모든 print 문 교체 완료)
- [x] Provider 위치 표준화 ✅
- [x] `image_upload_service.dart`를 core로 이동 ✅
- [x] 코드베이스 전체 에러 수정 ✅ - RadioListTile 마이그레이션, l10n 변수 누락 수정, const 오류 수정, 사용하지 않는 코드 제거
- [x] Repository에 대한 단위 테스트 추가 ✅
- [x] Notifier에 대한 단위 테스트 추가 ✅
- [x] 주석 언어 표준화 ✅

---

## 즉시 주의가 필요한 파일

### 완료된 파일

1. **`lib/features/community/data/repositories/firestore_post_repository.dart`** ✅ 완료
   - ✅ 로깅 서비스로 교체 완료
   - ✅ Either 패턴으로 에러 처리 완료
   - ✅ 중복 정렬 로직 추출 완료

2. **`lib/features/community/presentation/screens/post_detail_screen.dart`** ✅ 완료
   - 959줄 → 304줄로 감소 (68% 감소)
   - 8개 위젯으로 분리:
     - `PostImageViewer` - 이미지 전체화면 뷰어
     - `PostDetailHeader` - 게시글 헤더 (배지, 제목, 작성자)
     - `PostDetailAuthorInfo` - 작성자 정보
     - `PostDetailImages` - 이미지 썸네일 섹션
     - `PostDetailLikeButton` - 좋아요 버튼
     - `PostDetailCommentsSection` - 댓글 섹션
     - `PostDetailCommentInput` - 댓글 입력
     - `PostCommentSubmitter` - 댓글 제출 로직 헬퍼

3. **`lib/features/parish/presentation/screens/parish_list_screen.dart`** ✅ 완료
   - 739줄 → 336줄로 감소 (55% 감소)
   - 4개 위젯으로 분리:
     - `ParishSearchBar` - 검색 바
     - `ParishFilterBottomSheet` - 필터 바텀시트
     - `ParishEmptyState` - 빈 상태
     - `ParishNoResultState` - 검색 결과 없음 상태

### 리팩토링 완료된 파일

1. **`lib/features/profile/presentation/screens/edit_profile_screen.dart`** ✅ 완료
   - ✅ 분할 완료 (1,106줄 → 457줄, 59% 감소)
   - 총 8개 위젯으로 분리 완료

2. **`lib/features/parish/presentation/screens/parish_detail_screen.dart`** ✅ 완료
   - ✅ 분할 완료 (1,225줄 → 172줄, 약 86% 감소)
   - 완료된 분할:
     - `ParishDetailHeader` - 헤더 및 기본 정보 ✅
     - `ParishDetailBasicInfo` - 기본 정보 (주소, 전화, 팩스, 웹사이트) ✅
     - `ParishDetailMassTimes` - 미사 시간 섹션 ✅
     - `ParishDetailActions` - 즐겨찾기, 지도 열기 버튼 ✅
     - `MassTimeParser` - 미사 시간 파싱 유틸리티 ✅

3. **`lib/features/auth/presentation/screens/sign_up_screen.dart`** ✅ 완료
   - ✅ 분할 완료 (1,043줄 → 385줄, 약 63% 감소)
   - 완료된 분할:
     - `SignUpFormFields` - 기본 입력 필드 (이메일, 비밀번호 등) ✅
     - `SignUpParishSelector` - 성당 선택 섹션 ✅
     - `SignUpFeastDaySelector` - 축일 선택 섹션 ✅
     - `ParishSearchSheet` - 성당 검색 시트 ✅
     - `FeastDaySearchSheet` - 축일 검색 시트 ✅
     - `TermsAgreementCheckbox` - 약관 동의 섹션 ✅
     - `LoadingButton` - 제출 버튼 ✅

4. **`lib/features/mass/presentation/screens/daily_mass_screen.dart`** ✅ 완료
   - ✅ 분할 완료 (1,037줄 → 307줄, 약 70% 감소)
   - 완료된 분할:
     - `DailyMassHeader` - 날짜 및 제목 ✅
     - `DailyMassDisclaimerCard` - 면책 조항 카드 ✅
     - `DailyMassLiturgicalDayCard` - 전례일 카드 ✅
     - `DailyMassNoDataCard` - 데이터 없음 카드 ✅
     - `DailyMassReadings` - 독서 섹션 ✅
     - `DailyMassMeditationTips` - 묵상 가이드 섹션 ✅
     - `DailyMassComments` - 댓글 섹션 ✅
     - `DailyMassCommentInput` - 댓글 입력 ✅
     - `DailyMassLoginPrompt` - 로그인 프롬프트 ✅

5. **`lib/shared/providers/meditation_guide_provider.dart`** ✅ 완료
   - ✅ 분할 완료 (877줄 → 127줄, 약 85% 감소)
   - 완료된 분할:
     - `MeditationGuideCache` - 캐시 관련 로직 ✅
     - `MeditationGuideFormatter` - 포맷팅 관련 로직 ✅
     - `MeditationGuideDefaults` - 기본 묵상 가이드 ✅
     - `BibleReferenceTranslator` - 성경 참조 변환 ✅
     - `meditation_guide_provider.dart` - Provider만 유지 ✅

6. **`lib/features/profile/presentation/screens/my_page_screen.dart`** ✅ 완료
   - ✅ 분할 완료 (617줄 → 93줄, 약 85% 감소)
   - 완료된 분할:
     - `MyPageProfileSection` - 프로필 헤더 ✅
     - `MyPageMainParishRow` - 메인 성당 행 ✅
     - `MyPageSettingsSection` - 설정 섹션 (QR 코드, 즐겨찾기, 알림, 언어, 글씨 크기, 약관, 개인정보, 앱 정보) ✅
     - `MyPageAuthButton` - 로그인/로그아웃 버튼 ✅
     - `MyPageNavigationBar` - 네비게이션 바 ✅
     - `FontScaleSettingsTile` - 글씨 크기 설정 타일 ✅

3. **`lib/features/community/presentation/screens/post_create_screen.dart`** ✅ 완료
   - ✅ 분할 완료 (516줄 → 244줄, 4개 위젯으로 분리)
   - ✅ 16개의 print 문을 AppLogger로 교체 완료
   - ✅ 폼 컴포넌트 추출 완료 (PostFormFields, PostImagePicker, PostOfficialSettings, PostFormSubmitButton)

4. **`lib/core/data/services/push_notification_service.dart`** ✅ 완료
   - ✅ 18개의 debugPrint를 AppLogger.notification()으로 교체 완료

5. **`lib/core/data/services/image_upload_service.dart`** ✅ 완료
   - ✅ `lib/features/community/core/services/`에서 `lib/core/data/services/`로 이동 완료
   - ✅ import 경로 업데이트 완료
   - ✅ throw Exception을 Failure로 교체 완료

6. **Provider 구성 표준화** ✅ 완료
   - ✅ Repository Provider는 `data/providers/`에 유지
   - ✅ UI state Provider는 `presentation/providers/`로 이동
   - ✅ `community_presentation_providers.dart` 생성
   - ✅ 모든 import 경로 업데이트 (14개 파일)

7. **신고 기능 구현** ✅ 완료
   - ✅ 신고 모델 및 리포지토리 생성 (`Report`, `ReportRepository`)
   - ✅ 공통 신고 다이얼로그 위젯 생성 (`ReportDialog`)
   - ✅ 게시글/댓글에 신고 버튼 추가
   - ✅ Cloud Functions onCreate 트리거 추가 (Slack 알림 전송)
   - ✅ Firestore Rules에 reports 컬렉션 규칙 추가
   - ✅ 중복 신고 방지 로직 구현 (5분 내 동일 대상 신고 방지)
   - ✅ Slack webhook URL을 dotenv로 처리 (`functions/.env` 파일, dotenv 패키지 추가)

---

## 코드 품질 개선 ✅ 완료

### 컴파일 에러 수정 ✅ 완료 (2025-12-15)

**문제**: 코드베이스 전체에 여러 컴파일 에러와 경고가 존재했습니다.

**완료된 작업**:
1. ✅ **RadioListTile Deprecated API 마이그레이션**
   - `report_dialog.dart`에서 deprecated된 `onChanged`를 `RadioGroup`으로 변경
   - Material 3의 새로운 Radio API 적용

2. ✅ **l10n 변수 누락 문제 수정** (20+ 파일)
   - `location_permission_screen.dart`, `comment_item.dart`, `post_edit_screen.dart`, `post_create_screen.dart`, `post_detail_screen.dart`, `my_page_screen.dart`, `favorite_parishes_screen.dart`, `edit_profile_screen.dart`, `qr_scanner_screen.dart`, `qr_code_dialog.dart`, `prayer_screen.dart`, `parish_list_screen.dart`, `parish_detail_screen.dart` 등
   - `appLocalizationsSyncProvider`를 사용하여 l10n 변수 추가

3. ✅ **const 키워드 오류 수정**
   - 런타임 값을 사용하는 위젯에서 const 제거
   - `const Text(l10n.xxx)` → `Text(l10n.xxx)` 형태로 수정
   - `const SnackBar(content: Text(l10n.xxx))` → `SnackBar(content: Text(l10n.xxx))` 형태로 수정

4. ✅ **사용하지 않는 코드 제거**
   - 사용하지 않는 변수 제거 (`l10n`, `theme` 등)
   - 사용하지 않는 import 제거
   - 중복 import 제거
   - 사용하지 않는 함수 제거 (`_dateTimeToJson`, `_dateTimeFromJson` in `comment.dart`, `post.dart`, `notification.dart`)

5. ✅ **스타일 경고 수정**
   - 불필요한 언더스코어 사용 수정 (`__` → `_`)
   - `prefer_final_fields` 경고 수정

**결과**: 모든 심각한 에러(severity 1) 수정 완료, 코드베이스가 깨끗한 컴파일 상태 유지

**작업량**: 중간 (3-4시간) ✅ 완료
**영향**: 높음 (코드 품질 및 유지보수성 향상)

---

## lib 전체 분석 결과 (2025-12-18 업데이트)

### 전체 통계
- **총 파일 수**: 194개 Dart 파일 (자동 생성 파일 제외)
- **총 코드 라인**: 약 33,275줄 (자동 생성 파일 제외)
- **큰 파일 (500줄 이상)**: 8개
- **큰 파일 (400줄 이상)**: 15개

### 큰 파일 상세 분석

#### 자동 생성 파일 (리팩토링 불필요)
- `app_localizations.dart`: 1,376줄 - 번역 유틸리티 (자동 생성) ✅
- Freezed 생성 파일들: `*.freezed.dart`, `*.g.dart` - 자동 생성

#### 리팩토링 완료된 파일

| 파일 | 이전 줄 수 | 현재 줄 수 | 감소율 | 상태 |
|------|-----------|-----------|--------|------|
| `parish_detail_screen.dart` | 1,225 | 172 | 86% | ✅ 완료 |
| `sign_up_screen.dart` | 1,043 | 385 | 63% | ✅ 완료 |
| `daily_mass_screen.dart` | 1,037 | 307 | 70% | ✅ 완료 |
| `meditation_guide_provider.dart` | 877 | 127 | 85% | ✅ 완료 |
| `my_page_screen.dart` | 617 | 93 | 85% | ✅ 완료 |
| `parish_list_screen.dart` | 739 | 336 | 55% | ✅ 완료 |
| `post_detail_screen.dart` | 959 | 304 | 68% | ✅ 완료 |
| `edit_profile_screen.dart` | 1,106 | 457 | 59% | ✅ 완료 |

#### 현재 큰 파일 (리팩토링 고려 가능)

| 파일 | 줄 수 | 우선순위 | 권장 작업 |
|------|-------|----------|-----------|
| `firestore_post_repository.dart` | 967 | 낮음 | 적절한 크기 (Repository) |
| `auth_repository_impl.dart` | 748 | 낮음 | 적절한 크기 (Repository) |
| `parish_list_screen.dart` | 683 | 낮음 | 추가 분할 고려 가능 |
| `liturgical_reading_service.dart` | 629 | 낮음 | 적절한 크기 (서비스) |
| `home_screen.dart` | 626 | 중간 | 위젯 분할 고려 |
| `mass_time_parser.dart` | 623 | 낮음 | 적절한 크기 (유틸리티) |
| `post_detail_screen.dart` | 595 | 낮음 | 추가 분할 고려 가능 |
| `bible_reference_translator.dart` | 571 | 낮음 | 적절한 크기 (유틸리티) |
| `saint_feast_day_modal.dart` | 567 | 낮음 | 위젯 분할 고려 |
| `openai_service.dart` | 522 | 낮음 | 적절한 크기 (서비스) |
| `post_file_picker.dart` | 515 | 낮음 | 위젯 분할 고려 |
| `post_form_notifier.dart` | 476 | 낮음 | 적절한 크기 (Notifier) |
| `sign_in_screen.dart` | 461 | 낮음 | 위젯 분할 고려 |
| `image_upload_service.dart` | 461 | 낮음 | 적절한 크기 (서비스) |
| `edit_profile_screen.dart` | 460 | 낮음 | 추가 분할 고려 가능 |

### TODO 주석 분석

| 위치 | 내용 | 우선순위 | 상태 |
|------|------|----------|------|
| `expandable_content_card.dart:99` | 성경 읽기 화면 연결 | 낮음 | - |
| `qr_scanner_screen.dart:110` | 메신저 기능 구현 시 사용자 추가 처리 | 낮음 | - |
| `qr_scanner_screen.dart:150` | 메신저 기능 구현 시 "友達追加" 버튼 추가 | 낮음 | - |

### 코드 품질 지표

| 지표 | 값 | 상태 |
|------|-----|------|
| 평균 파일 크기 | ~171줄 | 양호 |
| 최대 파일 크기 | 1,376줄 (자동 생성) | 양호 |
| 500줄 이상 파일 | 8개 | 양호 (대부분 Repository/Service) |
| 1000줄 이상 파일 | 0개 (자동 생성 제외) | ✅ 개선 완료 |
| TODO 주석 | 3개 | 낮은 우선순위 |
| 주석 언어 표준화 | ✅ 완료 | 한국어로 통일 |

### 권장 리팩토링 우선순위

#### 우선순위 1: 높음 (즉시 진행) ✅ 완료
1. **`parish_detail_screen.dart` 분할** (1,225줄 → 178줄, 약 85% 감소) ✅
   - 예상 작업량: 4-6시간
   - 영향: 높음 (가독성 및 유지보수성)
   - 완료: Header, BasicInfo, MassTimes, Actions 위젯 추출 및 mass_time_parser 유틸리티 분리

2. **`sign_up_screen.dart` 분할** (1,043줄 → 390줄, 약 63% 감소) ✅
   - 예상 작업량: 4-6시간
   - 영향: 높음 (가독성 및 테스트 가능성)
   - 완료: FormFields, ParishSelector, FeastDaySelector, ParishSearchSheet, FeastDaySearchSheet 위젯 추출

3. **`daily_mass_screen.dart` 분할** (1,037줄 → 약 300줄, 약 71% 감소) ✅
   - 예상 작업량: 4-6시간
   - 영향: 높음 (가독성 및 재사용성)
   - 완료: Header, Readings, MeditationTips, Comments, CommentInput, LoginPrompt 위젯 추출

#### 우선순위 2: 중간 (단기간 내 진행) ✅ 완료
4. **`meditation_guide_provider.dart` 분할** (877줄 → 약 120줄, 약 86% 감소) ✅
   - 예상 작업량: 2-3시간
   - 영향: 중간 (코드 구조 개선)
   - 완료: 캐시 관리, 참고 말씀 포맷팅, 성경 참조 변환, 기본 묵상 가이드 유틸리티 분리

5. **`my_page_screen.dart` 분할** (617줄 → 93줄, 약 85% 감소) ✅
   - 예상 작업량: 2-3시간
   - 영향: 중간 (가독성 개선)
   - 완료: ProfileSection, SettingsSection, AuthButton, NavigationBar, MainParishRow, FontScaleSettingsTile 위젯 추출

#### 우선순위 3: 낮음 (장기 계획) ✅ 완료
6. **`app_localizations.dart` 자동 생성화** ✅
   - 예상 작업량: 4-6시간
   - 영향: 낮음-중간 (유지보수성 개선)
   - 완료: JSON에서 Dart 코드를 자동 생성하는 Python 스크립트 작성 (`scripts/generate_localizations.py`)
   - 참고: 특수 메서드(`meditationGuideTitle`, `liturgicalDay`, `hasData`)는 수동 추가 필요 (자세한 내용은 `scripts/README_LOCALIZATIONS.md` 참조)

---

## 테스트 추가 ✅ 진행 중

### Repository 단위 테스트 ✅ 진행 중
다음 Repository에 대한 단위 테스트를 작성했습니다:

1. **`FirestoreUserRepository`** ✅
   - `getUserById` 테스트 (성공, 사용자 없음, FirebaseException, 일반 예외)
   - `saveUser` 테스트 (성공, FirebaseException, 일반 예외)
   - 테스트 파일: `test/features/community/data/repositories/firestore_user_repository_test.dart`
   - 테스트 케이스: 7개

2. **`FirestoreNotificationRepository`** ✅
   - `createNotification` 테스트 (성공, FirebaseException, 일반 예외)
   - 테스트 파일: `test/features/community/data/repositories/firestore_notification_repository_test.dart`
   - 테스트 케이스: 3개

3. **`AuthRepositoryImpl`** ✅
   - `getCurrentUser` 테스트 (로그인된 사용자 있음, 없음)
   - `signOut` 테스트 (성공, 실패)
   - 테스트 파일: `test/features/auth/data/repositories/auth_repository_impl_test.dart`
   - 테스트 케이스: 3개

4. **`FirestorePostRepository`** ✅ (2025-12-18 추가)
   - `createPost` 테스트 (성공, 권한 부족, FirebaseException, 일반 예외)
   - `updatePost` 테스트 (성공, 변경 없음, FirebaseException)
   - `deletePost` 테스트 (성공, FirebaseException)
   - `getPostById` 테스트 (성공, 존재하지 않음, FirebaseException)
   - `isLiked` 테스트 (좋아요 있음, 없음)
   - 테스트 파일: `test/features/community/data/repositories/firestore_post_repository_test.dart`
   - 테스트 케이스: 14개
   - 참고: `createComment`, `toggleLike`, `searchPosts`는 Transaction/Query 복잡도로 인해 통합 테스트에서 검증 권장

5. **`FirestoreReportRepository`** ✅ (2025-12-18 추가)
   - `createReport` 테스트 (성공, 중복 신고 방지, FirebaseException, 인덱스 빌딩 중 에러 처리, 일반 예외)
   - 테스트 파일: `test/features/community/data/repositories/firestore_report_repository_test.dart`
   - 테스트 케이스: 5개

6. **`NotificationSettingsRepositoryImpl`** ✅
   - 테스트 파일: `test/features/profile/data/repositories/notification_settings_repository_impl_test.dart`
   - 테스트 케이스: 9개

7. **`ParishRepositoryImpl`** ✅
   - 테스트 파일: `test/features/parish/data/repositories/parish_repository_impl_test.dart`
   - 테스트 케이스: 12개

8. **`SaintFeastDayRepositoryImpl`** ✅
   - 테스트 파일: `test/features/profile/data/repositories/saint_feast_day_repository_impl_test.dart`
   - 테스트 케이스: 3개

### Notifier 단위 테스트 ✅ 완료
다음 Notifier에 대한 단위 테스트를 작성했습니다:

1. **`PostFormNotifier`** ✅
   - 상태 변경 테스트 (`setTitle`, `setBody`, `setCategory`, `setIsOfficial`, `setIsPinned`)
   - 유효성 검사 테스트 (제목/본문 비어있음)
   - 초기 상태 테스트 (기본값, initialPost 반영)
   - 테스트 파일: `test/features/community/presentation/notifiers/post_form_notifier_test.dart`
   - 테스트 케이스: 10개

### 테스트 도구
- **mocktail**: Mock 객체 생성 및 테스트 작성
- **flutter_test**: Flutter 테스트 프레임워크

### Provider 단위 테스트 ✅ 완료
다음 Provider에 대한 단위 테스트를 작성했습니다:

1. **`LiturgyThemeProvider`** ✅
   - 테스트 파일: `test/shared/providers/liturgy_theme_provider_test.dart`
   - 테스트 케이스: 4개

2. **`FontScaleProvider`** ✅
   - 테스트 파일: `test/shared/providers/font_scale_provider_test.dart`
   - 테스트 케이스: 7개

3. **`LocaleProvider`** ✅
   - 테스트 파일: `test/shared/providers/locale_provider_test.dart`
   - 테스트 케이스: 7개

### 테스트 실행 결과
- ✅ 총 13개 테스트 파일 작성 완료
- ✅ 총 85개 테스트 케이스 작성 완료
- ✅ Repository, Notifier, Provider의 주요 기능에 대한 테스트 커버리지 확보

### 남은 작업
- 추가 Notifier 테스트 (필요 시)
- Transaction 기반 메서드 통합 테스트 (`createComment`, `toggleLike`)

**참고**: 추가 테스트는 필요에 따라 확장 가능합니다.
