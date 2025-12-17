# Credo 아키텍처 문서

## 개요

Credo는 가톨릭 커뮤니티 참여를 위한 Flutter 모바일 애플리케이션입니다. 이 앱은 **기능 기반 모듈 구조**와 함께 **Clean Architecture**를 구현합니다.

**마지막 업데이트**: 2025-12-16
**전체 코드베이스**: 약 27,000줄의 Dart 코드, 135개 파일

---

## 프로젝트 구조

```
lib/
├── config/                    # 앱 설정
│   └── router.dart            # GoRouter 라우팅 설정
│
├── core/                      # 공통 관심사
│   ├── constants/             # 전역 상수
│   │   ├── app_constants.dart
│   │   └── liturgy_constants.dart
│   ├── data/                  # 핵심 데이터 레이어
│   │   ├── models/            # 공유 데이터 모델
│   │   │   ├── liturgical_calendar_model.dart
│   │   │   └── saint_feast_day_model.dart
│   │   └── services/          # 핵심 서비스
│   │       ├── geocoding_service.dart          # Google Maps Geocoding API
│   │       ├── image_upload_service.dart        # Firebase Storage 이미지 업로드
│   │       ├── liturgical_calendar_service.dart
│   │       ├── liturgical_reading_service.dart
│   │       ├── parish_service.dart
│   │       ├── prayer_service.dart
│   │       ├── push_notification_service.dart   # FCM 푸시 알림
│   │       └── saint_feast_day_service.dart
│   ├── error/                 # 에러 처리
│   │   ├── exceptions.dart    # 예외 정의
│   │   └── failures.dart      # 실패 타입 정의
│   ├── services/              # 공통 서비스
│   │   └── logger_service.dart # 중앙화된 로깅 서비스
│   ├── theme/                 # 테마 관리
│   │   └── app_theme.dart
│   └── utils/                 # 유틸리티 함수
│       ├── date_utils.dart
│       ├── location_utils.dart
│       └── validators.dart
│
├── features/                  # 기능 모듈
│   ├── auth/                  # 인증
│   ├── community/             # 커뮤니티 포럼 (상세 구조는 아래 참조)
│   ├── home/                  # 홈 화면
│   ├── mass/                  # 일일 미사 독서
│   ├── onboarding/            # 사용자 온보딩
│   ├── parish/                # 성당 디렉토리
│   ├── prayer/                # 기도 기능
│   ├── profile/               # 사용자 프로필
│   └── splash/                # 스플래시 화면
│
├── shared/                    # 공유 컴포넌트
│   ├── providers/             # 전역 Riverpod providers
│   └── widgets/                # 재사용 가능한 UI 컴포넌트
│
├── functions/                 # Firebase Cloud Functions
│   ├── src/
│   │   └── index.ts           # Cloud Functions 진입점
│   ├── .env                   # 환경 변수 (로컬 개발용, Git에 커밋 안 됨)
│   └── package.json           # Node.js 의존성
│
└── main.dart                  # 앱 진입점
```

---

## 기능 모듈 구조

각 기능은 Clean Architecture 원칙을 따릅니다:

```
features/{feature_name}/
├── data/                      # 데이터 레이어
│   ├── models/                # 데이터 전송 객체
│   ├── providers/              # Repository providers
│   └── repositories/          # Repository 구현
│
├── domain/                    # 도메인 레이어
│   ├── entities/              # 비즈니스 엔티티
│   ├── repositories/          # Repository 인터페이스
│   └── usecases/              # 비즈니스 로직 (선택사항)
│
└── presentation/              # 프레젠테이션 레이어
    ├── notifiers/              # State notifiers
    ├── providers/              # UI 상태 providers (StreamProvider, FutureProvider, StateNotifierProvider)
    ├── screens/                # 화면 위젯
    └── widgets/                # 기능별 위젯
```

---

## 아키텍처 레이어

### 1. 프레젠테이션 레이어

**책임**: UI 렌더링 및 사용자 상호작용 처리.

**구성 요소**:
- **Screens**: UI를 구성하는 전체 페이지 위젯 (라우팅에 등록된 독립 화면)
- **Widgets**: 재사용 가능한 UI 컴포넌트
- **Notifiers**: 복잡한 UI 상태를 위한 StateNotifier 클래스
- **Providers** (`presentation/providers/`): UI 상태를 관리하는 Provider (StreamProvider, FutureProvider, StateNotifierProvider)

**구조 원칙**:
- 모든 화면은 `screens/` 디렉토리에 위치 (이전 `pages/` 디렉토리는 `screens/`로 통합됨)
- 큰 화면 파일(500줄 이상)은 위젯으로 분할하여 `widgets/` 디렉토리에 배치
- 예: `post_detail_screen.dart` (959줄) → 8개 위젯으로 분할 (302줄)

**예시**:
```dart
// lib/features/community/presentation/screens/post_list_screen.dart
class PostListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(parishId));
    return postsAsync.when(
      data: (posts) => ListView.builder(...),
      loading: () => LoadingIndicator(),
      error: (e, st) => ErrorWidget(e),
    );
  }
}
```

### 2. 도메인 레이어

**책임**: 비즈니스 로직 및 규칙.

**구성 요소**:
- **Entities**: 핵심 비즈니스 객체 (Freezed 사용)
- **Repository Interfaces**: 추상 계약
- **Use Cases**: 단일 목적 비즈니스 작업 (선택사항)

**예시**:
```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<Failure, void>> signOut();
}
```

### 3. 데이터 레이어

**책임**: 데이터 접근 및 영속성.

**구성 요소**:
- **Models**: JSON/Firestore 직렬화
- **Repository Implementations**: 구체적인 데이터 접근 (모두 `Either<Failure, T>` 패턴 사용)
- **Providers** (`data/providers/`): Repository 인스턴스를 제공하는 Provider

**에러 처리 원칙**:
- 모든 Repository 메서드는 `Either<Failure, T>` 반환
- 원시 Exception 던지기 금지
- 기능별 전용 Failure 타입 사용 (예: `PostCreationFailure`)

**예시**:
```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return Right(null);
      // ... implementation
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}

// lib/features/community/data/repositories/firestore_post_repository.dart
@override
Future<Either<Failure, Post>> createPost(Post post) async {
  try {
    // ... implementation
    return Right(createdPost);
  } on FirebaseException catch (e) {
    return Left(PostCreationFailure(message: e.message ?? '게시글 생성 실패'));
  } catch (e) {
    return Left(PostCreationFailure(message: e.toString()));
  }
}
```

---

## 상태 관리

### Riverpod Providers

앱은 상태 관리 및 의존성 주입을 위해 **Riverpod**을 사용합니다.

**사용되는 Provider 타입**:

| 타입 | 사용 사례 | 예시 |
|------|----------|---------|
| `Provider` | 간단한 계산된 값 | `firebaseAuthProvider` |
| `FutureProvider` | 일회성 비동기 작업 | `postByIdProvider` |
| `StreamProvider` | 실시간 데이터 스트림 | `communityPostsProvider` |
| `StateNotifierProvider` | 복잡한 가변 상태 | `postFormNotifierProvider` |

**Provider 구성**:

Provider는 레이어별로 분리되어 있습니다:

1. **Repository Provider** (`features/{feature}/data/providers/`):
   - Repository 인스턴스를 제공하는 Provider
   - 예: `postRepositoryProvider`, `userRepositoryProvider`

2. **UI State Provider** (`features/{feature}/presentation/providers/`):
   - UI 상태를 관리하는 Provider (StreamProvider, FutureProvider, StateNotifierProvider)
   - 예: `communityPostsProvider`, `postByIdProvider`, `postFormNotifierProvider`

3. **Global Provider** (`shared/providers/`):
   - 앱 전역에서 사용되는 Provider
   - 예: `auth_provider.dart`, `location_provider.dart`, `liturgy_theme_provider.dart`, `font_scale_provider.dart`

**예시**:
```dart
// lib/features/community/data/providers/community_repository_providers.dart
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return FirestorePostRepository();
});

// lib/features/community/presentation/providers/community_presentation_providers.dart
final communityPostsProvider = StreamProvider.autoDispose
    .family<List<Post>, String?>((ref, String? parishId) {
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchCommunityPosts(parishId: parishId);
    });

// lib/shared/providers/auth_provider.dart
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider);
});
```

---

## 데이터 흐름

```
┌─────────────────────────────────────────────────────────────────┐
│                        프레젠테이션 레이어                        │
│  ┌─────────┐    ┌──────────┐    ┌──────────────────────────┐    │
│  │ Screen  │───▶│ Provider │───▶│ StateNotifier (optional) │    │
│  └─────────┘    └──────────┘    └──────────────────────────┘    │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│                         도메인 레이어                              │
│  ┌────────────────────────┐    ┌─────────────────────────────┐    │
│  │ Repository Interface   │    │ Entity (Freezed)            │    │
│  └────────────────────────┘    └─────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│                          데이터 레이어                            │
│  ┌────────────────────────┐    ┌─────────────────────────────┐    │
│  │ Repository Impl        │───▶│ Data Model                  │    │
│  └────────────────────────┘    └─────────────────────────────┘    │
│                              │                                    │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ Firebase (Auth / Firestore / Storage / FCM)                 │  │
│  └─────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────┘
```

---

## 에러 처리

### 실패 타입

`lib/core/error/failures.dart`에 정의된 기본 실패 타입:

```dart
abstract class Failure {
  final String message;
  final String? code;
  const Failure({required this.message, this.code});
}

class ServerFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class FirebaseFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
class NotFoundFailure extends Failure { ... }
class PermissionFailure extends Failure { ... }
class UnknownFailure extends Failure { ... }
class TimeoutFailure extends Failure { ... }
```

### 커뮤니티 전용 실패 타입

`lib/features/community/domain/failures/community_failures.dart`에 정의된 커뮤니티 기능 전용 실패 타입:

```dart
class PostCreationFailure extends Failure { ... }
class PostUpdateFailure extends Failure { ... }
class PostDeleteFailure extends Failure { ... }
class PostNotFoundFailure extends NotFoundFailure { ... }
class CommentCreationFailure extends Failure { ... }
class NotificationCreationFailure extends Failure { ... }
class NotificationUpdateFailure extends Failure { ... }
class NotificationDeleteFailure extends Failure { ... }
class UserNotFoundFailure extends NotFoundFailure { ... }
class UserSaveFailure extends Failure { ... }
class LikeToggleFailure extends Failure { ... }
class InsufficientPermissionFailure extends PermissionFailure { ... }
class ReportCreationFailure extends Failure { ... }
```

### Either 패턴

함수형 에러 처리를 위해 `dartz` 라이브러리 사용:

```dart
Future<Either<Failure, Post>> createPost(Post post) async {
  try {
    final docRef = await _firestore.collection('posts').add(post.toJson());
    return Right(post.copyWith(id: docRef.id));
  } on FirebaseException catch (e) {
    return Left(FirebaseFailure(message: e.message ?? 'Unknown error'));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

---

## 기능 상세

### Auth 기능

**인증 방법**:
- 이메일/비밀번호
- Google Sign-In
- Apple Sign-In

**주요 파일**:
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/entities/user_entity.dart`
- `lib/features/auth/presentation/screens/sign_in_screen.dart`

### Community 기능

**기능**:
- 게시글 생성/수정/삭제
- 댓글 및 답글
- 이미지 업로드 및 갤러리 뷰어
- 좋아요 기능
- 신고 기능 (게시글/댓글 신고, Slack 알림, 자동 숨김 처리)
- 푸시 알림
- 공식 공지 vs 커뮤니티 게시글
- 게시글 정렬 (핀 고정 우선, 시간순/인기순)
- Admin 게시글 비표시 기능 (소속 교회 게시글만)
- 두 손가락 줌 기능 (InteractiveViewer)

**주요 파일**:
- `lib/features/community/data/repositories/firestore_post_repository.dart`
- `lib/features/community/data/models/post.dart`
- `lib/features/community/data/models/report.dart` - 신고 모델
- `lib/features/community/data/repositories/firestore_report_repository.dart` - 신고 리포지토리
- `lib/features/community/presentation/widgets/report_dialog.dart` - 신고 다이얼로그 위젯
- `lib/features/community/domain/extensions/post_extensions.dart` - 게시글 정렬 로직
- `lib/features/community/domain/failures/community_failures.dart` - 커뮤니티 전용 실패 타입 (ReportCreationFailure 포함)
- `lib/features/community/presentation/screens/post_detail_screen.dart` (304줄, 8개 위젯으로 분할됨)
  - 위젯: `PostImageViewer`, `PostDetailHeader`, `PostDetailAuthorInfo`, `PostDetailImages`, `PostDetailLikeButton`, `PostDetailCommentsSection`, `PostDetailCommentInput`, `PostCommentSubmitter`
- `lib/features/parish/presentation/screens/parish_list_screen.dart` (336줄, 4개 위젯으로 분할됨)
  - 위젯: `ParishSearchBar`, `ParishFilterBottomSheet`, `ParishEmptyState`, `ParishNoResultState`

### Parish 기능

**기능**:
- 검색 기능이 있는 성당 디렉토리
- 도, 대성당, 미사 시간별 필터링
- 외국어 미사 지원
- 성당 상세 정보
- 거리순 정렬 기능 (위치 기반)
  - 사용자 위치 기반 거리 계산
  - 거리순 정렬 (기본값: 비활성화, 사용자가 활성화 가능)
  - 위치 권한 요청 및 처리
  - 위치 정보 없을 때 정렬 비활성화

**주요 파일**:
- `lib/features/parish/data/repositories/parish_repository_impl.dart`
- `lib/features/parish/presentation/screens/parish_list_screen.dart`
- `lib/shared/providers/location_provider.dart` - 위치 및 거리 계산 Provider
- `lib/core/data/services/geocoding_service.dart` - Google Maps Geocoding API

### Profile 기능

**기능**:
- 사용자 프로필 관리
- 성인 축일 추적
- 언어 설정
- 친구 추가를 위한 QR 코드 스캐너

**주요 파일**:
- `lib/features/profile/presentation/screens/edit_profile_screen.dart`
- `lib/features/profile/presentation/screens/my_page_screen.dart`

### Admin 기능

**기능**:
- 소속 교회 게시글 비표시/표시 기능
- 신고 기반 자동 게시글 숨김 (신고 3개 이상 시)

**구현 현황**:
- Admin 권한 체크 (`UserEntity.isAdmin` getter)
- Firestore Rules에 `isAdminOfPostParish()` helper function 추가
- UI에서 소속 교회 체크 및 권한 없는 경우 에러 메시지 표시
- Cloud Functions에서 신고 3개 이상 시 자동 숨김 처리

**주요 파일**:
- `lib/features/community/presentation/screens/post_detail_screen.dart` - 비표시 UI
- `firestore.rules` - Admin 권한 규칙
- `functions/src/index.ts` - 자동 숨김 로직

---

## 외부 의존성

### 핵심 의존성

| 패키지 | 목적 |
|---------|---------|
| `flutter_riverpod` | 상태 관리 |
| `go_router` | 네비게이션 |
| `freezed` | 불변 데이터 클래스 |
| `dartz` | 함수형 프로그래밍 (Either) |

### Firebase 의존성

| 패키지 | 목적 |
|---------|---------|
| `firebase_core` | Firebase 초기화 |
| `firebase_auth` | 인증 |
| `cloud_firestore` | 데이터베이스 |
| `firebase_storage` | 파일 저장소 |
| `firebase_messaging` | 푸시 알림 |

**푸시 알림 구현**:
- `lib/core/data/services/push_notification_service.dart` - FCM 푸시 알림 서비스
- 알림 탭 시 게시글 상세 화면으로 자동 네비게이션
- 사용자 FCM 토큰 관리

**Cloud Functions 구현**:
- `functions/src/index.ts` - Firebase Cloud Functions
  - 신고 알림 전송: `reports` 문서 생성 시 Slack으로 알림 전송
  - 환경 변수: `functions/.env` 파일에서 dotenv로 로드 (로컬 개발)
  - 배포 시: Firebase Console 환경 변수 또는 Secret Manager 사용

### UI 의존성

| 패키지 | 목적 |
|---------|---------|
| `cached_network_image` | 이미지 캐싱 |
| `image_picker` | 이미지 선택 |
| `flutter_svg` | SVG 지원 |

**접근성 기능**:
- 글씨 크기 설정: `MediaQuery.textScaler`를 통해 앱 전체 텍스트 크기 조절 지원
  - `font_scale_provider.dart` - 글씨 크기 배율 관리 (0.85 ~ 1.4)
  - `main.dart` - 전체 앱에 textScaler 적용
  - `my_page_screen.dart` - 마이페이지에서 슬라이더로 글씨 크기 설정
  - SharedPreferences로 설정 영속화

**다국어 지원 (Internationalization)**:
- 지원 언어: 7개 언어 (일본어, 영어, 한국어, 중국어, 베트남어, 스페인어, 포르투갈어)
- 번역 파일 위치: `assets/l10n/app_{languageCode}.json`
- 구현 방식:
  - `LocalizationService`: JSON 파일 기반 번역 데이터 로드 및 캐싱
  - `AppLocalizations`: 타입 안전한 번역 키 접근을 위한 클래스
  - `AppLocalizationsDelegate`: Flutter의 `LocalizationsDelegate` 구현
  - `localeProvider`: Riverpod을 통한 로케일 상태 관리
  - `appLocalizationsProvider`: 비동기 번역 데이터 로드 (FutureProvider)
  - `appLocalizationsSyncProvider`: 동기 번역 데이터 접근 (캐시된 데이터 사용)
- 주요 파일:
  - `lib/core/data/services/localization_service.dart` - 번역 데이터 로드 서비스
  - `lib/core/utils/app_localizations.dart` - 번역 키 접근 유틸리티 (1,241줄)
  - `lib/shared/providers/locale_provider.dart` - 로케일 상태 관리
  - `lib/features/profile/presentation/screens/language_settings_screen.dart` - 언어 설정 화면
- 번역 완료 상태:
  - ✅ 일본어 (기본 언어) - 완료
  - ✅ 한국어 - 완료
  - ✅ 영어 - 완료 (일본어 텍스트 제거 완료)
  - ✅ 중국어 - 완료 (일본어 텍스트 제거 완료)
  - ✅ 베트남어 - 완료 (일본어 텍스트 제거 완료)
  - ✅ 스페인어 - 완료 (일본어 텍스트 제거 완료)
  - ✅ 포르투갈어 - 완료 (일본어 텍스트 제거 완료)
- 사용 예시:
  ```dart
  // 비동기 방식 (권장)
  final l10nAsync = ref.watch(appLocalizationsProvider);
  return l10nAsync.when(
    data: (l10n) => Text(l10n.common.ok),
    loading: () => CircularProgressIndicator(),
    error: (e, st) => Text('Error'),
  );

  // 동기 방식 (캐시된 데이터 사용)
  final l10n = ref.read(appLocalizationsSyncProvider);
  Text(l10n.parish.search);
  Text(l10n.mass.prayer.title);
  ```

---

## 데이터베이스 스키마 (Firestore)

### 컬렉션

```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── displayName: string
│       ├── photoUrl: string?
│       ├── parishId: string?
│       ├── isVerified: bool
│       └── createdAt: timestamp
│
├── posts/
│   └── {postId}/
│       ├── title: string
│       ├── content: string
│       ├── authorId: string
│       ├── authorName: string
│       ├── parishId: string?
│       ├── category: string
│       ├── isOfficial: bool
│       ├── isPinned: bool
│       ├── imageUrls: array<string>
│       ├── status: string ("published" | "hidden" | "reported")
│       ├── likeCount: number
│       ├── commentCount: number
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── comments/
│   └── {commentId}/
│       ├── postId: string
│       ├── authorId: string
│       ├── content: string
│       ├── parentCommentId: string?
│       └── createdAt: timestamp
│
├── reports/
│   └── {reportId}/
│       ├── targetType: string ("post" | "comment" | "user")
│       ├── targetId: string
│       ├── reason: string
│       ├── reporterId: string
│       └── createdAt: timestamp
│
├── parishes/
│   └── {parishId}/
│       ├── name: string
│       ├── address: string
│       ├── prefecture: string
│       ├── isCathedral: bool
│       ├── massSchedule: map
│       └── location: geopoint
│
└── notifications/
    └── {notificationId}/
        ├── userId: string
        ├── type: string
        ├── postId: string?
        ├── isRead: bool
        └── createdAt: timestamp
```

---

## 라우팅

선언적 네비게이션을 위해 **GoRouter** 사용.

**설정**: `lib/config/router.dart`

**라우트 구조**:
```
/                           # 홈
/onboarding                 # 온보딩 플로우
  /language                 # 언어 선택
  /location                 # 위치 권한
/auth
  /sign-in                  # 로그인
  /sign-up                  # 회원가입
/community
  /                         # 커뮤니티 홈
  /posts/:id                # 게시글 상세
  /posts/create             # 게시글 작성
  /posts/:id/edit           # 게시글 수정
/parish
  /                         # 성당 목록
  /:id                      # 성당 상세
/profile
  /                         # 마이페이지
  /edit                     # 프로필 수정
  /settings/language        # 언어 설정
```

---

## 로깅

### 중앙화된 로깅 서비스

앱 전체에서 일관된 로깅을 위해 **AppLogger** 서비스를 사용합니다.

**위치**: `lib/core/services/logger_service.dart`

**사용법**:
```dart
import '../../../core/services/logger_service.dart';

// 기능별 로그
AppLogger.auth('사용자 로그인 성공');
AppLogger.community('게시글 생성 완료');
AppLogger.notification('알림 전송 완료');
AppLogger.parish('성당 정보 로드 완료');
AppLogger.profile('프로필 업데이트 완료');
AppLogger.image('이미지 업로드 완료');

// 레벨별 로그
AppLogger.debug('디버깅 정보');
AppLogger.info('정보 메시지');
AppLogger.warning('경고 메시지');
AppLogger.error('에러 메시지', error, stackTrace);
```

**특징**:
- Debug 모드에서만 로그 출력 (`kDebugMode` 사용)
- 기능별 태그로 로그 구분
- 프로덕션 빌드에서는 불필요한 로그 자동 제거

**적용 현황**:
- ✅ 주요 repository 파일들 (`auth_repository_impl.dart`, `firestore_post_repository.dart` 등)
- ✅ 주요 서비스 파일들 (`core/data/services/` 디렉토리: `image_upload_service.dart`, `geocoding_service.dart`, `liturgical_reading_service.dart`, `push_notification_service.dart`, `parish_service.dart`, `saint_feast_day_service.dart`, `prayer_service.dart` 등)
- ✅ 주요 화면 파일들 (`home_screen.dart` 등)
- ✅ Provider 파일들 (`auth_provider.dart` 등)

**금지 사항**:
- ❌ `print()` 또는 `debugPrint()` 직접 사용 금지
- ✅ 모든 로깅은 `AppLogger`를 통해 수행

---

## 모범 사례

### 권장 사항

1. **엔티티와 모델에 Freezed 사용**
2. **Repository에서 Either<Failure, T> 반환** - 모든 Repository 구현 완료
3. **의존성 주입을 위해 providers 사용**
4. **화면을 UI 구성에 집중**
5. **재사용 가능한 위젯 추출** - 큰 화면 파일(500줄 이상)은 위젯으로 분할
   - 예: `post_detail_screen.dart` (959줄 → 304줄), `parish_list_screen.dart` (739줄 → 336줄)
6. **실시간 데이터에 StreamProvider 사용**
7. **모든 로깅은 AppLogger 사용** - 대부분의 주요 파일 적용 완료 (일부 진행 중)
8. **중복 로직은 Extension 메서드로 추출** - 예: `PostListExtension`의 정렬 로직

### 금지 사항

1. **데이터 레이어에서 원시 Exception 던지기 금지** - 주요 서비스 및 repository 표준화 완료 (transaction 내부, presentation layer는 예외)
2. **프레젠테이션 레이어에 비즈니스 로직 넣지 않기**
3. **화면에서 Firebase 직접 접근 금지**
4. **God 클래스 생성 금지 (파일 > 500줄)** - `post_detail_screen.dart` (959줄 → 304줄), `parish_list_screen.dart` (739줄 → 336줄) 분할 완료
5. **코드 중복 금지 - 유틸리티/Extension으로 추출** - 게시글 정렬 로직 추출 완료
6. **`print()` 또는 `debugPrint()` 직접 사용 금지 - AppLogger 사용** - 주요 파일 적용 완료

---

## 새 기능 추가

### 체크리스트

1. 기능 디렉토리 구조 생성:
   ```
   lib/features/{new_feature}/
   ├── data/
   │   ├── models/
   │   ├── providers/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   └── repositories/
   └── presentation/
       ├── screens/        
       └── widgets/        # 재사용 가능한 위젯
   ```

2. Freezed를 사용하여 도메인 엔티티 정의
3. 도메인 레이어에 repository 인터페이스 생성
4. 데이터 레이어에 repository 구현
5. 의존성 주입을 위한 providers 생성
   - Repository Provider는 `data/providers/`에 위치
   - UI state Provider는 `presentation/providers/`에 위치
6. ConsumerWidget을 사용하여 화면 구축
7. GoRouter 설정에 라우트 추가
8. repository 및 providers에 대한 테스트 작성

---

## 데이터 관리

### 성당 데이터 (`assets/data/parishes/`)

성당 정보는 JSON 파일로 관리되며, 각 교구별로 파일이 분리되어 있습니다:
- `tokyo.json`, `yokohama.json`, `osaka.json`, `kyoto.json`, `nagasaki.json`, `nagoya.json`, `fukuoka.json`, `hiroshima.json`, `saitama.json`, `sendai.json`, `niigata.json`, `oita.json`, `kagoshima.json`, `sapporo.json`, `naha.json`

**데이터 구조**:
```json
{
  "diocese": "tokyo",
  "parishes": [
    {
      "name": "성당명",
      "address": "상세 주소 (번지수 포함)",
      "prefecture": "도도부현",
      "latitude": 35.xxx,
      "longitude": 139.xxx,
      "massTime": "미사 시간 문자열",
      "massTimes": { ... },
      "foreignMassTimes": { ... }
    }
  ]
}
```

**주소 업데이트**:
- 2025-12-15: 799개 성당 중 798개 성당에 상세 주소 추가 (99.9% 완료율)
- `scripts/batch_update_addresses.py`: 주소 업데이트 자동화 스크립트
- 웹 검색을 통한 주소 수집 및 검증
- 파일별 완료율: 14개 파일 100% 완료, sapporo.json 98.4% (61/62)
- 미완료: カトリック奥尻教会 (번지수 정보 확인 불가)

**좌표 데이터 추가**:
- 2025-12-15: 모든 성당에 latitude/longitude 좌표 추가
- Google Maps Geocoding API를 사용하여 주소를 좌표로 변환
- `scripts/add_coordinates.py`: 좌표 추가 자동화 스크립트
- 거리순 정렬 기능 활성화

**외국어 미사 데이터 수정**:
- 2025-12-15: `massTime` 텍스트와 `foreignMassTimes` 불일치 수정
- 末吉町教会 등 13개 성당의 데이터 수정 (중국어, 영어, 한국어, 스페인어, 포르투갈어 등)
- `scripts/fix_foreign_mass_times.py`: 불일치 분석 스크립트
- `scripts/auto_fix_foreign_mass.py`: 자동 수정 스크립트

**osaka.json 대규모 데이터 추가**:
- 2025-12-XX: 기존 1개 교회에서 **106개 교회**로 대폭 확장
- 웹사이트 데이터 기반 추가: https://ostk.catholic.jp/parish_mass/
- 지역별 분포: 大阪府 36개, 兵庫県 33개, 和歌山県 11개, 香川県 9개, 愛媛県 8개, 徳島県 4개, 高知県 5개
- 모든 교회의 `massTime`을 `massTimes`와 `foreignMassTimes`로 정확히 분리
- 특수 조건 처리 (第X日曜, 前晩, 계절별 시간 등) 완료
- `scripts/update_osaka_parishes.py`: 교회 데이터 추가 자동화 스크립트
- 참고: 위도/경도는 임시 값(0.0)으로 설정되어 geocoding 업데이트 필요
