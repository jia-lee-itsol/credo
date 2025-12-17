# Credo TODO 추적

이 문서는 코드베이스에서 발견된 모든 TODO 주석과 보류 중인 기능 구현을 추적합니다.

**마지막 업데이트**: 2025-12-16 (구글 로그인 문제 추가)
**전체 코드베이스**: 약 27,000줄의 Dart 코드, 135개 파일

---

## 코드 내 TODO 주석

### 프로필 기능
| 위치 | 설명 | 우선순위 | 상태 |
|----------|-------------|----------|------|
| `lib/features/profile/presentation/screens/qr_scanner_screen.dart:108` | 메신저 기능 구현 시 여기서 사용자 추가 처리 | 낮음 | - |
| `lib/features/profile/presentation/screens/qr_scanner_screen.dart:147` | 메신저 기능 구현 시 "友達追加" 버튼 추가 | 낮음 | - |
| `lib/features/profile/presentation/screens/language_settings_screen.dart:83` | 언어 변경 로직 구현 | 중간 | ✅ 완료 |

### 미사 기능
| 위치 | 설명 | 우선순위 | 상태 |
|----------|-------------|----------|------|
| `lib/features/mass/presentation/screens/daily_mass_screen.dart:318` | 실제 라이선스 상태를 확인하는 로직으로 교체 필요 | 중간 | ✅ 완료 |

### 공유 위젯
| 위치 | 설명 | 우선순위 | 상태 |
|----------|-------------|----------|------|
| `lib/shared/widgets/expandable_content_card.dart:99` | 추후 성경 읽기 화면으로 연결 | 낮음 | - |

---

## 보류 중인 기능

### 높은 우선순위

#### 1. 구글 로그인 문제 해결 ✅ 완료 (2025-12-16)
- **문제**: 구글 로그인이 작동하지 않음 (`ApiException: 10` 발생)
- **원인**: `google-services.json`에 Android OAuth Client ID (`client_type: 1`) 누락
- **해결 방법**:
  1. Firebase Console에서 SHA-1 인증서 추가: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`
  2. Firebase가 자동으로 Android OAuth Client 생성
  3. `google-services.json` 다시 다운로드 및 적용
- **최종 설정**:
  - Android OAuth Client ID: `182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com`
  - Package name: `com.itz.credo`
  - SHA-1: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`
- **결과**: ✅ Google Sign-In 정상 작동 확인

#### 2. 푸시 알림 네비게이션 ✅ 완료
- **문제**: 알림 탭 시 게시글 상세 화면으로 이동하지 않음
- **파일**: `push_notification_service.dart:124`
- **완료된 작업**:
  - `PushNotificationService`에 `setRouter()` 메서드 추가
  - `main.dart`에서 router 설정
  - `_handleMessageOpenedApp`에서 `postId`와 `parishId`를 받아 `AppRoutes.postDetailPath`로 네비게이션 구현

#### 3. 공지/커뮤니티 목록에서 네비게이션 ✅ 완료
- **문제**: 목록 항목이 상세 화면으로 이동하지 않음
- **파일**: `notice_list_page.dart:45`, `community_list_page.dart:50`
- **완료된 작업**: 
  - `GoRouter` import 추가
  - `ListTile`의 `onTap`에 `context.push(AppRoutes.postDetailPath(...))` 구현

#### 4. 위치 기반 거리 계산 기능 ✅ 완료
- **문제**: 교회 목록에서 거리가 하드코딩되어 있음 (`'1.2km'`)
- **파일**: `parish_card.dart`, `parish_list_screen.dart`
- **완료된 작업**:
  1. ✅ `location_provider.dart` 생성 - 사용자 위치 및 교회 좌표/거리 계산 Provider
  2. ✅ `geocoding_service.dart` 생성 - Google Maps Geocoding API를 사용한 주소-좌표 변환
  3. ✅ `parish_card.dart`에서 실제 거리 계산 및 표시
  4. ✅ `parish_list_screen.dart`에서 거리순 정렬 기능 구현
  5. ✅ 위치 권한 요청 기능 구현 (화면에서 명시적으로 권한 요청)
  6. ✅ Google Maps API 키를 환경 변수로 분리 (`.env` 파일, `flutter_dotenv` 사용)
  7. ✅ 거리순 필터링 버그 수정 - `FutureProvider` 접근 방식 수정 (`ref.read` → `ref.watch`), 기본값을 `false`로 변경, 위치 정보 가져오기 로직 개선

### 중간 우선순위

#### 5. 신고 기능 ✅ 완료
- **문제**: 게시글/댓글 신고 기능이 없음
- **완료된 작업**:
  1. ✅ 신고 모델 및 리포지토리 생성 (`Report`, `ReportRepository`)
  2. ✅ 공통 신고 다이얼로그 위젯 생성 (`ReportDialog`)
  3. ✅ 게시글/댓글에 신고 버튼 추가
  4. ✅ Cloud Functions onCreate 트리거 추가 (Slack 알림 전송)
  5. ✅ Firestore Rules에 reports 컬렉션 규칙 추가
  6. ✅ 중복 신고 방지 로직 구현 (5분 내 동일 대상 신고 방지)
  7. ✅ Slack webhook URL을 dotenv로 처리 (`functions/.env` 파일, dotenv 패키지 추가)
  8. ✅ 게시글 자동 숨김 기능: 신고 3개 이상 시 자동으로 `status`를 "hidden"으로 변경 (Cloud Functions에서 처리)

#### 6. 댓글 수 표시 ✅ 완료
- **문제**: 게시글 목록에 하드코딩된 `commentCount: 0` 표시
- **파일**: `post_list_screen.dart:47`
- **완료된 작업**:
  1. ✅ Post 모델에 `commentCount` 필드 추가
  2. ✅ 댓글 생성 시 Firestore transaction으로 `commentCount` 자동 증가
  3. ✅ `post_list_screen.dart`에서 실제 `commentCount` 사용

#### 7. 게시글 수 및 새 게시글 표시기 ✅ 완료
- **문제**: 커뮤니티 홈에 하드코딩된 값 표시
- **파일**: `community_home_screen.dart:70-71`
- **완료된 작업**:
  1. ✅ `postCountProvider` 생성 - 성당별 게시글 수 계산
  2. ✅ `hasNewPostsProvider` 생성 - 새 게시글 여부 확인
  3. ✅ SharedPreferences를 사용한 마지막 읽은 타임스탬프 추적
  4. ✅ `community_home_screen.dart`에 실제 데이터 연동

#### 8. Admin 게시글 비표시 기능 ✅ 완료
- **문제**: Admin이 게시글을 비표시할 수 있는 기능이 없음
- **완료된 작업**:
  1. ✅ `UserEntity.isAdmin` getter 추가
  2. ✅ Firestore Rules에 `isAdmin()` 및 `isAdminOfPostParish()` helper function 추가
  3. ✅ Posts update 규칙: 관리자는 자신이 소속된 교회의 게시글만 `status` 수정 가능
  4. ✅ UI에서 소속 교회 체크 및 비표시/표시 옵션 표시
  5. ✅ 권한 없는 경우 명확한 에러 메시지 표시

#### 9. 글씨 크기 설정 기능 ✅ 완료
- **문제**: 노인 사용자가 글씨를 크게 볼 수 있는 기능이 없음
- **완료된 작업**:
  1. ✅ `font_scale_provider.dart` 생성 - 글씨 크기 배율 관리 (0.85 ~ 1.4)
  2. ✅ `main.dart`에서 `MediaQuery.textScaler`를 통해 전체 앱 텍스트 크기 조절
  3. ✅ 마이페이지에 글씨 크기 설정 슬라이더 추가 (`my_page_screen.dart`)
  4. ✅ SharedPreferences를 사용하여 설정 영속화
  5. ✅ 실시간 미리보기 기능 추가 ("サンプルテキスト")

#### 10. 언어 설정 구현 ✅ 완료
- **문제**: 언어 변경 로직이 구현되지 않음
- **파일**: `language_settings_screen.dart:83`
- **완료된 작업**:
  1. ✅ 로케일 영속성 구현 (SharedPreferences) - 이미 `locale_provider.dart`에 구현되어 있음
  2. ✅ 선택 시 앱 로케일 업데이트 - `setLocaleByLanguageCode` 메서드 사용
  3. ✅ 날짜 포맷 로케일 동적 업데이트 - `locale_provider.dart`에 `initializeDateFormatting` 추가
  4. ✅ 번역 데이터 자동 재로드 - `appLocalizationsProvider` invalidate 추가

#### 11. 검색 기능 구현 ✅ 완료 (2025-12-16)
- **문제**: 게시글 및 성당 검색 기능이 제한적이거나 미구현
- **완료된 작업**:
  1. ✅ 게시글 검색 기능 구현
     - `PostRepository`에 `searchPosts` 메서드 추가
     - `FirestorePostRepository`에 검색 로직 구현 (Firestore 쿼리 + 클라이언트 사이드 필터링)
     - 제목, 내용, 작성자 이름으로 검색 가능
     - `parishId`, `category`, `type` 필터링 지원
  2. ✅ 게시글 검색 Provider 추가
     - `searchPostsProvider` 생성
     - `SearchPostsParams` 클래스로 검색 파라미터 관리
  3. ✅ 성당 검색 개선
     - 이름, 주소, 도도부현, 교구, 지역(시/구)로 검색 확장
     - 검색 결과 정렬 개선 (이름 매칭 우선, 주소 매칭 다음)
     - `ParishService.searchParishes` 메서드 개선
  4. ✅ 검색 UI 개선 (검색 히스토리 및 자동완성)
     - `SearchHistoryService` 생성 (SharedPreferences 기반)
     - 게시글 및 성당 검색 히스토리 저장/조회 기능
     - 검색 히스토리 Provider 추가 (`postSearchHistoryProvider`, `parishSearchHistoryProvider`)
     - `PostListSearchBar` 개선: 히스토리 표시, 자동완성 (게시글 제목 기반)
     - `ParishSearchBar` 개선: 히스토리 표시, 자동완성 (성당 이름 기반)
     - 검색어 입력 시 실시간 자동완성 제안 표시
     - 히스토리 항목 개별 삭제 기능

### 낮은 우선순위

#### 7. 메신저 / 친구 기능
- **문제**: QR 스캐너 친구 추가가 구현되지 않음
- **파일**: `qr_scanner_screen.dart:108-109`
- **필요한 작업**:
  1. 친구/연결 데이터 모델 설계
  2. 친구 요청 시스템 생성
  3. 메신저 기능 구현

---

## 리팩토링 작업

### 중요
- [x] 중앙화된 로깅 서비스 생성 ✅
- [x] 중복 게시글 정렬 로직 추출 ✅
- [x] 커뮤니티 repository의 에러 처리 표준화 ✅

### 높음
- [x] `edit_profile_screen.dart` 분할 (1,106줄 → 457줄) ✅
  - 8개 위젯으로 분리: 기존 5개 + 새로 분리된 3개 (`FeastDaySearchSheet`, `UserSearchSheet`, `ParishSearchSheet`)
- [x] `post_detail_screen.dart` 분할 (959줄 → 304줄) ✅
- [x] `parish_list_screen.dart` 분할 (739줄 → 336줄) ✅
- [x] `post_list_screen.dart` 분할 (543줄 → 332줄) ✅
  - 3개 위젯으로 분리: `PostCard`, `PostListFilterBar`, `PostListSearchBar`
- [x] `post_create_screen.dart` 분할 (516줄 → 244줄) + 로깅 교체 ✅
  - 16개 `debugPrint`를 `AppLogger.community()`로 교체 완료
  - 4개 위젯으로 분리: `PostFormFields`, `PostImagePicker`, `PostOfficialSettings`, `PostFormSubmitButton`
- [x] `post_edit_screen.dart` 분할 (556줄 → 252줄) ✅
  - `post_create_screen.dart`와 공통 위젯 재사용
- [x] 커뮤니티 모델을 Freezed로 마이그레이션 ✅
  - 대상: `post.dart`, `comment.dart`, `notification.dart`, `app_user.dart`
  - 완료: 모든 모델을 Freezed로 변환, `toFirestore()` 메서드 추가, DateTime 변환기 구현

### 중간
- [x] `push_notification_service.dart`의 debugPrint를 AppLogger로 교체 (18개) ✅
- [x] `parish_service.dart`의 debugPrint와 throw Exception을 AppLogger/Failure로 교체 ✅
- [x] `saint_feast_day_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `prayer_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `image_upload_service.dart`의 throw Exception을 Failure로 교체 ✅
- [x] `app_user.dart`의 throw Exception을 ValidationFailure로 교체 ✅
- [ ] 단위 테스트 커버리지 추가
  - 우선순위: Repository 구현, State notifiers, 유틸리티 함수
  - 예상 작업량: 8-12시간
- [x] Provider 구성 표준화 ✅
  - 현재: `features/parish/presentation/providers/`, `features/community/data/providers/`
  - 권장: `features/{feature}/data/providers/` (Repository), `features/{feature}/presentation/providers/` (UI state)
  - 완료: Repository Provider는 `data/providers/`에 유지, UI state Provider는 `presentation/providers/`로 이동, `community_presentation_providers.dart` 생성
- [x] 공유 서비스를 core로 이동 ✅
  - `image_upload_service.dart`를 `core/data/services/`로 이동
  - 완료: 파일 이동 및 import 경로 업데이트 완료
- [x] 남은 print 문 AppLogger로 교체 ✅
  - 확인: `post_create_screen.dart`에는 이미 모든 print 문이 AppLogger로 교체되어 있음

---

## 기술 부채

| 카테고리 | 개수 | 영향 | 상태 |
|----------|-------|--------|------|
| 원시 Exception 던지기 | 6개 (정상) | 높음 | ✅ 주요 서비스 완료 - transaction 내부, presentation layer는 정상 |
| 디버그 print 문 | 0개 | 중간 | ✅ 완료 - 모든 print 문이 AppLogger로 교체됨 |
| 큰 파일 (>500줄) | 0개 | 중간 | ✅ 완료 - 모든 큰 파일 분할 완료 |
| 누락된 테스트 | 전체 | 높음 | - |
| 중복 코드 블록 | 0 | 중간 | ✅ 정렬 로직 Extension 추출 완료 |
| 컴파일 에러 | 0개 | 높음 | ✅ 완료 - 모든 심각한 에러(severity 1) 수정 완료 |
| Deprecated API 사용 | 0개 | 중간 | ✅ 완료 - RadioListTile의 deprecated onChanged를 RadioGroup으로 마이그레이션 완료 |
| 사용하지 않는 코드 | 0개 | 낮음 | ✅ 완료 - 사용하지 않는 변수, import, 함수 제거 완료 |

---

## 완료된 TODO

| 날짜 | 설명 | PR/커밋 |
|------|-------------|-----------|
| 2025-12-12 | 중앙화된 로깅 서비스 구현 및 주요 파일 적용 | d8f1c84d |
| 2025-12-12 | `AppLogger` 서비스 생성 및 `auth_repository_impl.dart` 로깅 교체 | d8f1c84d |
| 2025-12-12 | `firestore_post_repository.dart` 로깅 교체 | d8f1c84d |
| 2025-12-12 | `firestore_notification_repository.dart`, `firestore_user_repository.dart` 로깅 교체 | d8f1c84d |
| 2025-12-12 | `image_upload_service.dart`, `home_screen.dart` 로깅 교체 | d8f1c84d |
| 2025-12-12 | 중복 정렬 로직 추출 - `PostListExtension` 생성 및 적용 | d8f1c84d |
| 2025-12-12 | 푸시 알림 네비게이션 구현 | d8f1c84d |
| 2025-12-12 | 공지/커뮤니티 목록 네비게이션 구현 | d8f1c84d |
| 2025-12-12 | 커뮤니티 전용 실패 타입 생성 및 에러 처리 표준화 | d8f1c84d |
| 2025-12-12 | 모든 커뮤니티 repository를 Either 패턴으로 리팩토링 | d8f1c84d |
| 2025-12-12 | 댓글 수 표시 기능 구현 - Post 모델에 commentCount 추가 및 댓글 생성 시 자동 업데이트 | d8f1c84d |
| 2025-12-12 | 게시글 수 및 새 게시글 표시기 구현 - postCountProvider, hasNewPostsProvider 생성 | d8f1c84d |
| 2025-12-12 | Firestore 복합 인덱스 관련 주석 업데이트 | d8f1c84d |
| 2025-12-12 | `liturgical_reading_service.dart` 모든 print 문을 AppLogger로 변경 (44개) | d8f1c84d |
| 2025-12-12 | `auth_provider.dart` 모든 print 문을 AppLogger로 변경 (3개) | d8f1c84d |
| 2025-12-12 | 목업 데이터 스크립트 삭제 - `scripts/create_sample_posts.dart`, `scripts/README_SAMPLE_DATA.md` | d8f1c84d |
| 2025-12-12 | Firestore 복합 인덱스 설정 완료 - `watchCommunityPosts`와 `watchAllPosts`에서 parishId 필터링 활성화, `firestore.indexes.json`에 필요한 인덱스 추가 | d8f1c84d |
| 2025-12-12 | `post_detail_screen.dart` 분할 완료 (959줄 → 302줄) - 위젯을 8개 파일로 분리: PostImageViewer, PostDetailHeader, PostDetailAuthorInfo, PostDetailImages, PostDetailLikeButton, PostDetailCommentsSection, PostDetailCommentInput, PostCommentSubmitter | d8f1c84d |
| 2025-12-12 | `pages` 디렉토리를 `screens`로 통합 - `post_edit_page.dart`, `notice_list_page.dart`, `community_list_page.dart`를 `screens` 디렉토리로 이동 및 클래스명 변경 (Page → Screen) | d8f1c84d |
| 2025-12-12 | `push_notification_service.dart`의 debugPrint를 AppLogger로 교체 (18개) | d8f1c84d |
| 2025-12-12 | `parish_service.dart`의 debugPrint와 throw Exception을 AppLogger/Failure로 교체 | d8f1c84d |
| 2025-12-12 | `saint_feast_day_service.dart`의 throw Exception을 CacheFailure로 교체 | d8f1c84d |
| 2025-12-12 | `prayer_service.dart`의 throw Exception을 CacheFailure로 교체 | d8f1c84d |
| 2025-12-12 | `image_upload_service.dart`의 throw Exception을 ValidationFailure/FirebaseFailure로 교체 | d8f1c84d |
| 2025-12-12 | `app_user.dart`의 throw Exception을 ValidationFailure로 교체 | d8f1c84d |
| 2025-12-12 | `post_list_screen.dart` 분할 완료 (543줄 → 332줄) - 위젯을 3개 파일로 분리: PostCard, PostListFilterBar, PostListSearchBar | d8f1c84d |
| 2025-12-12 | `post_create_screen.dart` 분할 완료 (516줄 → 244줄) - 16개 debugPrint를 AppLogger로 교체, 4개 위젯으로 분리: PostFormFields, PostImagePicker, PostOfficialSettings, PostFormSubmitButton | d8f1c84d |
| 2025-12-12 | `post_edit_screen.dart` 분할 완료 (556줄 → 252줄) - post_create_screen.dart와 공통 위젯 재사용 | d8f1c84d |
| 2025-12-12 | 커뮤니티 모델을 Freezed로 마이그레이션 완료 - `post.dart`, `comment.dart`, `notification.dart`, `app_user.dart`를 Freezed로 변환, `toFirestore()` 메서드 추가, DateTime 변환기 구현 | d8f1c84d |
| 2025-12-12 | 위치 기반 거리 계산 기능 구현 - `location_provider.dart`, `geocoding_service.dart` 생성, `parish_card.dart`에서 실제 거리 표시, `parish_list_screen.dart`에서 거리순 정렬 및 위치 권한 요청 기능 추가 | d8f1c84d |
| 2025-12-12 | Google Maps API 키를 환경 변수로 분리 - `flutter_dotenv` 추가, `.env` 파일 생성, `geocoding_service.dart`에서 환경 변수 사용 | d8f1c84d |
| 2025-12-12 | 교회 카드 UI 개선 - 오버플로우 문제 해결 (가로 스크롤 가능), JP 뱃지 제거 (기본 언어이므로), 지도 버튼을 Google Maps로 연결 (주소 검색) | d8f1c84d |
| 2025-12-15 | Provider 구성 표준화 - Repository Provider는 `data/providers/`에 유지, UI state Provider는 `presentation/providers/`로 이동, `community_presentation_providers.dart` 생성 | cfc4ab29 |
| 2025-12-15 | 공유 서비스를 core로 이동 - `image_upload_service.dart`를 `core/data/services/`로 이동, import 경로 업데이트 | cfc4ab29 |
| 2025-12-15 | Slack webhook URL을 dotenv로 처리 - `functions/.env` 파일 생성, dotenv 패키지 추가, `functions/src/index.ts`에서 dotenv 사용 | cfc4ab29 |
| 2025-12-15 | Admin 게시글 비표시 버그 수정 - Firestore Rules에 `commentCount` 업데이트 권한 추가, `updatePost()` 필드 비교 로직 개선 (리스트 비교, 기본값 처리) | cfc4ab29 |
| 2025-12-15 | 댓글 기능 버그 수정 - `PostCommentSubmitter`의 `Ref` 타입을 `WidgetRef`로 변경, `currentAppUserProvider.future` 사용, Firestore 트랜잭션 순서 수정 (읽기 → 쓰기) | cfc4ab29 |
| 2025-12-15 | 게시글 숨기기 후 목록으로 돌아가기 - `_hidePost()` 성공 시 `Navigator.pop()` 추가 | cfc4ab29 |
| 2025-12-15 | 글씨 크기 설정 기능 추가 - `font_scale_provider.dart` 생성, `main.dart`에서 `MediaQuery.textScaler` 적용, 마이페이지에 설정 UI 추가 | cfc4ab29 |
| 2025-12-15 | 거리순 필터링 버그 수정 - `parish_list_screen.dart`에서 `FutureProvider` 접근 방식 수정 (`ref.read` → `ref.watch`), 기본값을 `false`로 변경, 위치 정보 가져오기 로직 개선 | cfc4ab29 |
| 2025-12-15 | `edit_profile_screen.dart` 추가 분할 완료 (1,106줄 → 457줄, 649줄 감소, 59% 감소) - 검색 시트 위젯 3개를 별도 파일로 분리: `FeastDaySearchSheet`, `UserSearchSheet`, `ParishSearchSheet` | cfc4ab29 |
| 2025-12-15 | 성당 주소 업데이트 작업 완료 - 799개 성당 중 798개 성당에 상세 주소 추가 (99.9% 완료율), 웹 검색을 통한 주소 수집, `scripts/batch_update_addresses.py` 스크립트 생성, 파일별 완료율: 14개 파일 100% 완료, sapporo.json 98.4% (61/62), 미완료: カトリック奥尻教会 (번지수 정보 없음) | cfc4ab29 |
| 2025-12-15 | 미사 시간 데이터 정리 작업 완료 - massTime 문자열 기반으로 massTimes/foreignMassTimes 재생성, 중복 항목 6개 해결, 순회 교회 96개 성당 문의 안내로 통일, 빈 데이터 항목 17개 처리 (kyoto.json 9개, nagoya.json 1개, osaka.json 1개, sapporo.json 4개, yokohama.json 2개), `scripts/parse_mass_times.py` 개선, 홈페이지 확인이 필요한 교회들 안내 문구 추가, 백업 파일 28개 삭제 | cfc4ab29 |
| 2025-01-XX | fukuoka.json 데이터 구조 개선 및 검증 완료 - 福岡カテドラル에 필수 `diocese` 및 `deanery` 필드 추가 (앱 연결 문제 해결), 모든 교구의 `massTimes`와 `foreignMassTimes` 분리 확인, 외국어 미사 시간 `note` 필드 표준화 ("第○日" → "第○日曜"), 누락된 미사 시간 추가 (大楠教会, 水俣教会, 菊池教会 등), 大江教会 수요일/목요일 미사 시간 추가, JSON 형식 유효성 검증 완료, `assets/data/README.md` 업데이트 | - |
| 2025-12-15 | 전체 코드베이스 에러 수정 완료 - RadioListTile의 deprecated onChanged를 RadioGroup으로 마이그레이션 (report_dialog.dart), l10n 변수 누락 문제 수정 (20+ 파일), const 키워드 오류 수정 (런타임 값 사용 시), 사용하지 않는 변수/import 제거, 중복 import 제거, 사용하지 않는 함수 제거 (_dateTimeToJson, _dateTimeFromJson), 모든 심각한 에러(severity 1) 수정 완료 | cfc4ab29 |
| 2025-12-15 | 언어 설정 구현 완료 - `locale_provider.dart`에 날짜 포맷 로케일 동적 업데이트 추가 (`initializeDateFormatting`), `language_settings_screen.dart`에서 `appLocalizationsProvider` invalidate 추가하여 번역 데이터 자동 재로드 | cfc4ab29 |
| 2025-12-15 | 에러 수정 완료 - `daily_mass_screen.dart`에서 l10n 파라미터 누락 수정 (`_buildCommentInput` 메서드에 `AppLocalizations l10n` 파라미터 추가), `parish_detail_screen.dart`에서 l10n 파라미터 누락 수정 및 사용하지 않는 메서드 제거 (`_buildMassTimeSection` 메서드에 `AppLocalizations l10n` 파라미터 추가, `_launchMapByCoordinates` 메서드 제거) | cfc4ab29 |
| 2025-12-15 | 성경 텍스트 라이선스 상태 확인 기능 구현 - `bible_license_provider.dart` 생성 (Firestore의 `app_settings/bible_license` 문서에서 라이선스 상태 확인), `daily_mass_screen.dart`에서 하드코딩된 `isBibleTextLicensed`를 Provider로 교체, Firestore Rules에 `app_settings` 컬렉션 읽기 권한 추가 | cfc4ab29 |
| 2025-12-15 | 공지글 푸시 알림 기능 개선 - FCM 토큰 갱신 시 자동 Firestore 저장, `_currentUserId` 관리 추가 | cfc4ab29 |
| 2025-12-15 | 성당 좌표 데이터 추가 - Google Maps Geocoding API를 사용하여 모든 성당 JSON 파일에 latitude/longitude 좌표 추가, `scripts/add_coordinates.py` 생성 | cfc4ab29 |
| 2025-12-15 | 거리순 필터 Provider 버그 수정 - `parishDistanceProvider`에서 빌드 중 다른 Provider 수정 문제 해결 (`StateNotifierListenerError` 수정) | cfc4ab29 |
| 2025-12-15 | 거리순 필터칩 UI 개선 - `ParishFilterChip`에서 `isSelected` 상태에 따른 체크 아이콘 및 배경색 변경 | cfc4ab29 |
| 2025-12-15 | 외국어 미사 데이터 수정 - 末吉町教会 등 13개 성당의 `foreignMassTimes` 데이터를 `massTime` 텍스트 기반으로 수정, `scripts/fix_foreign_mass_times.py` 및 `scripts/auto_fix_foreign_mass.py` 생성 | cfc4ab29 |
| 2025-12-15 | 미사 시간 데이터 일관성 검증 및 수정 - kagoshima.json의 志布志教会, 阿久根教会 `massTimes` 데이터를 `massTime` 텍스트와 일치하도록 수정, kyoto.json의 上野教会 `massTimes`에 토요일 19:30 및 일요일 09:00, 10:30, 17:00 추가, `foreignMassTimes`에 타갈로그어 미사 추가 | bad05ad |
| 2025-12-16 | 성인 축일 데이터 업데이트 - ChatGPT API를 사용하여 전체 월별 누락된 성인 추가: 12,1,2월 95명, 3,4,5월 112명, 6,7,8월 82명, 9,10,11월 95명 추가 (총 384명), `scripts/check_and_fix_missing_saints.py` 스크립트 사용 | - |
| 2025-12-16 | 다국어 지원 완료 - 모든 언어 파일의 일본어 텍스트를 각 언어로 번역 완료: 영어 76개, 스페인어 289개, 포르투갈어 289개, 베트남어 289개, 중국어 번역 완료, 모든 언어 파일에서 일본어 문자(히라가나/가타카나) 제거 완료 | - |
| 2025-12-16 | Google 로그인 문제 해결 - ApiException: 10 (DEVELOPER_ERROR) 오류 해결, Firebase Console에서 SHA-1 인증서 추가 (61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A), Android OAuth Client ID 자동 생성 확인 (182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com), google-services.json 업데이트 (client_type: 1 추가), Google Sign-In 정상 작동 확인 | - |
| 2025-12-16 | 검색 기능 구현 - 게시글 검색 기능 구현 (PostRepository.searchPosts 메서드 추가, Firestore 쿼리 + 클라이언트 사이드 필터링), 성당 검색 개선 (이름, 주소, 도도부현, 교구, 지역 검색 확장, 검색 결과 정렬 개선), searchPostsProvider 추가, 검색 UI 개선 (검색 히스토리 서비스, 자동완성 기능, PostListSearchBar 및 ParishSearchBar 개선) | - |

---

## 다음 스프린트 권장 작업

### 우선순위 1: 높음 (즉시 진행)

1. **언어 설정 구현** ✅ 완료
   - 로케일 영속성 구현 (SharedPreferences)
   - 선택 시 앱 로케일 업데이트
   - 날짜 포맷 로케일 동적 업데이트
   - 번역 데이터 자동 재로드

2. **단위 테스트 커버리지 추가** (8-12시간)
   - 우선순위: Repository 구현, State notifiers, 유틸리티 함수
   - 점진적으로 추가 가능

### 우선순위 2: 중간

3. **Provider 구성 표준화** ✅ 완료
   - Repository Provider는 `data/providers/`에 유지
   - UI state Provider는 `presentation/providers/`로 이동
   - `community_presentation_providers.dart` 생성 및 모든 import 경로 업데이트

4. **공유 서비스를 core로 이동** ✅ 완료
   - `image_upload_service.dart`를 `core/data/services/`로 이동
   - import 경로 업데이트 완료

**총 예상 시간**: 11-17시간

대부분의 큰 화면 파일(500줄 이상)이 이미 분할되어 코드 가독성과 유지보수성이 크게 향상되었습니다.

---

## 이 문서 업데이트 방법

1. 코드에 새 TODO를 추가할 때 여기에 항목 추가
2. TODO를 완료하면 "완료된 TODO" 섹션으로 이동
3. 완료된 항목에 PR/커밋 참조 포함
4. 스프린트 계획 중 이 문서 검토

---

# Credo TODO 追跡 (日本語版)

このドキュメントは、コードベースで発見されたすべてのTODOコメントと保留中の機能実装を追跡します。

**最終更新**: 2025-12-16
**コードベース全体**: 約27,000行のDartコード、135ファイル

---

## コード内のTODOコメント

### プロフィール機能
| 位置 | 説明 | 優先度 | 状態 |
|----------|-------------|----------|------|
| `lib/features/profile/presentation/screens/qr_scanner_screen.dart:108` | メッセンジャー機能実装時にここでユーザー追加処理 | 低 | - |
| `lib/features/profile/presentation/screens/qr_scanner_screen.dart:147` | メッセンジャー機能実装時に「友達追加」ボタン追加 | 低 | - |
| `lib/features/profile/presentation/screens/language_settings_screen.dart:83` | 言語変更ロジック実装 | 中 | ✅ 完了 |

### ミサ機能
| 位置 | 説明 | 優先度 | 状態 |
|----------|-------------|----------|------|
| `lib/features/mass/presentation/screens/daily_mass_screen.dart:318` | 実際のライセンス状態を確認するロジックに置き換え必要 | 中 | ✅ 完了 |

### 共有ウィジェット
| 位置 | 説明 | 優先度 | 状態 |
|----------|-------------|----------|------|
| `lib/shared/widgets/expandable_content_card.dart:99` | 今後聖書読み取り画面に接続 | 低 | - |

---

## 保留中の機能

### 高優先度

#### 1. Googleログイン問題解決 ✅ 完了 (2025-12-16)
- **問題**: Googleログインが動作しない（`ApiException: 10`発生）
- **原因**: `google-services.json`にAndroid OAuth Client ID（`client_type: 1`）が欠落
- **解決方法**:
  1. Firebase ConsoleでSHA-1証明書追加: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`
  2. Firebaseが自動的にAndroid OAuth Clientを生成
  3. `google-services.json`を再ダウンロードして適用
- **最終設定**:
  - Android OAuth Client ID: `182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com`
  - Package name: `com.itz.credo`
  - SHA-1: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`
- **結果**: ✅ Google Sign-In正常動作確認
- **参考ドキュメント**: 
  - `docs/GOOGLE_SIGNIN_RESOLVED.md` - 解決完了レポート
  - `docs/ANDROID_OAUTH_CLIENT_FIX.md` - 問題解決ガイド

#### 2. プッシュ通知ナビゲーション ✅ 完了
- **問題**: 通知タップ時に投稿詳細画面に移動しない
- **ファイル**: `push_notification_service.dart:124`
- **完了した作業**:
  - `PushNotificationService`に`setRouter()`メソッド追加
  - `main.dart`でルーター設定
  - `_handleMessageOpenedApp`で`postId`と`parishId`を受け取り`AppRoutes.postDetailPath`でナビゲーション実装

#### 3. お知らせ/コミュニティリストからのナビゲーション ✅ 完了
- **問題**: リスト項目が詳細画面に移動しない
- **ファイル**: `notice_list_page.dart:45`, `community_list_page.dart:50`
- **完了した作業**: 
  - `GoRouter` import追加
  - `ListTile`の`onTap`に`context.push(AppRoutes.postDetailPath(...))`実装

#### 4. 位置ベース距離計算機能 ✅ 完了
- **問題**: 教会リストで距離がハードコードされている (`'1.2km'`)
- **ファイル**: `parish_card.dart`, `parish_list_screen.dart`
- **完了した作業**:
  1. ✅ `location_provider.dart`生成 - ユーザー位置および教会座標/距離計算Provider
  2. ✅ `geocoding_service.dart`生成 - Google Maps Geocoding APIを使用した住所-座標変換
  3. ✅ `parish_card.dart`で実際の距離計算および表示
  4. ✅ `parish_list_screen.dart`で距離順ソート機能実装
  5. ✅ 位置権限リクエスト機能実装 (画面で明示的に権限リクエスト)
  6. ✅ Google Maps APIキーを環境変数に分離 (`.env`ファイル、`flutter_dotenv`使用)
  7. ✅ 距離順フィルタリングバグ修正 - `FutureProvider`アクセス方式修正 (`ref.read` → `ref.watch`)、デフォルト値を`false`に変更、位置情報取得ロジック改善

### 中優先度

#### 4. 通報機能 ✅ 完了
- **問題**: 投稿/コメント通報機能がない
- **完了した作業**:
  1. ✅ 通報モデルおよびリポジトリ生成 (`Report`, `ReportRepository`)
  2. ✅ 共通通報ダイアログウィジェット生成 (`ReportDialog`)
  3. ✅ 投稿/コメントに通報ボタン追加
  4. ✅ Cloud Functions onCreateトリガー追加 (Slack通知送信)
  5. ✅ Firestore Rulesにreportsコレクション規則追加
  6. ✅ 重複通報防止ロジック実装 (5分以内同一対象通報防止)
  7. ✅ Slack webhook URLをdotenvで処理 (`functions/.env`ファイル、dotenvパッケージ追加)
  8. ✅ 投稿自動非表示機能: 通報3件以上で自動的に`status`を"hidden"に変更 (Cloud Functionsで処理)

#### 5. コメント数表示 ✅ 完了
- **問題**: 投稿リストにハードコードされた`commentCount: 0`表示
- **ファイル**: `post_list_screen.dart:47`
- **完了した作業**:
  1. ✅ Postモデルに`commentCount`フィールド追加
  2. ✅ コメント生成時Firestore transactionで`commentCount`自動増加
  3. ✅ `post_list_screen.dart`で実際の`commentCount`使用

#### 6. 投稿数および新規投稿表示器 ✅ 完了
- **問題**: コミュニティホームにハードコードされた値表示
- **ファイル**: `community_home_screen.dart:70-71`
- **完了した作業**:
  1. ✅ `postCountProvider`生成 - 聖堂別投稿数計算
  2. ✅ `hasNewPostsProvider`生成 - 新規投稿有無確認
  3. ✅ SharedPreferencesを使用した最後に読んだタイムスタンプ追跡
  4. ✅ `community_home_screen.dart`に実際のデータ連携

#### 7. Admin投稿非表示機能 ✅ 完了
- **問題**: Adminが投稿を非表示にできる機能がない
- **完了した作業**:
  1. ✅ `UserEntity.isAdmin` getter追加
  2. ✅ Firestore Rulesに`isAdmin()`および`isAdminOfPostParish()` helper function追加
  3. ✅ Posts update規則: 管理者は自分が所属する教会の投稿のみ`status`修正可能
  4. ✅ UIで所属教会チェックおよび非表示/表示オプション表示
  5. ✅ 権限がない場合明確なエラーメッセージ表示

#### 8. 文字サイズ設定機能 ✅ 完了
- **問題**: 高齢ユーザーが文字を大きく見られる機能がない
- **完了した作業**:
  1. ✅ `font_scale_provider.dart`生成 - 文字サイズ倍率管理 (0.85 ~ 1.4)
  2. ✅ `main.dart`で`MediaQuery.textScaler`を通じて全体アプリテキストサイズ調整
  3. ✅ マイページに文字サイズ設定スライダー追加 (`my_page_screen.dart`)
  4. ✅ SharedPreferencesを使用して設定永続化
  5. ✅ リアルタイムプレビュー機能追加 ("サンプルテキスト")

#### 9. 言語設定実装 ✅ 完了
- **問題**: 言語変更ロジックが実装されていない
- **ファイル**: `language_settings_screen.dart:83`
- **完了した作業**:
  1. ✅ ロケール永続性実装 (SharedPreferences) - 既に`locale_provider.dart`に実装済み
  2. ✅ 選択時アプリロケール更新 - `setLocaleByLanguageCode`メソッド使用
  3. ✅ 日付フォーマットロケール動的更新 - `locale_provider.dart`に`initializeDateFormatting`追加
  4. ✅ 翻訳データ自動再読み込み - `appLocalizationsProvider` invalidate追加

### 低優先度

#### 7. メッセンジャー / 友達機能
- **問題**: QRスキャナー友達追加が実装されていない
- **ファイル**: `qr_scanner_screen.dart:108-109`
- **必要な作業**:
  1. 友達/接続データモデル設計
  2. 友達リクエストシステム生成
  3. メッセンジャー機能実装

---

## リファクタリング作業

### 重要
- [x] 中央化されたロギングサービス生成 ✅
- [x] 重複投稿ソートロジック抽出 ✅
- [x] コミュニティrepositoryのエラー処理標準化 ✅

### 高
- [x] `edit_profile_screen.dart`分割 (1,106行 → 457行) ✅
  - 8個のウィジェットに分離: 既存5個 + 新たに分離された3個 (`FeastDaySearchSheet`, `UserSearchSheet`, `ParishSearchSheet`)
- [x] `post_detail_screen.dart`分割 (959行 → 304行) ✅
- [x] `parish_list_screen.dart`分割 (739行 → 336行) ✅
- [x] `post_list_screen.dart`分割 (543行 → 332行) ✅
  - 3個のウィジェットに分離: `PostCard`, `PostListFilterBar`, `PostListSearchBar`
- [x] `post_create_screen.dart`分割 (516行 → 244行) + ロギング置き換え ✅
  - 16個の`debugPrint`を`AppLogger.community()`に置き換え完了
  - 4個のウィジェットに分離: `PostFormFields`, `PostImagePicker`, `PostOfficialSettings`, `PostFormSubmitButton`
- [x] `post_edit_screen.dart`分割 (556行 → 252行) ✅
  - `post_create_screen.dart`と共通ウィジェット再利用
- [x] コミュニティモデルをFreezedにマイグレーション ✅
  - 対象: `post.dart`, `comment.dart`, `notification.dart`, `app_user.dart`
  - 完了: すべてのモデルをFreezedに変換、`toFirestore()`メソッド追加、DateTime変換器実装

### 中
- [x] `push_notification_service.dart`のdebugPrintをAppLoggerに置き換え (18個) ✅
- [x] `parish_service.dart`のdebugPrintとthrow ExceptionをAppLogger/Failureに置き換え ✅
- [x] `saint_feast_day_service.dart`のthrow ExceptionをFailureに置き換え ✅
- [x] `prayer_service.dart`のthrow ExceptionをFailureに置き換え ✅
- [x] `image_upload_service.dart`のthrow ExceptionをFailureに置き換え ✅
- [x] `app_user.dart`のthrow ExceptionをValidationFailureに置き換え ✅
- [ ] 単体テストカバレッジ追加
  - 優先度: Repository実装、State notifiers、ユーティリティ関数
  - 予想作業量: 8-12時間
- [x] Provider構成標準化 ✅
  - 現在: `features/parish/presentation/providers/`, `features/community/data/providers/`
  - 推奨: `features/{feature}/data/providers/` (Repository), `features/{feature}/presentation/providers/` (UI state)
  - 完了: Repository Providerは`data/providers/`に維持、UI state Providerは`presentation/providers/`に移動、`community_presentation_providers.dart`生成
- [x] 共有サービスをcoreに移動 ✅
  - `image_upload_service.dart`を`core/data/services/`に移動
  - 完了: ファイル移動およびimportパス更新完了
- [x] 残りのprint文AppLoggerに置き換え ✅
  - 確認: `post_create_screen.dart`には既にすべてのprint文がAppLoggerに置き換えられている

---

## 技術的負債

| カテゴリ | 個数 | 影響 | 状態 |
|----------|-------|--------|------|
| 原始Exception投げ | 6個 (正常) | 高 | ✅ 主要サービス完了 - transaction内部、presentation layerは正常 |
| デバッグprint文 | 0個 | 中 | ✅ 完了 - すべてのprint文がAppLoggerに置き換えられた |
| 大きなファイル (>500行) | 0個 | 中 | ✅ 完了 - すべての大きなファイル分割完了 |
| 欠落したテスト | 全体 | 高 | - |
| 重複コードブロック | 0 | 中 | ✅ ソートロジックExtension抽出完了 |
| コンパイルエラー | 0個 | 高 | ✅ 完了 - すべての深刻なエラー(severity 1)修正完了 |
| Deprecated API使用 | 0個 | 中 | ✅ 完了 - RadioListTileのdeprecated onChangedをRadioGroupにマイグレーション完了 |
| 使用していないコード | 0個 | 低 | ✅ 完了 - 使用していない変数、import、関数削除完了 |

---

## 完了したTODO

| 日付 | 説明 | PR/コミット |
|------|-------------|-----------|
| 2025-12-12 | 中央化されたロギングサービス実装および主要ファイル適用 | d8f1c84d |
| 2025-12-12 | `AppLogger`サービス生成および`auth_repository_impl.dart`ロギング置き換え | d8f1c84d |
| 2025-12-12 | `firestore_post_repository.dart`ロギング置き換え | d8f1c84d |
| 2025-12-12 | `firestore_notification_repository.dart`, `firestore_user_repository.dart`ロギング置き換え | d8f1c84d |
| 2025-12-12 | `image_upload_service.dart`, `home_screen.dart`ロギング置き換え | d8f1c84d |
| 2025-12-12 | 重複ソートロジック抽出 - `PostListExtension`生成および適用 | d8f1c84d |
| 2025-12-12 | プッシュ通知ナビゲーション実装 | d8f1c84d |
| 2025-12-12 | お知らせ/コミュニティリストナビゲーション実装 | d8f1c84d |
| 2025-12-12 | コミュニティ専用失敗タイプ生成およびエラー処理標準化 | d8f1c84d |
| 2025-12-12 | すべてのコミュニティrepositoryをEitherパターンにリファクタリング | d8f1c84d |
| 2025-12-12 | コメント数表示機能実装 - PostモデルにcommentCount追加およびコメント生成時自動更新 | d8f1c84d |
| 2025-12-12 | 投稿数および新規投稿表示器実装 - postCountProvider, hasNewPostsProvider生成 | d8f1c84d |
| 2025-12-12 | Firestore複合インデックス関連コメント更新 | d8f1c84d |
| 2025-12-12 | `liturgical_reading_service.dart`すべてのprint文をAppLoggerに変更 (44個) | d8f1c84d |
| 2025-12-12 | `auth_provider.dart`すべてのprint文をAppLoggerに変更 (3個) | d8f1c84d |
| 2025-12-12 | モックデータスクリプト削除 - `scripts/create_sample_posts.dart`, `scripts/README_SAMPLE_DATA.md` | d8f1c84d |
| 2025-12-12 | Firestore複合インデックス設定完了 - `watchCommunityPosts`と`watchAllPosts`でparishIdフィルタリング有効化、`firestore.indexes.json`に必要なインデックス追加 | d8f1c84d |
| 2025-12-12 | `post_detail_screen.dart`分割完了 (959行 → 302行) - ウィジェットを8個のファイルに分離: PostImageViewer, PostDetailHeader, PostDetailAuthorInfo, PostDetailImages, PostDetailLikeButton, PostDetailCommentsSection, PostDetailCommentInput, PostCommentSubmitter | d8f1c84d |
| 2025-12-12 | `pages`ディレクトリを`screens`に統合 - `post_edit_page.dart`, `notice_list_page.dart`, `community_list_page.dart`を`screens`ディレクトリに移動およびクラス名変更 (Page → Screen) | d8f1c84d |
| 2025-12-12 | `push_notification_service.dart`のdebugPrintをAppLoggerに置き換え (18個) | d8f1c84d |
| 2025-12-12 | `parish_service.dart`のdebugPrintとthrow ExceptionをAppLogger/Failureに置き換え | d8f1c84d |
| 2025-12-12 | `saint_feast_day_service.dart`のthrow ExceptionをCacheFailureに置き換え | d8f1c84d |
| 2025-12-12 | `prayer_service.dart`のthrow ExceptionをCacheFailureに置き換え | d8f1c84d |
| 2025-12-12 | `image_upload_service.dart`のthrow ExceptionをValidationFailure/FirebaseFailureに置き換え | d8f1c84d |
| 2025-12-12 | `app_user.dart`のthrow ExceptionをValidationFailureに置き換え | d8f1c84d |
| 2025-12-12 | `post_list_screen.dart`分割完了 (543行 → 332行) - ウィジェットを3個のファイルに分離: PostCard, PostListFilterBar, PostListSearchBar | d8f1c84d |
| 2025-12-12 | `post_create_screen.dart`分割完了 (516行 → 244行) - 16個のdebugPrintをAppLoggerに置き換え、4個のウィジェットに分離: PostFormFields, PostImagePicker, PostOfficialSettings, PostFormSubmitButton | d8f1c84d |
| 2025-12-12 | `post_edit_screen.dart`分割完了 (556行 → 252行) - post_create_screen.dartと共通ウィジェット再利用 | d8f1c84d |
| 2025-12-12 | コミュニティモデルをFreezedにマイグレーション完了 - `post.dart`, `comment.dart`, `notification.dart`, `app_user.dart`をFreezedに変換、`toFirestore()`メソッド追加、DateTime変換器実装 | d8f1c84d |
| 2025-12-12 | 位置ベース距離計算機能実装 - `location_provider.dart`, `geocoding_service.dart`生成、`parish_card.dart`で実際の距離表示、`parish_list_screen.dart`で距離順ソートおよび位置権限リクエスト機能追加 | d8f1c84d |
| 2025-12-12 | Google Maps APIキーを環境変数に分離 - `flutter_dotenv`追加、`.env`ファイル生成、`geocoding_service.dart`で環境変数使用 | d8f1c84d |
| 2025-12-12 | 教会カードUI改善 - オーバーフロー問題解決 (横スクロール可能)、JPバッジ削除 (基本言語のため)、地図ボタンをGoogle Mapsに接続 (住所検索) | d8f1c84d |
| 2025-12-15 | Provider構成標準化 - Repository Providerは`data/providers/`に維持、UI state Providerは`presentation/providers/`に移動、`community_presentation_providers.dart`生成 | cfc4ab29 |
| 2025-12-15 | 共有サービスをcoreに移動 - `image_upload_service.dart`を`core/data/services/`に移動、importパス更新 | cfc4ab29 |
| 2025-12-15 | Slack webhook URLをdotenvで処理 - `functions/.env`ファイル生成、dotenvパッケージ追加、`functions/src/index.ts`でdotenv使用 | cfc4ab29 |
| 2025-12-15 | Admin投稿非表示バグ修正 - Firestore Rulesに`commentCount`更新権限追加、`updatePost()`フィールド比較ロジック改善 (リスト比較、デフォルト値処理) | cfc4ab29 |
| 2025-12-15 | コメント機能バグ修正 - `PostCommentSubmitter`の`Ref`タイプを`WidgetRef`に変更、`currentAppUserProvider.future`使用、Firestoreトランザクション順序修正 (読み取り → 書き込み) | cfc4ab29 |
| 2025-12-15 | 投稿非表示後リストに戻る - `_hidePost()`成功時`Navigator.pop()`追加 | cfc4ab29 |
| 2025-12-15 | 文字サイズ設定機能追加 - `font_scale_provider.dart`生成、`main.dart`で`MediaQuery.textScaler`適用、マイページに設定UI追加 | cfc4ab29 |
| 2025-12-15 | 距離順フィルタリングバグ修正 - `parish_list_screen.dart`で`FutureProvider`アクセス方式修正 (`ref.read` → `ref.watch`)、デフォルト値を`false`に変更、位置情報取得ロジック改善 | cfc4ab29 |
| 2025-12-15 | `edit_profile_screen.dart`追加分割完了 (1,106行 → 457行、649行減少、59%減少) - 検索シートウィジェット3個を別ファイルに分離: `FeastDaySearchSheet`, `UserSearchSheet`, `ParishSearchSheet` | cfc4ab29 |
| 2025-12-15 | 聖堂住所更新作業完了 - 799個の聖堂中798個の聖堂に詳細住所追加 (99.9%完了率)、ウェブ検索による住所収集、`scripts/batch_update_addresses.py`スクリプト生成、ファイル別完了率: 14個のファイル100%完了、sapporo.json 98.4% (61/62)、未完了: カトリック奥尻教会 (番地情報なし) | cfc4ab29 |
| 2025-12-15 | ミサ時間データ整理作業完了 - massTime文字列ベースでmassTimes/foreignMassTimes再生成、重複項目6個解決、巡回教会96個の聖堂問い合わせ案内で統一、空データ項目17個処理 (kyoto.json 9個、nagoya.json 1個、osaka.json 1個、sapporo.json 4個、yokohama.json 2個)、`scripts/parse_mass_times.py`改善、ホームページ確認が必要な教会たち案内文句追加、バックアップファイル28個削除 | cfc4ab29 |
| 2025-12-15 | 全体コードベースエラー修正完了 - RadioListTileのdeprecated onChangedをRadioGroupにマイグレーション (report_dialog.dart)、l10n変数欠落問題修正 (20+ファイル)、constキーワードエラー修正 (ランタイム値使用時)、使用していない変数/import削除、重複import削除、使用していない関数削除 (_dateTimeToJson, _dateTimeFromJson)、すべての深刻なエラー(severity 1)修正完了 | cfc4ab29 |
| 2025-12-15 | 言語設定実装完了 - `locale_provider.dart`に日付フォーマットロケール動的更新追加 (`initializeDateFormatting`)、`language_settings_screen.dart`で`appLocalizationsProvider` invalidate追加して翻訳データ自動再読み込み | cfc4ab29 |
| 2025-12-15 | エラー修正完了 - `daily_mass_screen.dart`でl10nパラメータ欠落修正 (`_buildCommentInput`メソッドに`AppLocalizations l10n`パラメータ追加)、`parish_detail_screen.dart`でl10nパラメータ欠落修正および使用していないメソッド削除 (`_buildMassTimeSection`メソッドに`AppLocalizations l10n`パラメータ追加、`_launchMapByCoordinates`メソッド削除) | cfc4ab29 |
| 2025-12-15 | 聖書テキストライセンス状態確認機能実装 - `bible_license_provider.dart`生成 (Firestoreの`app_settings/bible_license`ドキュメントでライセンス状態確認)、`daily_mass_screen.dart`でハードコードされた`isBibleTextLicensed`をProviderに置き換え、Firestore Rulesに`app_settings`コレクション読み取り権限追加 | cfc4ab29 |
| 2025-12-15 | お知らせ投稿プッシュ通知機能改善 - FCMトークン更新時自動Firestore保存、`_currentUserId`管理追加 | cfc4ab29 |
| 2025-12-15 | 聖堂座標データ追加 - Google Maps Geocoding APIを使用してすべての聖堂JSONファイルにlatitude/longitude座標追加、`scripts/add_coordinates.py`生成 | cfc4ab29 |
| 2025-12-15 | 距離順フィルターProviderバグ修正 - `parishDistanceProvider`でビルド中他のProvider修正問題解決 (`StateNotifierListenerError`修正) | cfc4ab29 |
| 2025-12-15 | 距離順フィルターチップUI改善 - `ParishFilterChip`で`isSelected`状態によるチェックアイコンおよび背景色変更 | cfc4ab29 |
| 2025-12-15 | 外国語ミサデータ修正 - 末吉町教会など13個の聖堂の`foreignMassTimes`データを`massTime`テキストベースで修正、`scripts/fix_foreign_mass_times.py`および`scripts/auto_fix_foreign_mass.py`生成 | cfc4ab29 |
| 2025-12-15 | ミサ時間データ一貫性検証および修正 - kagoshima.jsonの志布志教会、阿久根教会`massTimes`データを`massTime`テキストと一致するように修正、kyoto.jsonの上野教会`massTimes`に土曜日19:30および日曜日09:00、10:30、17:00追加、`foreignMassTimes`にタガログ語ミサ追加 | bad05ad |
| 2025-12-16 | 聖人祝日データ更新 - ChatGPT APIを使用して全体月別欠落聖人追加: 12,1,2月 95名、3,4,5月 112名、6,7,8月 82名、9,10,11月 95名追加 (合計 384名)、`scripts/check_and_fix_missing_saints.py`スクリプト使用 | - |
| 2025-12-16 | 多言語サポート完了 - すべての言語ファイルの日本語テキストを各言語に翻訳完了: 英語 76個、スペイン語 289個、ポルトガル語 289個、ベトナム語 289個、中国語翻訳完了、すべての言語ファイルから日本語文字(ひらがな/カタカナ)削除完了 | - |
| 2025-12-16 | Googleログイン問題解決 - ApiException: 10 (DEVELOPER_ERROR)エラー解決、Firebase ConsoleでSHA-1証明書追加 (61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A)、Android OAuth Client ID自動生成確認 (182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com)、google-services.json更新 (client_type: 1追加)、Google Sign-In正常動作確認 | - |
| 2025-12-16 | 検索機能実装 - 投稿検索機能実装 (PostRepository.searchPostsメソッド追加、Firestoreクエリ + クライアントサイドフィルタリング)、聖堂検索改善 (名前、住所、都道府県、教区、地域検索拡張、検索結果ソート改善)、searchPostsProvider追加、検索UI改善 (検索履歴サービス、自動補完機能、PostListSearchBarおよびParishSearchBar改善) | - |

---

## 次のスプリント推奨作業

### 優先度1: 高 (即座に進行)

1. **言語設定実装** ✅ 完了
   - ロケール永続性実装 (SharedPreferences)
   - 選択時アプリロケール更新
   - 日付フォーマットロケール動的更新
   - 翻訳データ自動再読み込み

2. **単体テストカバレッジ追加** (8-12時間)
   - 優先度: Repository実装、State notifiers、ユーティリティ関数
   - 段階的に追加可能

### 優先度2: 中

3. **Provider構成標準化** ✅ 完了
   - Repository Providerは`data/providers/`に維持
   - UI state Providerは`presentation/providers/`に移動
   - `community_presentation_providers.dart`生成およびすべてのimportパス更新

4. **共有サービスをcoreに移動** ✅ 完了
   - `image_upload_service.dart`を`core/data/services/`に移動
   - importパス更新完了

**総予想時間**: 11-17時間

大部分の大きな画面ファイル(500行以上)が既に分割され、コード可読性と保守性が大幅に向上しました。

---

## このドキュメント更新方法

1. コードに新TODOを追加する際、ここに項目追加
2. TODOを完了したら「完了したTODO」セクションに移動
3. 完了した項目にPR/コミット参照を含める
4. スプリント計画中このドキュメント検討
