# Credo TODO 추적

이 문서는 코드베이스에서 발견된 모든 TODO 주석과 보류 중인 기능 구현을 추적합니다.

**마지막 업데이트**: 2025-12-12
**전체 코드베이스**: 약 27,000줄의 Dart 코드, 135개 파일

---

## 코드 내 TODO 주석

### 프로필 기능
| 위치 | 설명 | 우선순위 | 상태 |
|----------|-------------|----------|------|
| `lib/features/profile/presentation/screens/qr_scanner_screen.dart:108` | 메신저 기능 구현 시 여기서 사용자 추가 처리 | 낮음 | - |
| `lib/features/profile/presentation/screens/qr_scanner_screen.dart:147` | 메신저 기능 구현 시 "友達追加" 버튼 추가 | 낮음 | - |
| `lib/features/profile/presentation/screens/language_settings_screen.dart:83` | 언어 변경 로직 구현 (아직 개발 중) | 중간 | - |

### 미사 기능
| 위치 | 설명 | 우선순위 | 상태 |
|----------|-------------|----------|------|
| `lib/features/mass/presentation/screens/daily_mass_screen.dart:318` | 실제 라이선스 상태를 확인하는 로직으로 교체 필요 | 중간 | - |

### 공유 위젯
| 위치 | 설명 | 우선순위 | 상태 |
|----------|-------------|----------|------|
| `lib/shared/widgets/expandable_content_card.dart:99` | 추후 성경 읽기 화면으로 연결 | 낮음 | - |

---

## 보류 중인 기능

### 높은 우선순위

#### 1. 푸시 알림 네비게이션 ✅ 완료
- **문제**: 알림 탭 시 게시글 상세 화면으로 이동하지 않음
- **파일**: `push_notification_service.dart:124`
- **완료된 작업**:
  - `PushNotificationService`에 `setRouter()` 메서드 추가
  - `main.dart`에서 router 설정
  - `_handleMessageOpenedApp`에서 `postId`와 `parishId`를 받아 `AppRoutes.postDetailPath`로 네비게이션 구현

#### 2. 공지/커뮤니티 목록에서 네비게이션 ✅ 완료
- **문제**: 목록 항목이 상세 화면으로 이동하지 않음
- **파일**: `notice_list_page.dart:45`, `community_list_page.dart:50`
- **완료된 작업**: 
  - `GoRouter` import 추가
  - `ListTile`의 `onTap`에 `context.push(AppRoutes.postDetailPath(...))` 구현

#### 3. 위치 기반 거리 계산 기능 ✅ 완료
- **문제**: 교회 목록에서 거리가 하드코딩되어 있음 (`'1.2km'`)
- **파일**: `parish_card.dart`, `parish_list_screen.dart`
- **완료된 작업**:
  1. ✅ `location_provider.dart` 생성 - 사용자 위치 및 교회 좌표/거리 계산 Provider
  2. ✅ `geocoding_service.dart` 생성 - Google Maps Geocoding API를 사용한 주소-좌표 변환
  3. ✅ `parish_card.dart`에서 실제 거리 계산 및 표시
  4. ✅ `parish_list_screen.dart`에서 거리순 정렬 기능 구현
  5. ✅ 위치 권한 요청 기능 구현 (화면에서 명시적으로 권한 요청)
  6. ✅ Google Maps API 키를 환경 변수로 분리 (`.env` 파일, `flutter_dotenv` 사용)

### 중간 우선순위

#### 4. 댓글 수 표시 ✅ 완료
- **문제**: 게시글 목록에 하드코딩된 `commentCount: 0` 표시
- **파일**: `post_list_screen.dart:47`
- **완료된 작업**:
  1. ✅ Post 모델에 `commentCount` 필드 추가
  2. ✅ 댓글 생성 시 Firestore transaction으로 `commentCount` 자동 증가
  3. ✅ `post_list_screen.dart`에서 실제 `commentCount` 사용

#### 5. 게시글 수 및 새 게시글 표시기 ✅ 완료
- **문제**: 커뮤니티 홈에 하드코딩된 값 표시
- **파일**: `community_home_screen.dart:70-71`
- **완료된 작업**:
  1. ✅ `postCountProvider` 생성 - 성당별 게시글 수 계산
  2. ✅ `hasNewPostsProvider` 생성 - 새 게시글 여부 확인
  3. ✅ SharedPreferences를 사용한 마지막 읽은 타임스탬프 추적
  4. ✅ `community_home_screen.dart`에 실제 데이터 연동

#### 6. 언어 설정 구현
- **문제**: 언어 변경 로직이 구현되지 않음
- **파일**: `language_settings_screen.dart:83`
- **필요한 작업**:
  1. 로케일 영속성 구현 (SharedPreferences)
  2. 선택 시 앱 로케일 업데이트
  3. 필요한 위젯 재시작

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
- [x] `edit_profile_screen.dart` 분할 (1,484줄 → 1,105줄) ✅
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
- [ ] Provider 구성 표준화
  - 현재: `features/parish/presentation/providers/`, `features/community/data/providers/`
  - 권장: `features/{feature}/data/providers/` (Repository), `features/{feature}/presentation/providers/` (UI state)
  - 예상 작업량: 1-2시간
- [ ] 공유 서비스를 core로 이동
  - `image_upload_service.dart`를 `core/data/services/`로 이동
  - 예상 작업량: 30분
- [x] 남은 print 문 AppLogger로 교체 ✅
  - 확인: `post_create_screen.dart`에는 이미 모든 print 문이 AppLogger로 교체되어 있음

---

## 기술 부채

| 카테고리 | 개수 | 영향 | 상태 |
|----------|-------|--------|------|
| 원시 Exception 던지기 | 6개 (정상) | 높음 | ✅ 주요 서비스 완료 - transaction 내부, presentation layer는 정상 |
| 디버그 print 문 | 0개 | 중간 | ✅ 완료 - 모든 print 문이 AppLogger로 교체됨 |
| 큰 파일 (>500줄) | 1개 | 중간 | 🔄 진행 중 - `edit_profile_screen.dart`(1,105줄) |
| 누락된 테스트 | 전체 | 높음 | - |
| 중복 코드 블록 | 0 | 중간 | ✅ 정렬 로직 Extension 추출 완료 |

---

## 완료된 TODO

| 날짜 | 설명 | PR/커밋 |
|------|-------------|-----------|
| 2025-12-12 | 중앙화된 로깅 서비스 구현 및 주요 파일 적용 | - |
| 2025-12-12 | `AppLogger` 서비스 생성 및 `auth_repository_impl.dart` 로깅 교체 | - |
| 2025-12-12 | `firestore_post_repository.dart` 로깅 교체 | - |
| 2025-12-12 | `firestore_notification_repository.dart`, `firestore_user_repository.dart` 로깅 교체 | - |
| 2025-12-12 | `image_upload_service.dart`, `home_screen.dart` 로깅 교체 | - |
| 2025-12-12 | 중복 정렬 로직 추출 - `PostListExtension` 생성 및 적용 | - |
| 2025-12-12 | 푸시 알림 네비게이션 구현 | - |
| 2025-12-12 | 공지/커뮤니티 목록 네비게이션 구현 | - |
| 2025-12-12 | 커뮤니티 전용 실패 타입 생성 및 에러 처리 표준화 | - |
| 2025-12-12 | 모든 커뮤니티 repository를 Either 패턴으로 리팩토링 | - |
| 2025-12-12 | 댓글 수 표시 기능 구현 - Post 모델에 commentCount 추가 및 댓글 생성 시 자동 업데이트 | - |
| 2025-12-12 | 게시글 수 및 새 게시글 표시기 구현 - postCountProvider, hasNewPostsProvider 생성 | - |
| 2025-12-12 | Firestore 복합 인덱스 관련 주석 업데이트 | - |
| 2025-12-12 | `liturgical_reading_service.dart` 모든 print 문을 AppLogger로 변경 (44개) | - |
| 2025-12-12 | `auth_provider.dart` 모든 print 문을 AppLogger로 변경 (3개) | - |
| 2025-12-12 | 목업 데이터 스크립트 삭제 - `scripts/create_sample_posts.dart`, `scripts/README_SAMPLE_DATA.md` | - |
| 2025-12-12 | Firestore 복합 인덱스 설정 완료 - `watchCommunityPosts`와 `watchAllPosts`에서 parishId 필터링 활성화, `firestore.indexes.json`에 필요한 인덱스 추가 | - |
| 2025-12-12 | `post_detail_screen.dart` 분할 완료 (959줄 → 302줄) - 위젯을 8개 파일로 분리: PostImageViewer, PostDetailHeader, PostDetailAuthorInfo, PostDetailImages, PostDetailLikeButton, PostDetailCommentsSection, PostDetailCommentInput, PostCommentSubmitter | - |
| 2025-12-12 | `pages` 디렉토리를 `screens`로 통합 - `post_edit_page.dart`, `notice_list_page.dart`, `community_list_page.dart`를 `screens` 디렉토리로 이동 및 클래스명 변경 (Page → Screen) | - |
| 2025-12-12 | `push_notification_service.dart`의 debugPrint를 AppLogger로 교체 (18개) | - |
| 2025-12-12 | `parish_service.dart`의 debugPrint와 throw Exception을 AppLogger/Failure로 교체 | - |
| 2025-12-12 | `saint_feast_day_service.dart`의 throw Exception을 CacheFailure로 교체 | - |
| 2025-12-12 | `prayer_service.dart`의 throw Exception을 CacheFailure로 교체 | - |
| 2025-12-12 | `image_upload_service.dart`의 throw Exception을 ValidationFailure/FirebaseFailure로 교체 | - |
| 2025-12-12 | `app_user.dart`의 throw Exception을 ValidationFailure로 교체 | - |
| 2025-12-12 | `post_list_screen.dart` 분할 완료 (543줄 → 332줄) - 위젯을 3개 파일로 분리: PostCard, PostListFilterBar, PostListSearchBar | - |
| 2025-12-12 | `post_create_screen.dart` 분할 완료 (516줄 → 244줄) - 16개 debugPrint를 AppLogger로 교체, 4개 위젯으로 분리: PostFormFields, PostImagePicker, PostOfficialSettings, PostFormSubmitButton | - |
| 2025-12-12 | `post_edit_screen.dart` 분할 완료 (556줄 → 252줄) - post_create_screen.dart와 공통 위젯 재사용 | - |
| 2025-12-12 | 커뮤니티 모델을 Freezed로 마이그레이션 완료 - `post.dart`, `comment.dart`, `notification.dart`, `app_user.dart`를 Freezed로 변환, `toFirestore()` 메서드 추가, DateTime 변환기 구현 | - |
| 2025-12-12 | 위치 기반 거리 계산 기능 구현 - `location_provider.dart`, `geocoding_service.dart` 생성, `parish_card.dart`에서 실제 거리 표시, `parish_list_screen.dart`에서 거리순 정렬 및 위치 권한 요청 기능 추가 | - |
| 2025-12-12 | Google Maps API 키를 환경 변수로 분리 - `flutter_dotenv` 추가, `.env` 파일 생성, `geocoding_service.dart`에서 환경 변수 사용 | - |

---

## 다음 스프린트 권장 작업

### 우선순위 1: 높음 (즉시 진행)

1. **언어 설정 구현** (2-3시간)
   - 로케일 영속성 구현 (SharedPreferences)
   - 선택 시 앱 로케일 업데이트
   - 필요한 위젯 재시작

2. **단위 테스트 커버리지 추가** (8-12시간)
   - 우선순위: Repository 구현, State notifiers, 유틸리티 함수
   - 점진적으로 추가 가능

### 우선순위 2: 중간

3. **Provider 구성 표준화** (1-2시간)
   - 현재: `features/parish/presentation/providers/`, `features/community/data/providers/`
   - 권장: `features/{feature}/data/providers/` (Repository), `features/{feature}/presentation/providers/` (UI state)

4. **공유 서비스를 core로 이동** (30분)
   - `image_upload_service.dart`를 `core/data/services/`로 이동

**총 예상 시간**: 11-17시간

대부분의 큰 화면 파일(500줄 이상)이 이미 분할되어 코드 가독성과 유지보수성이 크게 향상되었습니다.

---

## 이 문서 업데이트 방법

1. 코드에 새 TODO를 추가할 때 여기에 항목 추가
2. TODO를 완료하면 "완료된 TODO" 섹션으로 이동
3. 완료된 항목에 PR/커밋 참조 포함
4. 스프린트 계획 중 이 문서 검토
