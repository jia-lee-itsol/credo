# Firestore 샘플 데이터 생성 가이드

## 방법 1: Dart 스크립트 실행 (권장)

### 준비사항
1. Firebase 프로젝트가 초기화되어 있어야 합니다
2. `firebase_options.dart` 파일이 있어야 합니다

### 실행 방법
```bash
# 프로젝트 루트에서 실행
dart run scripts/create_sample_posts.dart
```

### 주의사항
- 스크립트의 `authorId`를 현재 로그인한 사용자의 UID로 변경해야 할 수 있습니다
- Firestore 보안 규칙에 따라 로그인한 사용자만 데이터를 생성할 수 있습니다

---

## 방법 2: Firebase Console에서 수동 생성

### 단계별 가이드

1. **Firebase Console 접속**
   - https://console.firebase.google.com
   - 프로젝트 "credo" 선택

2. **Firestore Database로 이동**
   - 왼쪽 메뉴: "Firestore Database" 클릭
   - "데이터" 탭 선택

3. **컬렉션 생성**
   - `+ 컬렉션 시작` 버튼 클릭
   - 컬렉션 ID: `posts` 입력
   - "다음" 클릭

4. **첫 번째 문서 생성**
   - 문서 ID: `sample-post-1` (또는 자동 생성)
   - 필드 추가:

   ```
   필드 이름: postId
   타입: string
   값: sample-post-1
   ```

   ```
   필드 이름: authorId
   타입: string
   값: C8V7SJaUbGfBZDxMExthGTDU8tJ2 (현재 사용자 UID)
   ```

   ```
   필드 이름: authorName
   타입: string
   값: 東京カテドラル
   ```

   ```
   필드 이름: authorRole
   타입: string
   값: staff
   ```

   ```
   필드 이름: authorIsVerified
   타입: boolean
   값: true
   ```

   ```
   필드 이름: category
   타입: string
   값: notice
   ```

   ```
   필드 이름: type
   타입: string
   값: official
   ```

   ```
   필드 이름: title
   타입: string
   값: 【お知らせ】年末年始のミサ時間について
   ```

   ```
   필드 이름: body
   타입: string
   값: 年末年始のミサ時間をお知らせいたします。12月31日は18時から、1月1日は10時からとなります。皆様のご参列をお待ちしております。
   ```

   ```
   필드 이름: createdAt
   타입: timestamp
   값: [현재 시간]
   ```

   ```
   필드 이름: updatedAt
   타입: timestamp
   값: [현재 시간]
   ```

   ```
   필드 이름: status
   타입: string
   값: published
   ```

5. **저장**
   - "저장" 버튼 클릭

---

## 샘플 데이터 구조

### 공식 공지사항 (Official Notice)
```json
{
  "postId": "sample-post-1",
  "authorId": "사용자UID",
  "authorName": "東京カテドラル",
  "authorRole": "staff",
  "authorIsVerified": true,
  "category": "notice",
  "type": "official",
  "title": "【お知らせ】年末年始のミサ時間について",
  "body": "年末年始のミサ時間をお知らせいたします...",
  "createdAt": "2025-12-10T18:00:00Z",
  "updatedAt": "2025-12-10T18:00:00Z",
  "status": "published"
}
```

### 커뮤니티 게시글 (Community Post)
```json
{
  "postId": "sample-post-3",
  "authorId": "사용자UID",
  "authorName": "マリア",
  "authorRole": "user",
  "authorIsVerified": false,
  "category": "community",
  "type": "normal",
  "title": "先週のミサで感動しました",
  "body": "先週日曜日のミサに初めて参加しました...",
  "createdAt": "2025-12-10T12:00:00Z",
  "updatedAt": "2025-12-10T12:00:00Z",
  "status": "published"
}
```

---

## 문제 해결

### 컬렉션이 생성되지 않는 경우
1. **Firestore 보안 규칙 확인**
   - `firestore.rules` 파일 확인
   - 로그인한 사용자만 생성 가능한지 확인

2. **권한 확인**
   - 앱에서 로그인되어 있는지 확인
   - `authorId`가 현재 로그인한 사용자의 UID와 일치하는지 확인

3. **에러 로그 확인**
   - 앱의 콘솔 로그 확인
   - Firebase Console의 "모니터링" 섹션 확인

### 데이터가 보이지 않는 경우
1. **쿼리 조건 확인**
   - `category == "community"`
   - `type == "normal"`
   - `status == "published"`
   - 모든 조건이 일치해야 합니다

2. **인덱스 확인**
   - 복합 쿼리 사용 시 Firestore 인덱스가 필요할 수 있습니다
   - Firebase Console에서 인덱스 생성 링크가 표시됩니다
