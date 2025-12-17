# Credo 백엔드 아키텍처 제안서

**마지막 업데이트**: 2025-12-16

## 현재 상태 분석

### 사용 중인 서비스
- ✅ Firebase Authentication (이메일, Google, Apple) - **구현 완료**
- ✅ Cloud Firestore (사용자 데이터, 게시글, 댓글, 알림) - **구현 완료**
- ✅ Firebase Storage (이미지 저장) - **구현 완료**
- ✅ Firebase Cloud Messaging (푸시 알림) - **구현 완료**
  - `PushNotificationService` 구현 완료
  - 알림 탭 시 게시글 상세 화면 네비게이션 구현
  - 사용자 FCM 토큰 관리 구현
- ✅ Google Maps Geocoding API - **구현 완료**
  - `GeocodingService` 구현 완료
  - 주소를 좌표로 변환 (교회 위치 계산)
  - 환경 변수로 API 키 관리 (`.env` 파일)
- 📦 로컬 JSON 파일 (교회 데이터) - 현재 사용 중

### 주요 기능
1. **인증**: 사용자 로그인/회원가입 - **구현 완료**
2. **교회 정보**: 교회 검색, 상세 정보, 미사 시간 - **구현 완료** (로컬 JSON 사용)
   - 위치 기반 거리 계산 구현 완료
   - 거리순 정렬 기능 구현 완료 (버그 수정 완료)
     - `FutureProvider` 접근 방식 수정 (`ref.read` → `ref.watch`)
     - 기본값을 `false`로 변경 (사용자가 명시적으로 활성화)
     - 위치 정보 가져오기 로직 개선
   - Google Maps 연동 (지도 앱으로 열기)
3. **커뮤니티**: 게시글, 댓글, 좋아요 - **구현 완료**
   - 게시글 CRUD 구현 완료
   - 댓글 시스템 구현 완료 (`commentCount` 자동 업데이트)
   - 좋아요 기능 구현 완료
   - 이미지 업로드 및 갤러리 뷰어 구현 완료
   - 공식 공지 vs 커뮤니티 게시글 구분 구현 완료
4. **프로필**: 사용자 정보 관리 - **구현 완료**
5. **알림**: 푸시 알림 - **구현 완료**
   - FCM 토큰 관리 구현 완료
   - 알림 네비게이션 구현 완료
6. **위치 서비스**: 위치 기반 기능 - **구현 완료**
   - 사용자 현재 위치 가져오기 (Geolocator)
   - 교회 주소를 좌표로 변환 (Google Maps Geocoding API)
   - 거리 계산 및 표시 (Haversine 공식)
   - 위치 권한 요청 기능

---

## 추천 아키텍처: Firebase 중심 하이브리드 구조

### 🎯 추천 이유
1. **이미 Firebase 인프라 구축됨** - 추가 비용 최소화
2. **빠른 개발 속도** - 서버리스 아키텍처
3. **자동 스케일링** - 트래픽 증가에 자동 대응
4. **실시간 동기화** - Firestore의 실시간 기능 활용
5. **비용 효율적** - 사용량 기반 과금

---

## 아키텍처 구조

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Firebase     │  │ Cloud        │  │ Firebase     │
│ Auth         │  │ Firestore    │  │ Functions    │
│              │  │              │  │              │
│ - 이메일     │  │ - 사용자     │  │ - 백그라운드 │
│ - Google     │  │ - 게시글     │  │   작업       │
│ - Apple      │  │ - 댓글       │  │ - 알림       │
│              │  │ - 교회 정보  │  │ - 검색       │
└──────────────┘  └──────────────┘  └──────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Firebase     │  │ Google Maps  │  │ Algolia      │
│ Storage      │  │ Geocoding    │  │ (선택사항)   │
│              │  │ API          │  │              │
│ - 이미지     │  │              │  │ - 고급 검색  │
│ - 파일       │  │ - 주소→좌표  │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## 데이터베이스 구조 (Firestore)

### Collections

#### 1. `users` (사용자)
```typescript
{
  userId: string,
  email: string,
  nickname: string,
  profileImageUrl?: string,
  mainParishId?: string,
  favoriteParishIds: string[],
  preferredLanguages: string[],
  createdAt: Timestamp,
  updatedAt: Timestamp,
  lastLoginAt: Timestamp
}
```

#### 2. `parishes` (교회)
```typescript
{
  parishId: string, // "diocese-name"
  name: string,
  diocese: string,
  address: string,
  prefecture: string,
  phone?: string,
  latitude: number,
  longitude: number,
  officialSite?: string,
  massTimes: MassTime[],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 3. `posts` (게시글) ✅ 구현 완료
```typescript
{
  postId: string,
  parishId: string,
  authorId: string,
  authorName: string,
  title: string,
  content: string,
  imageUrls?: string[], // Storage URLs
  likeCount: number,
  commentCount: number, // 댓글 생성 시 자동 업데이트
  isPinned: boolean,
  isOfficial: boolean, // 공식 게시글
  category: string,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```
**구현 현황**:
- 게시글 CRUD 구현 완료
- 이미지 업로드 및 다중 이미지 지원
- 공식 공지/커뮤니티 게시글 구분
- 핀 고정 기능
- 댓글 수 자동 업데이트 (댓글 생성 시 Firestore transaction 사용)
- 좋아요 기능

#### 4. `comments` (댓글) ✅ 구현 완료
```typescript
{
  commentId: string,
  postId: string,
  authorId: string,
  content: string,
  likeCount: number,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```
**구현 현황**:
- 댓글 생성/조회 구현 완료
- 게시글의 `commentCount` 필드에 댓글 생성 시 자동 증가 (Firestore transaction 사용)

#### 5. `postLikes` (게시글 좋아요) ✅ 구현 완료
```typescript
{
  postId: string,
  userId: string,
  createdAt: Timestamp
}
// Composite index: (postId, userId)
```
**구현 현황**:
- 좋아요 토글 기능 구현 완료
- 게시글의 `likeCount` 필드와 동기화

#### 6. `reports` (신고) ✅ 구현 완료
```typescript
{
  targetType: "post" | "comment" | "user",
  targetId: string,
  reason: string,
  reporterId: string,
  createdAt: Timestamp
}
```
**구현 현황**:
- 신고 모델 및 리포지토리 구현 완료
- 게시글/댓글 신고 버튼 UI 구현 완료
- 중복 신고 방지 로직 구현 (5분 내 동일 대상 신고 방지)
- Cloud Functions onCreate 트리거로 Slack 알림 전송 구현 완료
- Firestore Rules에 reports 컬렉션 규칙 추가 완료

---

## Firebase Cloud Functions

### 필수 Functions

#### 1. **사용자 생성 시 프로필 초기화**
```typescript
// onCreate trigger
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  await firestore.collection('users').doc(user.uid).set({
    userId: user.uid,
    email: user.email,
    nickname: user.displayName || 'ユーザー',
    favoriteParishIds: [],
    preferredLanguages: ['ja'],
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
});
```

#### 2. **게시글 작성 시 통계 업데이트**
```typescript
// onCreate trigger
exports.onPostCreate = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const post = snap.data();
    // 교회별 게시글 수 증가
    await firestore.collection('parishes')
      .doc(post.parishId)
      .update({
        postCount: FieldValue.increment(1)
      });
  });
```

#### 3. **댓글 작성 시 게시글 댓글 수 업데이트**
```typescript
exports.onCommentCreate = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    await firestore.collection('posts')
      .doc(comment.postId)
      .update({
        commentCount: FieldValue.increment(1)
      });
  });
```

#### 4. **좋아요 처리**
```typescript
exports.togglePostLike = functions.https.onCall(async (data, context) => {
  const { postId } = data;
  const userId = context.auth.uid;
  
  const likeRef = firestore
    .collection('postLikes')
    .doc(`${postId}_${userId}`);
  
  const likeDoc = await likeRef.get();
  
  if (likeDoc.exists) {
    // 좋아요 취소
    await likeRef.delete();
    await firestore.collection('posts').doc(postId).update({
      likeCount: FieldValue.increment(-1)
    });
  } else {
    // 좋아요 추가
    await likeRef.set({
      postId,
      userId,
      createdAt: FieldValue.serverTimestamp()
    });
    await firestore.collection('posts').doc(postId).update({
      likeCount: FieldValue.increment(1)
    });
  }
});
```

#### 5. **신고 알림 전송 및 자동 숨김 처리** ✅ 구현 완료
```typescript
exports.onReportCreated = functions.firestore
  .document('reports/{reportId}')
  .onCreate(async (snap, context) => {
    const report = snap.data();
    
    // Slack Incoming Webhook으로 알림 전송
    const webhookUrl = process.env.SLACK_WEBHOOK_URL;
    
    const slackMessage = {
      text: "🚨 새로운 신고가 접수되었습니다",
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "🚨 새로운 신고가 접수되었습니다",
            emoji: true,
          },
        },
        {
          type: "section",
          fields: [
            { type: "mrkdwn", text: `*신고 ID:*\n${reportId}` },
            { type: "mrkdwn", text: `*신고 유형:*\n${targetTypeDisplay}` },
            { type: "mrkdwn", text: `*대상 ID:*\n${targetId}` },
            { type: "mrkdwn", text: `*신고 사유:*\n${reason}` },
            { type: "mrkdwn", text: `*신고자 ID:*\n${reporterId}` },
            { type: "mrkdwn", text: `*신고 시간:*\n${createdAt}` },
          ],
        },
      ],
    };
    
    await fetch(webhookUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(slackMessage),
    });
    
    // 게시글 신고인 경우 자동 숨김 처리 (신고 3개 이상)
    if (targetType === "post") {
      const reportsSnapshot = await db
        .collection("reports")
        .where("targetType", "==", "post")
        .where("targetId", "==", targetId)
        .get();
      
      const reportCount = reportsSnapshot.size;
      const HIDE_THRESHOLD = 3;
      
      if (reportCount >= HIDE_THRESHOLD) {
        const postRef = db.collection("posts").doc(targetId);
        const postDoc = await postRef.get();
        
        if (postDoc.exists) {
          const postData = postDoc.data();
          const currentStatus = postData?.status || "published";
          
          if (currentStatus === "published") {
            await postRef.update({
              status: "hidden",
              updatedAt: new Date(),
            });
          }
        }
      }
    }
  });
```
**구현 현황**:
- ✅ Cloud Functions v2 `onDocumentCreated` 트리거 구현 완료
- ✅ Slack Incoming Webhook 연동 완료
- ✅ 신고 정보 포맷팅 및 전송 완료
- ✅ 환경 변수 관리: `functions/.env` 파일에 dotenv로 설정, `functions/.gitignore`에 포함
- ✅ dotenv 패키지 추가 및 `functions/src/index.ts`에서 자동 로드
- ✅ 게시글 자동 숨김 처리: 신고 3개 이상 시 자동으로 `status`를 "hidden"으로 변경

#### 6. **푸시 알림 전송** ✅ 구현 완료
```typescript
// 게시글 생성 시 알림 전송
export const onPostCreated = onDocumentCreated(
  "posts/{postId}",
  async (event) => {
    // 공지글(type == "official" && category == "notice")인 경우
    // 해당 성당에 소속된 사용자에게 알림 전송 (작성자 제외)
  }
);

// 댓글 생성 시 알림 전송
export const onCommentCreated = onDocumentCreated(
  "comments/{commentId}",
  async (event) => {
    // 게시글 작성자에게 알림 전송 (댓글 작성자 자신 제외)
  }
);
```
**현재 구현 상태**:
- ✅ 클라이언트 측 `PushNotificationService` 구현 완료 (`lib/core/data/services/push_notification_service.dart`)
- ✅ FCM 토큰 관리 구현 완료
  - 앱 초기화 시 토큰 자동 저장
  - 로그인 시 `authStateProvider`를 통한 토큰 자동 저장 (`lib/main.dart`)
  - 토큰 갱신 시 자동 저장
- ✅ 알림 수신 및 네비게이션 구현 완료 (알림 탭 시 게시글 상세 화면으로 이동)
- ✅ Firebase Cloud Functions를 통한 자동 알림 전송 구현 완료
  - Firebase Admin SDK 초기화 추가 (`initializeApp()`)
  - 게시글 생성 시: 공지글인 경우 소속 성당 사용자에게 알림 전송 (작성자 제외)
  - 댓글 생성 시: 게시글 작성자에게 알림 전송 (댓글 작성자 자신 제외)
  - 디버깅 로그 추가 (게시글/댓글 생성 이벤트, FCM 토큰 통계 등)

#### 7. **교회 데이터 동기화 (선택사항)**
```typescript
// 주기적으로 로컬 JSON을 Firestore에 동기화
exports.syncParishData = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    // JSON 파일 읽기 및 Firestore 업데이트
  });
```

---

## 보안 규칙 (Firestore Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function: 관리자 여부 확인
    function isAdmin() {
      return request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Helper function: 관리자가 자신의 교회 게시글인지 확인
    function isAdminOfPostParish() {
      let adminUser = get(/databases/$(database)/documents/users/$(request.auth.uid));
      let adminParishId = adminUser.data.main_parish_id;
      let postParishId = resource.data.parishId;
      return adminParishId is string
        && adminParishId != ''
        && postParishId is string
        && postParishId != ''
        && adminParishId == postParishId;
    }
    
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Posts
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null 
        && request.resource.data.authorId == request.auth.uid;
      // update: 작성자는 모든 필드 수정 가능
      // 다른 사용자는 likeCount 또는 commentCount만 수정 가능
      // 관리자는 자신이 소속된 교회의 게시글만 status 수정 가능
      allow update: if request.auth != null
        && (resource.data.authorId == request.auth.uid ||
            (request.resource.data.diff(resource.data).affectedKeys()
                .hasOnly(['likeCount', 'updatedAt'])) ||
            (request.resource.data.diff(resource.data).affectedKeys()
                .hasOnly(['commentCount', 'updatedAt'])) ||
            (isAdmin()
                && isAdminOfPostParish()
                && request.resource.data.diff(resource.data).affectedKeys()
                    .hasOnly(['status', 'updatedAt'])));
      allow delete: if request.auth != null 
        && resource.data.authorId == request.auth.uid;
    }
    
    // Comments
    match /comments/{commentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null 
        && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if request.auth != null 
        && resource.data.authorId == request.auth.uid;
    }
    
    // Post Likes
    match /postLikes/{likeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null 
        && request.resource.data.userId == request.auth.uid;
      allow delete: if request.auth != null 
        && resource.data.userId == request.auth.uid;
    }
    
    // Reports
    match /reports/{reportId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null 
        && request.resource.data.reporterId == request.auth.uid
        && request.resource.data.targetType is string
        && request.resource.data.targetId is string
        && request.resource.data.reason is string
        && request.resource.data.createdAt is timestamp;
      allow update, delete: if false;
    }
  }
}
```

**주요 변경사항**:
- ✅ `isAdmin()` helper function 추가: 관리자 권한 확인
- ✅ `isAdminOfPostParish()` helper function 추가: 관리자가 자신의 교회 게시글인지 확인
- ✅ Posts update 규칙: 관리자는 자신이 소속된 교회의 게시글만 `status`와 `updatedAt` 수정 가능
- ✅ `commentCount` 업데이트 규칙 추가: 다른 사용자가 댓글 수만 수정 가능

---

## 대안 아키텍처 옵션

### 옵션 1: 완전 Firebase (현재 추천) ⭐
**장점:**
- 빠른 개발 속도
- 서버 관리 불필요
- 자동 스케일링
- 실시간 동기화

**단점:**
- 복잡한 쿼리 제한
- 비용이 사용량에 따라 증가
- 벤더 종속성

**비용 예상:** 월 $50-200 (초기 단계)

---

### 옵션 2: Firebase + Node.js/Express API
**구조:**
- Firebase Auth (인증)
- Node.js API 서버 (비즈니스 로직)
- PostgreSQL/MongoDB (데이터베이스)
- Firebase Storage (파일 저장)

**장점:**
- 더 복잡한 비즈니스 로직 구현 가능
- 데이터베이스 선택의 자유
- 더 나은 쿼리 성능

**단점:**
- 서버 관리 필요
- 더 높은 개발 비용
- 스케일링 설정 필요

**비용 예상:** 월 $100-500 (서버 호스팅 포함)

---

### 옵션 3: Supabase
**구조:**
- Supabase Auth
- PostgreSQL (실시간)
- Supabase Storage
- Edge Functions

**장점:**
- 오픈소스
- PostgreSQL의 강력한 기능
- Firebase와 유사한 DX

**단점:**
- 마이그레이션 필요
- 커뮤니티가 Firebase보다 작음

---

## 구현 단계별 로드맵

### Phase 1: 기본 인프라 ✅ 완료
- [x] Firestore Collections 생성
- [x] Security Rules 설정
- [x] 기본 Cloud Functions 구현 (클라이언트 측 로직으로 대체)
- [ ] 교회 데이터 Firestore 마이그레이션 (현재 로컬 JSON 사용 중)

### Phase 2: 커뮤니티 기능 ✅ 완료
- [x] 게시글 CRUD 구현
- [x] 댓글 시스템 구현 (commentCount 자동 업데이트 포함)
- [x] 좋아요 기능 구현
- [x] 실시간 업데이트 적용 (StreamProvider 사용)
- [x] 이미지 업로드 및 갤러리 뷰어 구현

### Phase 3: 고급 기능 🔄 진행 중
- [x] 푸시 알림 클라이언트 구현 (FCM 토큰 관리, 알림 수신, 네비게이션)
- [x] 위치 기반 기능 구현 (사용자 위치, 거리 계산, Google Maps 연동)
  - 사용자 현재 위치 가져오기 (Geolocator)
  - 교회 주소를 좌표로 변환 (Google Maps Geocoding API)
  - 거리 계산 및 표시
  - 위치 권한 요청 기능
  - Google Maps 앱으로 교회 위치 열기
- [x] 신고 시스템 구현 완료
  - 신고 모델 및 리포지토리 구현
  - 게시글/댓글 신고 버튼 UI 구현
  - 중복 신고 방지 로직 (5분 내 동일 대상 신고 방지)
  - Cloud Functions onCreate 트리거로 Slack 알림 전송
  - Firestore Rules에 reports 컬렉션 규칙 추가
- [x] 푸시 알림 서버 구현 완료 (Firebase Cloud Functions를 통한 자동 알림 전송)
  - 게시글 생성 시: 공지글인 경우 소속 성당 사용자에게 알림 전송 (작성자 제외)
  - 댓글 생성 시: 게시글 작성자에게 알림 전송 (댓글 작성자 자신 제외)
  - Firebase Admin SDK 초기화 및 FCM 토큰 관리
- [ ] 검색 기능 (Algolia 또는 Firestore 검색)
- [ ] 관리자 기능

### Phase 4: 최적화 🔄 진행 중
- [x] 인덱스 최적화 (복합 인덱스 설정 완료)
- [ ] 캐싱 전략
- [ ] 성능 모니터링
- [ ] 비용 최적화

---

## 비용 예상

### Firebase 무료 티어
- Firestore: 50K 읽기/일, 20K 쓰기/일
- Storage: 5GB 저장, 1GB/일 다운로드
- Functions: 125K 호출/월
- Auth: 무제한

### 예상 월 비용 (1,000명 사용자 기준)
- Firestore: $0-25
- Storage: $0-5
- Functions: $0-10
- **총계: $0-40/월**

### 예상 월 비용 (10,000명 사용자 기준)
- Firestore: $50-150
- Storage: $10-30
- Functions: $20-50
- **총계: $80-230/월**

---

## 권장 사항

### ✅ 즉시 구현
1. **Firestore로 교회 데이터 마이그레이션**
   - 현재 로컬 JSON → Firestore로 이동
   - 실시간 업데이트 가능

2. **커뮤니티 기능 구현**
   - 게시글, 댓글, 좋아요
   - Firestore의 실시간 기능 활용

3. **기본 Cloud Functions**
   - 사용자 생성 시 프로필 초기화
   - 통계 업데이트

### 🔄 단계적 구현
1. **검색 기능**
   - 초기: Firestore 기본 검색
   - 후기: Algolia 통합 (필요시)

2. **고급 알림**
   - 주제별 구독
   - 개인화된 알림

3. **분석 및 모니터링**
   - Firebase Analytics
   - Performance Monitoring

---

## 결론

**추천: Firebase 중심 하이브리드 구조**

현재 Firebase 인프라가 구축되어 있고, 앱의 요구사항이 Firebase의 강점과 잘 맞습니다:
- ✅ 실시간 커뮤니티 기능
- ✅ 사용자 인증
- ✅ 파일 저장
- ✅ 푸시 알림

Firebase만으로도 충분히 구현 가능하며, 필요시 Node.js API 서버를 추가할 수 있습니다.

