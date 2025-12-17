# 푸시 알림 서버 구현 가이드

이 문서는 Firebase Cloud Functions를 사용한 푸시 알림 서버 구현 및 배포 방법을 안내합니다.

**구현 완료일**: 2025-12-15  
**마지막 업데이트**: 2025-12-16

---

## 개요

푸시 알림 서버는 다음과 같이 동작합니다:

1. **게시글 생성 시**: 공지글(`type == "official" && category == "notice"`)인 경우, 해당 성당에 소속된 사용자에게 알림 전송 (작성자 제외)
2. **댓글 생성 시**: 게시글 작성자에게 알림 전송 (댓글 작성자 자신 제외)

---

## 구현 내용

### 0. Firebase Admin SDK 초기화

**중요**: Cloud Functions에서 Firebase Admin SDK를 사용하기 전에 반드시 초기화해야 합니다.

```typescript
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

// Firebase Admin SDK 초기화
initializeApp();
```

이 초기화가 없으면 `The default Firebase app does not exist` 에러가 발생합니다.

### 1. 게시글 생성 시 알림 전송 (`onPostCreated`)

**트리거**: `posts/{postId}` 문서 생성 시

**동작**:
- 게시글 생성 이벤트 로그 출력
- 공지글인지 확인 (`type === "official" && category === "notice"`)
- `parishId`가 있는지 확인
- 해당 성당에 소속된 사용자 조회 (`main_parish_id == parishId`)
- 작성자를 제외한 사용자 중 FCM 토큰이 있는 사용자에게 알림 전송
- FCM 토큰 통계 로그 출력 (토큰 있음/없음 사용자 수)
- 최대 500개씩 배치로 전송

**알림 데이터**:
```typescript
{
  notification: {
    title: post.title,
    body: post.body.substring(0, 100) + "..."
  },
  data: {
    postId: string,
    parishId: string,
    type: "official_notice"
  }
}
```

### 2. 댓글 생성 시 알림 전송 (`onCommentCreated`)

**트리거**: `comments/{commentId}` 문서 생성 시

**동작**:
- 댓글 생성 이벤트 로그 출력
- 게시글 정보 가져오기
- 게시글 정보 로그 출력 (`postId`, `postAuthorId`, `postParishId`)
- 댓글 작성자가 게시글 작성자와 다른지 확인
- 게시글 작성자 정보 및 FCM 토큰 존재 여부 로그 출력
- 게시글 작성자의 FCM 토큰 확인
- 알림 전송

**알림 데이터**:
```typescript
{
  notification: {
    title: "新しいコメント",
    body: `${commentAuthorName}: ${commentContent.substring(0, 50)}...`
  },
  data: {
    postId: string,
    parishId: string,
    type: "comment",
    commentId: string
  }
}
```

---

## 배포 방법

### 1. TypeScript 컴파일

```bash
cd functions
npm run build
```

### 2. Firebase Functions 배포

```bash
# 프로젝트 루트에서
firebase deploy --only functions
```

또는

```bash
cd functions
npm run deploy
```

### 3. 배포 확인

```bash
firebase functions:log
```

---

## 테스트 방법

### 1. 게시글 알림 테스트

1. Flutter 앱에서 공지글 작성 (`type: "official"`, `category: "notice"`)
2. 해당 성당에 소속된 다른 사용자 계정으로 로그인
3. 알림 수신 확인
4. Cloud Functions 로그 확인:
   ```bash
   firebase functions:log --only onPostCreated
   ```

### 2. 댓글 알림 테스트

1. Flutter 앱에서 게시글 작성
2. 다른 사용자 계정으로 로그인하여 댓글 작성
3. 게시글 작성자 계정에서 알림 수신 확인
4. Cloud Functions 로그 확인:
   ```bash
   firebase functions:log --only onCommentCreated
   ```

---

## 문제 해결

### 알림이 전송되지 않는 경우

1. **FCM 토큰 확인**:
   - Firestore Console에서 `users/{userId}` 문서의 `fcmToken` 필드 확인
   - 토큰이 없으면 다음을 확인:
     - 클라이언트 앱에서 로그인 후 토큰이 자동 저장되는지 확인
     - 앱을 재시작하거나 다시 로그인하여 토큰 저장 확인
     - **중요**: iOS 시뮬레이터에서는 FCM 토큰을 받을 수 없습니다. 실제 기기에서 테스트해야 합니다.
     - Android 에뮬레이터는 Google Play Services가 설치된 경우에만 가능합니다.

2. **Cloud Functions 로그 확인**:
   ```bash
   firebase functions:log
   ```
   - 에러 메시지 확인
   - 알림 전송 성공/실패 개수 확인

3. **Firestore 인덱스 확인**:
   - `users` 컬렉션에서 `main_parish_id` 필드로 쿼리하는 경우 인덱스 필요
   - Firebase Console에서 인덱스 생성 제안 확인

### 알림이 중복 전송되는 경우

- 작성자 제외 로직이 제대로 작동하는지 확인
- Cloud Functions가 중복 실행되지 않는지 확인 (트리거가 여러 번 발생하는 경우)

### 알림 데이터가 올바르지 않은 경우

- Post/Comment 모델의 필드명 확인 (`title`, `body`, `content` 등)
- Firestore 문서 구조 확인

---

## 클라이언트 측 FCM 토큰 관리

### 자동 저장 로직

클라이언트 앱에서 FCM 토큰은 다음 경우에 자동으로 Firestore에 저장됩니다:

1. **앱 초기화 시**: `PushNotificationService.initialize()` 호출 시 토큰을 가져온 후, 현재 로그인된 사용자가 있으면 자동 저장
2. **로그인 시**: `authStateProvider`를 감시하여 사용자가 로그인하면 자동으로 `saveTokenForUser()` 호출
3. **토큰 갱신 시**: `onTokenRefresh` 리스너에서 토큰이 갱신되면 자동 저장

**구현 위치**: `lib/main.dart`, `lib/core/data/services/push_notification_service.dart`

### 수동 저장

필요한 경우 수동으로 토큰을 저장할 수 있습니다:

```dart
await PushNotificationService().saveTokenForUser(userId);
```

## 코드 위치

- **서버 구현 파일**: `functions/src/index.ts`
- **함수명**:
  - `onPostCreated`: 게시글 생성 시 알림 전송
  - `onCommentCreated`: 댓글 생성 시 알림 전송
- **클라이언트 구현 파일**: `lib/core/data/services/push_notification_service.dart`
- **인증 상태 감시**: `lib/main.dart` (CredoApp 위젯)

---

## 향후 개선 사항

- [ ] 좋아요 알림 (선택사항)
- [ ] 알림 설정 (사용자가 알림 수신 여부 선택)
- [ ] 알림 히스토리 저장
- [ ] 알림 클릭 통계
- [ ] 배치 알림 전송 최적화

---

## 참고 문서

- **백엔드 아키텍처**: `docs/BACKEND_ARCHITECTURE.md`
- **클라이언트 푸시 알림 서비스**: `lib/core/data/services/push_notification_service.dart`
- **Firebase Cloud Functions 문서**: https://firebase.google.com/docs/functions
