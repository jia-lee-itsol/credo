# Credo 리팩토링 가이드

## 개요

이 문서는 `/lib` 디렉토리에 대한 종합 분석을 기반으로 Credo 코드베이스의 리팩토링 우선순위와 권장사항을 설명합니다.

**마지막 업데이트**: 2025-12-12
**전체 코드베이스**: 약 27,000줄의 Dart 코드, 135개 파일

---

## 요약

Credo 코드베이스는 **기능 기반 모듈식 설계와 함께 Clean Architecture**를 구현합니다. 아키텍처 기반은 견고하지만, 유지보수성, 일관성, 코드 품질을 개선하기 위해 여러 영역에서 리팩토링이 필요합니다.

### 건강 점수: 7/10

| 카테고리 | 상태 |
|----------|--------|
| 아키텍처 | 양호 |
| 상태 관리 | 양호 |
| 에러 처리 | ✅ 개선 완료 (커뮤니티 repository 표준화 완료) |
| 로깅 | ✅ 개선 완료 (주요 파일 AppLogger 적용 완료) |
| 코드 구성 | 개선됨 (일부 진행 중) |
| 테스트 커버리지 | 없음 |

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
| `edit_profile_screen.dart` | 1,484 → 1,105 | 3-4개 위젯으로 분할 | ✅ 완료 (379줄 감소, 5개 위젯으로 분리) |
| `post_detail_screen.dart` | 959 → 304 | 댓글, 이미지 갤러리 추출 | ✅ 완료 (655줄 감소, 8개 위젯으로 분리) |
| `parish_list_screen.dart` | 739 → 336 | 필터 다이얼로그, 리스트 아이템 추출 | ✅ 완료 (403줄 감소, 4개 위젯으로 분리) |
| `post_list_screen.dart` | 543 | 게시글 카드 위젯 추출 | - |
| `post_create_screen.dart` | 516 | 폼 컴포넌트 추출 | - |

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
- ✅ `edit_profile_screen.dart` 분할 완료 (1,484줄 → 1,112줄)
  - 5개 위젯으로 분리: `ProfileImagePicker`, `ProfileBasicInfoSection`, `ProfileParishInfoSection`, `ProfileSacramentDatesSection`, `ProfileGodparentSection`
  - 코드 가독성 및 재사용성 향상

**완료된 작업**:
- ✅ `parish_list_screen.dart` 분할 완료 (739줄 → 338줄)
  - 4개 위젯으로 분리: `ParishSearchBar`, `ParishFilterBottomSheet`, `ParishEmptyState`, `ParishNoResultState`
  - 코드 가독성 및 재사용성 향상

**남은 작업**:
- `post_list_screen.dart` (543줄)
- `post_create_screen.dart` (516줄)

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
- `lib/features/community/data/models/post.dart`
- `lib/features/community/data/models/app_user.dart`
- `lib/features/community/data/models/comment.dart`
- `lib/features/community/data/models/notification.dart`

**작업 항목**:
1. 커뮤니티 모델에 `@freezed` 어노테이션 추가
2. build_runner를 통해 `copyWith`, `==`, `hashCode` 생성
3. 수동 구현 제거

**작업량**: 중간 (2-3시간)
**영향**: 중간 (일관성 및 보일러플레이트 감소)

---

### 2.3 Provider 구성 표준화

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

**작업량**: 낮음 (1-2시간)
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

### 3.2 공유 서비스를 Core로 이동

**문제**: `image_upload_service.dart`가 커뮤니티 기능에 있지만 재사용 가능합니다.

**현재 위치**:
```
lib/features/community/core/services/image_upload_service.dart
```

**권장 위치**:
```
lib/core/data/services/image_upload_service.dart
```

**현재 상태**: 
- 커뮤니티 기능 내부에 위치하지만 다른 기능에서도 사용 가능
- 향후 재사용 필요 시 이동 고려

**작업량**: 낮음 (30분)
**영향**: 낮음-중간

---

### 3.3 주석 언어 표준화

**문제**: 혼재된 언어 주석 (한국어, 일본어, 영어).

```dart
// 한국어
// 게시글 생성 실패

// 일본어
// 'ホームへ戻る'

// 영어
// Firebase initialization
```

**권장사항**: 국제 협업을 위해 코드 주석은 영어로 표준화.

**작업량**: 낮음 (1-2시간)
**영향**: 낮음

---

## 코드 스멜 요약

| 문제 | 심각도 | 개수 | 주요 위치 | 상태 |
|-------|----------|-------|------------------|------|
| 원시 예외 던지기 | 높음 | 6개 (정상) | transaction 내부, presentation layer | ✅ 주요 서비스 완료 |
| 과도한 로깅 | 중간 | 16개 (1개 파일) | `post_create_screen.dart`(16) | 🔄 진행 중 |
| 중복 정렬 | 중간 | 0 | - | ✅ Extension 추출 완료 |
| 큰 파일 | 중간 | 3개 | `edit_profile_screen.dart`(1,105), `post_list_screen.dart`(543), `post_create_screen.dart`(516) | 🔄 진행 중 (3개 완료) |
| Late 변수 위험 | 중간 | 7개 이상 | Screen widgets | - |
| 불일치 모델 | 중간 | 4개 | Community models | - |

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
- [ ] `post_list_screen.dart` 분할 (543줄)
- [ ] `post_create_screen.dart` 분할 (516줄)
- [ ] `post.dart`를 Freezed로 마이그레이션
- [ ] `comment.dart`를 Freezed로 마이그레이션
- [ ] `notification.dart`를 Freezed로 마이그레이션

### Phase 3: 중간 우선순위 (3주차+)
- [x] `push_notification_service.dart`의 debugPrint를 AppLogger로 교체 (18개) ✅
- [x] `parish_service.dart`의 debugPrint와 throw Exception을 AppLogger/Failure로 교체 ✅
- [x] `saint_feast_day_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `prayer_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `image_upload_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `app_user.dart`의 throw Exception을 ValidationFailure로 교체 ✅
- [ ] 남은 print 문 AppLogger로 교체 (1개 파일, 16개) - `post_create_screen.dart`
- [ ] Repository에 대한 단위 테스트 추가
- [ ] Notifier에 대한 단위 테스트 추가
- [ ] Provider 위치 표준화
- [ ] `image_upload_service.dart`를 core로 이동
- [ ] 주석 언어 표준화

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

### 남은 작업이 필요한 파일

1. **`lib/features/profile/presentation/screens/edit_profile_screen.dart`**
   - 1,105줄 (추가 분할 가능)
   - 이미 5개 위젯으로 분리됨

2. **`lib/features/community/presentation/screens/post_list_screen.dart`**
   - 543줄 (분할 필요)
   - 게시글 카드 위젯 추출 권장

3. **`lib/features/community/presentation/screens/post_create_screen.dart`**
   - 516줄 (분할 필요)
   - 16개의 print 문 → AppLogger로 교체 필요
   - 폼 컴포넌트 추출 권장

4. **`lib/core/data/services/push_notification_service.dart`** ✅ 완료
   - ✅ 18개의 debugPrint를 AppLogger.notification()으로 교체 완료

---

## 다음 단계

1. 각 리팩토링 작업에 대한 GitHub 이슈 생성
2. 영향과 의존성을 기반으로 우선순위 결정
3. 각 리팩토링 작업에 대한 기능 브랜치 생성
4. 주요 리팩토링 전에 테스트 추가
5. 점진적으로 검토 및 병합
