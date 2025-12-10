# Credo 백엔드 아키텍처 제안서

## 현재 상태 분석

### 사용 중인 서비스
- ✅ Firebase Authentication (이메일, Google, Apple)
- ✅ Cloud Firestore (사용자 데이터)
- ✅ Firebase Storage (이미지 저장)
- ✅ Firebase Cloud Messaging (푸시 알림)
- 📦 로컬 JSON 파일 (교회 데이터)

### 주요 기능
1. **인증**: 사용자 로그인/회원가입
2. **교회 정보**: 교회 검색, 상세 정보, 미사 시간
3. **커뮤니티**: 게시글, 댓글, 좋아요, 신고
4. **프로필**: 사용자 정보 관리
5. **알림**: 푸시 알림

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
│ Firebase     │  │ Algolia      │  │ Cloud       │
│ Storage      │  │ (선택사항)   │  │ Scheduler   │
│              │  │              │  │ (선택사항)  │
│ - 이미지     │  │ - 고급 검색  │  │ - 스케줄    │
│ - 파일       │  │              │  │   작업      │
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

#### 3. `posts` (게시글)
```typescript
{
  postId: string,
  parishId: string,
  authorId: string,
  title: string,
  content: string,
  images?: string[], // Storage URLs
  likeCount: number,
  commentCount: number,
  isPinned: boolean,
  isOfficial: boolean, // 공식 게시글
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 4. `comments` (댓글)
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

#### 5. `postLikes` (게시글 좋아요)
```typescript
{
  postId: string,
  userId: string,
  createdAt: Timestamp
}
// Composite index: (postId, userId)
```

#### 6. `reports` (신고)
```typescript
{
  reportId: string,
  type: 'post' | 'comment',
  targetId: string,
  reporterId: string,
  reason: string,
  description?: string,
  status: 'pending' | 'reviewed' | 'resolved',
  createdAt: Timestamp
}
```

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

#### 5. **푸시 알림 전송**
```typescript
exports.sendNotification = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const post = snap.data();
    
    // 교회 구독자에게 알림 전송
    const subscribers = await firestore
      .collection('users')
      .where('favoriteParishIds', 'array-contains', post.parishId)
      .get();
    
    const messages = subscribers.docs.map(doc => ({
      token: doc.data().fcmToken,
      notification: {
        title: post.title,
        body: post.content.substring(0, 100)
      }
    }));
    
    await admin.messaging().sendAll(messages);
  });
```

#### 6. **교회 데이터 동기화 (선택사항)**
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
      allow update, delete: if request.auth != null 
        && (resource.data.authorId == request.auth.uid 
            || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
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
  }
}
```

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

### Phase 1: 기본 인프라 (1-2주)
- [ ] Firestore Collections 생성
- [ ] Security Rules 설정
- [ ] 기본 Cloud Functions 구현
- [ ] 교회 데이터 Firestore 마이그레이션

### Phase 2: 커뮤니티 기능 (2-3주)
- [ ] 게시글 CRUD 구현
- [ ] 댓글 시스템 구현
- [ ] 좋아요 기능 구현
- [ ] 실시간 업데이트 적용

### Phase 3: 고급 기능 (2-3주)
- [ ] 푸시 알림 설정
- [ ] 검색 기능 (Algolia 또는 Firestore 검색)
- [ ] 신고 시스템
- [ ] 관리자 기능

### Phase 4: 최적화 (1-2주)
- [ ] 인덱스 최적화
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

