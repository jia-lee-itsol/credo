# Credo 다음 단계 작업 가이드

**생성일**: 2025-01-XX  
**마지막 업데이트**: 2025-01-XX

---

## 📋 문서 검토 요약

### 완료된 주요 작업 ✅
- ✅ Clean Architecture 기반 기능 모듈 구조 완성
- ✅ 에러 처리 표준화 (Either 패턴)
- ✅ 로깅 서비스 중앙화 (AppLogger)
- ✅ 큰 파일 분할 (500줄 이상 파일 모두 분할 완료)
- ✅ Provider 구성 표준화
- ✅ 다국어 지원 완료 (7개 언어)
- ✅ 신고 기능 구현 완료
- ✅ 위치 기반 거리 계산 기능 구현 완료
- ✅ 글씨 크기 설정 기능 구현 완료
- ✅ 언어 설정 구현 완료

### 현재 상태
- **코드베이스**: 약 27,000줄의 Dart 코드, 135개 파일
- **테스트 커버리지**: 거의 없음 (기본 widget_test.dart만 존재)
- **기술 부채**: 낮음 (대부분 해결됨)

---

## 🎯 우선순위별 다음 작업

### 🔴 우선순위 1: 높음 (즉시 진행 권장)

#### 1. 단위 테스트 커버리지 추가
**상태**: ❌ 미완료  
**예상 작업량**: 8-12시간  
**영향**: 높음 (코드 품질 및 유지보수성)

**작업 내용**:
- Repository 구현 테스트
  - `auth_repository_impl_test.dart`
  - `firestore_post_repository_test.dart`
  - `firestore_user_repository_test.dart`
  - `firestore_notification_repository_test.dart`
  - `parish_repository_impl_test.dart`
- State Notifiers 테스트
  - `post_form_notifier_test.dart`
- 유틸리티 함수 테스트
  - `date_utils_test.dart`
  - `location_utils_test.dart`
  - `validators_test.dart`
- Core 서비스 테스트
  - `geocoding_service_test.dart`
  - `image_upload_service_test.dart`
  - `localization_service_test.dart`

**권장 테스트 구조**:
```
test/
├── features/
│   ├── auth/
│   │   └── data/
│   │       └── repositories/
│   │           └── auth_repository_impl_test.dart
│   ├── community/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── firestore_post_repository_test.dart
│   │   └── presentation/
│   │       └── notifiers/
│   │           └── post_form_notifier_test.dart
│   └── parish/
│       └── data/
│           └── repositories/
│               └── parish_repository_impl_test.dart
├── core/
│   ├── data/
│   │   └── services/
│   │       ├── geocoding_service_test.dart
│   │       └── image_upload_service_test.dart
│   └── utils/
│       ├── date_utils_test.dart
│       └── location_utils_test.dart
└── shared/
    └── providers/
```

**필요한 패키지**:
- `mockito` 또는 `mocktail` (Mock 객체 생성)
- `fake_cloud_firestore` (Firestore Mock)

---

#### 2. 푸시 알림 서버 구현 (Firebase Cloud Functions) ✅ 완료
**상태**: ✅ 구현 완료  
**완료일**: 2025-01-XX  
**영향**: 중간 (자동 알림 전송 기능)

**구현 내용**:
- ✅ Cloud Functions에 푸시 알림 전송 함수 추가
  - ✅ 게시글 생성 시: 공지글인 경우 소속 성당 사용자에게 알림 전송 (작성자 제외)
  - ✅ 댓글 생성 시: 게시글 작성자에게 알림 전송 (댓글 작성자 자신 제외)
- ✅ FCM 토큰 관리 개선
  - ✅ 사용자별 토큰 저장 및 업데이트 (클라이언트 측에서 자동 처리)
  - ✅ 토큰 무효화 처리 (로그아웃 시)

**구현 파일**: `functions/src/index.ts`
- `onPostCreated`: 게시글 생성 시 알림 전송
- `onCommentCreated`: 댓글 생성 시 알림 전송

**참고 문서**: `docs/BACKEND_ARCHITECTURE.md` Phase 3

---

### 🟡 우선순위 2: 중간 (단기간 내 진행)

#### 3. 검색 기능 구현
**상태**: ❌ 미구현  
**예상 작업량**: 6-8시간  
**영향**: 중간 (사용자 경험 개선)

**작업 내용**:
- 게시글 검색 기능
  - 제목, 내용 검색
  - Firestore 기본 검색 또는 Algolia 통합 (선택)
- 성당 검색 개선
  - 현재는 이름만 검색, 주소/지역 검색 추가
- 검색 결과 필터링 및 정렬

**참고 문서**: `docs/BACKEND_ARCHITECTURE.md` Phase 3

---

#### 4. 관리자 대시보드 기능
**상태**: ⚠️ 기본 기능만 구현 (게시글 비표시)  
**예상 작업량**: 8-12시간  
**영향**: 중간 (운영 효율성)

**작업 내용**:
- 관리자 전용 화면 추가
  - 신고 목록 조회 및 처리
  - 게시글 관리 (비표시/표시, 삭제)
  - 사용자 관리
  - 통계 대시보드
- Firestore Rules에 관리자 권한 강화
- 관리자 인증 및 권한 체크

**참고 문서**: `docs/BACKEND_ARCHITECTURE.md` Phase 3

---

### 🟢 우선순위 3: 낮음 (장기 계획)

#### 5. 성능 최적화
**상태**: ❌ 미구현  
**예상 작업량**: 4-6시간  
**영향**: 중간 (사용자 경험)

**작업 내용**:
- 이미지 캐싱 전략 개선
  - `cached_network_image` 최적화
  - 이미지 압축 및 리사이징
- Firestore 쿼리 최적화
  - 인덱스 추가 및 쿼리 최적화
  - 페이지네이션 개선
- 앱 시작 시간 개선
  - 초기 로딩 최적화
  - Lazy loading 적용

**참고 문서**: `docs/BACKEND_ARCHITECTURE.md` Phase 4

---

#### 6. 모니터링 및 분석
**상태**: ❌ 미구현  
**예상 작업량**: 4-6시간  
**영향**: 중간 (운영 효율성)

**작업 내용**:
- Firebase Analytics 통합
  - 사용자 행동 추적
  - 화면 전환 추적
  - 이벤트 로깅
- Firebase Performance Monitoring
  - 앱 성능 모니터링
  - 네트워크 요청 추적
- Crashlytics 통합
  - 크래시 리포트 자동 수집

**참고 문서**: `docs/BACKEND_ARCHITECTURE.md` Phase 4

---

#### 7. 메신저/친구 기능
**상태**: ❌ 미구현 (QR 스캐너만 존재)  
**예상 작업량**: 20-30시간  
**영향**: 낮음 (새로운 기능)

**작업 내용**:
- 친구/연결 데이터 모델 설계
- 친구 요청 시스템
  - 친구 요청 전송/수락/거절
  - 친구 목록 관리
- 메신저 기능
  - 1:1 채팅
  - 메시지 전송/수신
  - 실시간 메시지 동기화

**참고 문서**: `docs/TODO.md` - 낮은 우선순위

**TODO 주석 위치**:
- `lib/features/profile/presentation/screens/qr_scanner_screen.dart:110`
- `lib/features/profile/presentation/screens/qr_scanner_screen.dart:150`

---

#### 8. 성경 읽기 화면 연결
**상태**: ❌ 미구현  
**예상 작업량**: 2-4시간  
**영향**: 낮음 (기능 완성도)

**작업 내용**:
- 성경 읽기 화면 구현
- `expandable_content_card.dart`에서 연결

**TODO 주석 위치**:
- `lib/shared/widgets/expandable_content_card.dart:99`

---

## 📊 작업 우선순위 매트릭스

| 작업 | 우선순위 | 예상 시간 | 영향 | 난이도 | 상태 |
|------|----------|-----------|------|--------|------|
| 단위 테스트 커버리지 추가 | 높음 | 8-12시간 | 높음 | 중간 | ❌ 미완료 |
| 푸시 알림 서버 구현 | 높음 | 4-6시간 | 중간 | 중간 | ✅ 완료 |
| 검색 기능 구현 | 중간 | 6-8시간 | 중간 | 중간 |
| 관리자 대시보드 | 중간 | 8-12시간 | 중간 | 높음 |
| 성능 최적화 | 낮음 | 4-6시간 | 중간 | 중간 |
| 모니터링 및 분석 | 낮음 | 4-6시간 | 중간 | 낮음 |
| 메신저/친구 기능 | 낮음 | 20-30시간 | 낮음 | 높음 |
| 성경 읽기 화면 | 낮음 | 2-4시간 | 낮음 | 낮음 |

---

## 🎯 권장 작업 순서

### Sprint 1 (2주)
1. **단위 테스트 커버리지 추가** (우선순위 1)
   - Repository 테스트부터 시작
   - 점진적으로 확장

### Sprint 2 (2주) ✅ 완료
2. **푸시 알림 서버 구현** (우선순위 1) ✅
   - ✅ Cloud Functions 구현 완료
   - ⏳ 테스트 및 배포 필요

### Sprint 3 (2주)
3. **검색 기능 구현** (우선순위 2)
   - 게시글 검색
   - 성당 검색 개선

### Sprint 4 (2주)
4. **관리자 대시보드** (우선순위 2)
   - 기본 화면 구현
   - 신고 관리 기능

### Sprint 5+ (장기)
5. 성능 최적화
6. 모니터링 및 분석
7. 메신저/친구 기능 (필요시)
8. 성경 읽기 화면

---

## 📝 참고 문서

- **아키텍처**: `docs/ARCHITECTURE.md`
- **리팩토링 가이드**: `docs/REFACTORING.md`
- **백엔드 아키텍처**: `docs/BACKEND_ARCHITECTURE.md`
- **TODO 추적**: `docs/TODO.md`
- **신고 기능 설정**: `docs/REPORT_FEATURE_SETUP.md`

---

## 🔄 이 문서 업데이트 방법

1. 작업 완료 시 해당 항목에 ✅ 표시
2. 예상 작업량과 실제 작업량 비교 기록
3. 새로운 작업 항목 발견 시 추가
4. 우선순위 변경 시 매트릭스 업데이트
