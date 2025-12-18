# Credo 추가 기능 제안서

**작성일**: 2025-12-17  
**마지막 업데이트**: 2025-12-18 (성인 이미지 검색 기능 완료)  
**프로젝트 상태**: 대부분의 핵심 기능 완료, 추가 기능 제안 단계

---

## 📋 현재 상태 요약

### ✅ 완료된 주요 기능
- 인증 (이메일, Google, Apple)
- 커뮤니티 (게시글, 댓글, 좋아요, 신고)
- 알림 타입 구분 (새 글, 코멘트, 공지사항)
- 교회 검색 및 위치 기반 기능
- 일일 미사 독서
- 프로필 관리
- 푸시 알림
- 검색 기능 (게시글, 성당)
- 다국어 지원 (7개 언어)
- 글씨 크기 설정
- 성인 축일 모달 (GPT 축하 메시지, 하루에 한번 표시, 성인 이미지 자동 검색 및 표시)
- 성당별 알림 그룹화 및 아코디언 기능
- 공유 기능 (게시글, 일일 미사 독서, 교회 정보)

### ⏳ 준비 중인 기능
- 성경 읽기 화면 (TODO 주석)
- 이용 규약/개인정보 처리방침 (Coming Soon)

---

## 🎯 추가 기능 제안

### 우선순위 높음 (즉시 구현 권장)

#### 1. 알림 설정 화면 구현 ⭐⭐⭐ ✅ 완료
**현재 상태**: 완전히 구현됨  
**완료 날짜**: 2025-12-18  
**영향**: 높음 (사용자 경험 개선)

**구현된 기능**:
- ✅ 푸시 알림 ON/OFF 토글 (`enabled`)
- ✅ 알림 카테고리별 설정:
  - ✅ 공지사항 알림 (`notices`)
  - ✅ 댓글 알림 (`comments`)
  - ✅ 좋아요 알림 (`likes`)
  - ✅ 일일 미사 독서 알림 (`dailyMass`)
- ✅ 알림 시간대 설정 (조용한 시간) (`quietHoursStart`, `quietHoursEnd`)
- ✅ Firestore에 사용자 알림 설정 저장 (`users/{userId}/notificationSettings/settings`)
- ✅ 백엔드에서 알림 전송 시 설정 확인 구현됨

**구현 위치**:
- `lib/features/profile/presentation/screens/notification_settings_screen.dart` - 화면 구현
- `lib/features/profile/data/models/notification_settings.dart` - 모델 (Freezed)
- `lib/features/profile/data/repositories/notification_settings_repository_impl.dart` - Repository
- `lib/features/profile/data/providers/notification_settings_providers.dart` - Riverpod Provider
- `lib/features/profile/presentation/widgets/my_page_settings_section.dart` - 마이페이지에서 접근
- `lib/config/routes/app_router.dart` - 라우터 연결 (line 260-264)
- `lib/config/routes/app_routes.dart` - 라우트 경로 상수 (`/my-page/notification-settings`)

**참고사항**:
- ✅ 알림 설정은 마이페이지 > 설정 섹션에서 접근 가능
- ✅ 라우터 연결 완료: `/my-page/notification-settings` (라우트 이름: `notificationSettings`)
- ✅ 마이페이지 설정 카드에서 `AppRoutes.notificationSettings`로 네비게이션
- 로그인한 사용자만 설정 가능 (비로그인 시 로그인 필요 메시지 표시)
- 설정 변경 시 즉시 Firestore에 저장됨
- ✅ 백엔드에서 알림 전송 시 설정 확인 구현됨 (`functions/src/index.ts`의 `onPostCreated`, `onCommentCreated`에서 확인)
  - 전체 알림 ON/OFF 확인
  - 카테고리별 알림 설정 확인 (공지사항, 댓글)
  - 조용한 시간대 확인 (자정을 넘어가는 경우 포함)

---

#### 2. 성경 읽기 화면 구현 ⭐⭐⭐
**현재 상태**: TODO 주석만 존재 (`expandable_content_card.dart:99`)  
**예상 작업량**: 6-8시간  
**영향**: 중간 (기능 완성도)

**기능 상세**:
- 성경 구절 참조 파싱 (예: "イザヤ書 48:17–19")
- 성경 텍스트 표시 (라이선스 확인 필요)
- 장/절 네비게이션
- 북마크 기능
- 하이라이트/메모 기능 (선택사항)
- 다국어 성경 지원

**구현 위치**:
- `lib/features/bible/presentation/screens/bible_reading_screen.dart`
- `lib/features/bible/data/services/bible_service.dart`
- `expandable_content_card.dart`에서 연결

**참고**: 이미 `bible_license_provider.dart`가 있어서 라이선스 확인은 가능

---

---

### 우선순위 중간 (점진적 구현)

#### 4. 북마크/즐겨찾기 기능 확장 ⭐⭐
**현재 상태**: 교회 즐겨찾기만 존재  
**예상 작업량**: 6-8시간  
**영향**: 중간

**기능 상세**:
- 게시글 북마크
- 일일 미사 독서 북마크
- 성경 구절 북마크
- 북마크 목록 화면
- 북마크한 게시글 빠른 접근

**구현 위치**:
- `lib/features/bookmarks/` (새 모듈)
- Firestore 컬렉션: `users/{userId}/bookmarks`

---

#### 5. 오프라인 모드 지원 ⭐⭐ ✅ 기본 구현 완료
**현재 상태**: 기본 구조 구현 완료  
**완료 날짜**: 2025-12-18  
**영향**: 중간 (사용자 편의성)

**구현된 기능**:
- ✅ 오프라인 상태 감지 (`connectivity_plus` 사용)
- ✅ 캐시 서비스 구현 (`CacheService` - SharedPreferences 기반)
- ✅ 오프라인 상태 표시 UI (`OfflineIndicator`)
- ✅ 동기화 상태 표시 UI (`SyncStatusIndicator`)
- ✅ 일일 미사 독서: 이미 assets 파일에서 로드되므로 오프라인에서도 작동
- ✅ 교회 정보: 이미 assets 파일에서 로드되므로 오프라인에서도 작동
- ✅ 게시글: Firestore 오프라인 지속성 활용 가능 (추가 캐싱 선택사항)

**구현 위치**:
- `lib/core/data/services/cache_service.dart` - 캐시 서비스 (SharedPreferences 기반)
- `lib/shared/providers/connectivity_provider.dart` - 네트워크 상태 감지 Provider
- `lib/shared/widgets/offline_indicator.dart` - 오프라인/동기화 상태 표시 위젯
- `lib/shared/widgets/main_scaffold.dart` - 메인 화면에 오프라인 인디케이터 통합

**참고사항**:
- 일일 미사 독서와 교회 정보는 assets 파일에서 로드되므로 별도 캐싱 불필요
- Firestore는 기본적으로 오프라인 지속성을 지원하므로 게시글도 오프라인에서 읽기 가능
- 추가적인 오프라인 캐싱이 필요한 경우 `CacheService`를 사용하여 구현 가능
- `CacheService`는 만료 시간 기반 캐싱을 지원하며, 자동으로 만료된 캐시를 정리

---

#### 6. 이벤트/일정 관리 기능 ⭐⭐
**현재 상태**: 미구현  
**예상 작업량**: 10-15시간  
**영향**: 중간 (커뮤니티 참여도 향상)

**기능 상세**:
- 교회별 이벤트 생성 (관리자만)
- 이벤트 목록 표시
- 이벤트 상세 정보
- 이벤트 알림
- 캘린더 연동 (선택사항)

**구현 위치**:
- `lib/features/events/` (새 모듈)
- Firestore 컬렉션: `events/{eventId}`
- `parish_detail_screen.dart`에 이벤트 섹션 추가

---

#### 7. 통계/인사이트 화면 ⭐
**현재 상태**: 미구현  
**예상 작업량**: 6-8시간  
**영향**: 낮음 (사용자 참여도 모니터링)

**기능 상세**:
- 읽은 미사 독서 통계
- 작성한 게시글/댓글 수
- 방문한 교회 수
- 기도 일수 연속 기록
- 개인 성장 차트

**구현 위치**:
- `lib/features/stats/presentation/screens/stats_screen.dart`
- `my_page_screen.dart`에 통계 섹션 추가

---

### 우선순위 낮음 (장기 계획)

#### 8. 성인 축일 모달 ✅ 완료 (2025-12-17)
**현재 상태**: 성인 축일 데이터는 있음 (`saints_feast_days.json`)  
**예상 작업량**: 4-6시간  
**영향**: 낮음 (특정 사용자층)

**완료된 작업**:
1. ✅ 성인 축일 모달 위젯 생성 (`SaintFeastDayModal`)
   - 큰 이미지 영역 (350px 높이) - 실제 성인 이미지 자동 검색 및 표시
   - 성인 이름, 축일 정보, 인사말, 설명 표시
   - 세례명 일치 시 특별 표시 배지
2. ✅ Provider 생성
   - `todaySaintsProvider`: 오늘의 성인 축일 목록
   - `userBaptismalSaintProvider`: 사용자 세례명과 일치하는 오늘의 성인
   - `saintImageUrlProvider`: 성인 이미지 URL 검색 및 제공
3. ✅ 홈 화면 통합
   - 앱 시작 시 사용자 세례명과 일치하는 성인 축일이 있으면 모달 자동 표시
   - 중복 표시 방지 로직 구현
4. ✅ 다국어 지원
   - 일본어, 한국어, 영어 번역 추가
   - 날짜 포맷 다국어 지원 (월 이름 포함)
5. ✅ UI 개선
   - 그라데이션 배경
   - 원형 아이콘 프레임
   - 축일 타입별 색상 구분 (대축일: 빨강, 축일: 주황, 기념일: 기본색)
6. ✅ 성인 이미지 자동 검색 기능 (2025-12-18)
   - Wikipedia API를 통한 이미지 검색 (우선순위 1)
   - GPT-4o를 통한 이미지 URL 검색 (우선순위 2)
   - SharedPreferences 기반 캐싱
   - 실패한 URL 추적 및 자동 재검색 (404 에러 처리)
   - 실패한 URL 목록을 SharedPreferences에 저장하여 영구 추적

---

#### 9. 기도 요청 기능 ⭐
**현재 상태**: 미구현  
**예상 작업량**: 8-12시간  
**영향**: 중간 (커뮤니티 연결)

**기능 상세**:
- 기도 요청 게시글 작성
- 기도 요청 목록
- 기도 응답 기능
- 익명 기도 요청 옵션

**구현 위치**:
- `lib/features/prayer_requests/` (새 모듈)
- 커뮤니티 게시글과 통합 가능

---

#### 10. 공유 기능 개선 ⭐ ✅ 완료
**현재 상태**: 완전히 구현됨  
**완료 날짜**: 2025-12-18  
**영향**: 낮음 (바이럴 마케팅)

**구현된 기능**:
- ✅ 게시글 공유 (딥링크 및 앱 스킴 URL 생성)
- ✅ 일일 미사 독서 공유 (날짜별 딥링크)
- ✅ 교회 정보 공유 (교회 상세 페이지 딥링크)
- ✅ 각 화면에 공유 버튼 추가 (`PostDetailScreen`, `DailyMassScreen`, `ParishDetailScreen`)

**구현 위치**:
- `lib/core/utils/share_utils.dart` - 공유 유틸리티 클래스
- `lib/features/community/presentation/screens/post_detail_screen.dart` - 게시글 공유 버튼
- `lib/features/mass/presentation/screens/daily_mass_screen.dart` - 일일 미사 독서 공유 버튼
- `lib/features/parish/presentation/widgets/parish_detail_header.dart` - 교회 정보 공유 버튼
- `assets/l10n/app_ja.json` - 공유 관련 번역 키 추가 (`mass.shareReading`, `community.sharePost`, `parish.shareParish`, `common.shareLink`, `common.shareAppLink`)
- `lib/core/utils/app_localizations.dart` - 공유 관련 번역 getter 추가

**참고사항**:
- `share_plus` 패키지 사용
- 딥링크 URL 형식: `https://credo.app/{path}`
- 앱 스킴 URL 형식: `credo://{path}`
- 공유 텍스트에 딥링크와 앱 스킴 URL 모두 포함
- 향후 Firebase Dynamic Links 통합 가능 (현재는 기본 URL 사용)

---

#### 11. 관리자 대시보드 (웹) ⭐
**현재 상태**: 미구현  
**예상 작업량**: 20-30시간  
**영향**: 중간 (운영 효율성)

**기능 상세**:
- 게시글 관리
- 신고 처리
- 사용자 관리
- 통계 대시보드
- 이벤트 관리

**구현 위치**:
- 별도 웹 프로젝트 또는 Flutter Web
- Firebase Admin SDK 사용

---

#### 12. 메신저/친구 기능 ⭐
**현재 상태**: QR 스캐너만 존재, 기능 미구현  
**예상 작업량**: 20-30시간  
**영향**: 낮음 (복잡도 높음)

**기능 상세**:
- 친구 요청/수락 시스템
- 1:1 채팅
- 그룹 채팅 (선택사항)
- 실시간 메시지 동기화

**구현 위치**:
- `lib/features/messenger/` (새 모듈)
- Firestore 컬렉션: `friendships`, `messages`

**참고**: TODO.md에 이미 언급됨 (낮은 우선순위)

---

## 📊 우선순위 매트릭스

| 기능 | 우선순위 | 예상 시간 | 영향 | 난이도 | 추천 순서 | 상태 |
|------|----------|-----------|------|--------|----------|------|
| 알림 설정 화면 | 높음 | ✅ 완료 | 높음 | 낮음 | - | ✅ 완료 (2025-12-18) |
| 성경 읽기 화면 | 높음 | 6-8시간 | 중간 | 중간 | 1 | - |
| 다크 모드 | 높음 | 4-6시간 | 중간 | 낮음 | 2 | - |
| 북마크 확장 | 중간 | 6-8시간 | 중간 | 중간 | 3 | - |
| 오프라인 모드 | 중간 | ✅ 완료 | 중간 | 높음 | - | ✅ 완료 (2025-12-18) |
| 이벤트 관리 | 중간 | 10-15시간 | 중간 | 중간 | 4 | - |
| 통계 화면 | 중간 | 6-8시간 | 낮음 | 낮음 | 5 | - |
| 성인 축일 알림 | 낮음 | ✅ 완료 | 낮음 | 낮음 | - | ✅ 완료 (2025-12-17) |
| 기도 요청 | 낮음 | 8-12시간 | 중간 | 중간 | 6 | - |
| 공유 기능 개선 | 낮음 | ✅ 완료 | 낮음 | 낮음 | - | ✅ 완료 (2025-12-18) |
| 관리자 대시보드 | 낮음 | 20-30시간 | 중간 | 높음 | 7 | - |
| 메신저/친구 | 낮음 | 20-30시간 | 낮음 | 높음 | 8 | - |

---

## 🎯 권장 구현 순서

### Sprint 1 (2주) - 즉시 구현
1. ✅ **알림 설정 화면** (완료 - 2025-12-18)
   - 사용자 요청이 많은 기능
   - 구현 난이도 낮음
   - 사용자 경험 개선 효과 큼

2. **성경 읽기 화면** (6-8시간)
   - TODO 주석으로 이미 계획됨
   - 기능 완성도 향상

3. **다크 모드** (4-6시간)
   - 사용자 선호도 반영
   - 구현 난이도 낮음

**총 예상 시간**: 10-14시간

---

### Sprint 2 (2주) - 점진적 구현
4. **북마크 확장** (6-8시간)
5. ✅ **오프라인 모드** (완료 - 2025-12-18) - 기본 구조 구현 완료

**총 예상 시간**: 6-8시간

---

### Sprint 3 (2주) - 커뮤니티 강화
6. **이벤트 관리** (10-15시간)
7. **통계 화면** (6-8시간)

**총 예상 시간**: 16-23시간

---

## 💡 추가 고려사항

### 기술적 개선
- **단위 테스트 커버리지 추가** (TODO.md에 언급됨, 8-12시간)
  - Repository 테스트
  - State notifiers 테스트
  - 유틸리티 함수 테스트

### 사용자 경험 개선
- **로딩 상태 개선**: Skeleton UI 추가
- **에러 처리 개선**: 더 친화적인 에러 메시지
- **접근성 개선**: 스크린 리더 지원 강화

### 성능 최적화
- **이미지 최적화**: 캐싱 및 압축
- **Firestore 쿼리 최적화**: 인덱스 추가
- **앱 크기 최적화**: 불필요한 의존성 제거

---

## 📝 구현 시 주의사항

1. **Clean Architecture 준수**: 모든 새 기능은 기존 아키텍처 패턴 따르기
2. **다국어 지원**: 모든 새 기능은 7개 언어 번역 필요
3. **에러 처리**: `Failure` 타입 사용, `Either` 패턴 준수
4. **로깅**: `AppLogger` 사용
5. **테스트**: 가능한 경우 단위 테스트 작성

---

## 🔗 관련 문서

- [TODO.md](./TODO.md) - 현재 작업 상태
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 아키텍처 가이드
- [BACKEND_ARCHITECTURE.md](./BACKEND_ARCHITECTURE.md) - 백엔드 구조

---

**마지막 업데이트**: 2025-12-18

