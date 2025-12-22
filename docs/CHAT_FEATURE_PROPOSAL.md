# 채팅 기능 구현 제안서

## 개요
사용자 간 1:1 채팅 및 그룹 채팅 기능을 추가하여 앱 내에서 실시간 메시지 교환을 가능하게 합니다.

## 기능 요구사항

### 1. 핵심 기능
- ✅ **1:1 채팅**: 두 사용자 간 개인 메시지
- ✅ **그룹 채팅**: 여러 사용자와의 그룹 대화
- ✅ **실시간 메시지 동기화**: Firestore Stream을 통한 실시간 업데이트
- ✅ **읽음 상태 표시**: 메시지 읽음/안 읽음 상태 표시
- ✅ **이미지 전송**: 채팅에서 이미지 공유 (갤러리/카메라)
- ✅ **푸시 알림**: 새 메시지 수신 시 FCM 알림

### 2. UI/UX 기능
- ✅ **채팅 목록 화면**: 대화 목록 (최신 메시지 미리보기)
- ✅ **채팅 화면**: 메시지 입력 및 표시
- ✅ **사용자 검색**: 채팅 시작을 위한 사용자 검색
- ✅ **읽음 표시**: 메시지 읽음 상태 표시
- ✅ **타이핑 인디케이터**: 상대방이 입력 중임을 표시

### 3. 친구 시스템 ✅
- ✅ **친구 추가/삭제**: 친구 관계 관리
- ✅ **친구 차단**: 특정 사용자 차단
- ✅ **QR 코드 친구 추가**: QR 스캔으로 친구 추가
- ✅ **친구에게만 메시지 전송**: 친구 관계가 있는 사용자만 메시지 전송 가능
- ✅ **친구 검색**: 닉네임, 아이디, 이메일로 친구 검색

### 4. 채팅방 관리 ✅
- ✅ **채팅방 정보 화면**: 참여자 목록 및 채팅방 정보 표시
- ✅ **멤버 초대**: 1:1 채팅에서 멤버 초대로 그룹 채팅 변환
- ✅ **채팅방 나가기**: 시스템 메시지와 함께 채팅방 퇴장
- ✅ **그룹 이름 변경**: 방장만 그룹 이름 변경 가능
- ✅ **시스템 메시지**: 입장/퇴장/초대 등 시스템 이벤트 표시

## 데이터베이스 구조

### Firestore Collections

#### 1. `conversations/{conversationId}`
대화방 정보를 저장합니다.

```typescript
{
  conversationId: string;          // 문서 ID
  participants: string[];           // 참여자 userId 배열
  type: "direct" | "group";        // 대화 타입
  lastMessage?: {
    content: string;
    senderId: string;
    createdAt: Timestamp;
  };
  lastMessageAt?: Timestamp;       // 마지막 메시지 시간
  createdAt: Timestamp;
  updatedAt: Timestamp;
  // 그룹 채팅의 경우
  name?: string;                    // 그룹 이름
  imageUrl?: string;                // 그룹 이미지
  createdBy?: string;               // 그룹 생성자
}
```

#### 2. `conversations/{conversationId}/messages/{messageId}`
개별 메시지를 저장합니다 (서브컬렉션).

```typescript
{
  messageId: string;                // 문서 ID
  conversationId: string;           // 대화방 ID
  senderId: string;                 // 발신자 userId ("system" for system messages)
  content: string;                  // 메시지 내용
  type: "text" | "image" | "system"; // 메시지 타입
  imageUrls?: string[];             // 이미지 URL 배열
  readBy: {                         // 읽음 상태
    [userId: string]: Timestamp;    // userId별 읽은 시간
  };
  createdAt: Timestamp;
  updatedAt?: Timestamp;
}
```

#### 3. `friends/{friendId}`
친구 관계를 저장합니다.

```typescript
{
  odId: string;                     // 문서 ID
  userId: string;                   // 현재 사용자
  friendId: string;                 // 상대방 사용자
  status: "none" | "pending" | "accepted" | "blocked";
  createdAt: Timestamp;
  updatedAt?: Timestamp;
  nickname?: string;                // 친구에게 설정한 별명
}
```

## Firestore Security Rules

```javascript
// Conversations Collection
match /conversations/{conversationId} {
  // 읽기: 인증된 사용자 (get은 모두 허용, list는 참여자만)
  allow get: if request.auth != null;
  allow list: if request.auth != null 
    && request.auth.uid in resource.data.participants;
  
  // 생성: 자신을 참여자로 포함해야 함
  allow create: if request.auth != null 
    && request.auth.uid in request.resource.data.participants;
  
  // 수정: 참여자만 수정 가능
  allow update: if request.auth != null 
    && request.auth.uid in resource.data.participants;
  
  // 삭제: 참여자만 삭제 가능
  allow delete: if request.auth != null 
    && request.auth.uid in resource.data.participants;
  
  // Messages 서브컬렉션
  match /messages/{messageId} {
    // 읽기: 인증된 사용자
    allow read: if request.auth != null;
    
    // 생성: 발신자 ID가 본인이어야 함
    allow create: if request.auth != null 
      && request.auth.uid == request.resource.data.senderId;
    
    // 수정: 발신자만 수정 가능 (readBy 업데이트 포함)
    allow update: if request.auth != null 
      && (resource.data.senderId == request.auth.uid 
          || request.resource.data.diff(resource.data).affectedKeys().hasOnly(['readBy', 'updatedAt']));
    
    // 삭제: 발신자만 삭제 가능
    allow delete: if request.auth != null 
      && resource.data.senderId == request.auth.uid;
  }
}

// Friends Collection
match /friends/{friendId} {
  allow read: if request.auth != null 
    && (resource.data.userId == request.auth.uid || resource.data.friendId == request.auth.uid);
  allow create: if request.auth != null 
    && request.resource.data.userId == request.auth.uid;
  allow update, delete: if request.auth != null 
    && resource.data.userId == request.auth.uid;
}
```

## 아키텍처 구조

### Domain Layer

#### Entities
```
lib/features/chat/domain/entities/
  ├── conversation_entity.dart      # 대화방 엔티티 ✅
  ├── message_entity.dart           # 메시지 엔티티 ✅
  ├── chat_user_entity.dart         # 채팅 사용자 정보 엔티티 ✅
  └── friend_entity.dart            # 친구 관계 엔티티 ✅
```

#### Repositories
```
lib/features/chat/domain/repositories/
  ├── chat_repository.dart          # 채팅 Repository 인터페이스 ✅
  └── friend_repository.dart        # 친구 Repository 인터페이스 ✅
```

### Data Layer

#### Models
```
lib/features/chat/data/models/
  ├── conversation_model.dart        # Freezed 모델 ✅
  ├── message_model.dart            # Freezed 모델 ✅
  ├── chat_user_model.dart          # Freezed 모델 ✅
  └── friend_model.dart             # Freezed 모델 ✅
```

#### Repositories
```
lib/features/chat/data/repositories/
  ├── firestore_chat_repository.dart   # Firestore 구현 ✅
  └── firestore_friend_repository.dart # Firestore 구현 ✅
```

#### Providers
```
lib/features/chat/data/providers/
  └── chat_repository_providers.dart   # Repository Providers ✅
```

### Presentation Layer

#### Screens
```
lib/features/chat/presentation/screens/
  ├── chat_list_screen.dart          # 채팅 목록 ✅
  ├── chat_screen.dart               # 채팅 화면 ✅
  ├── chat_info_screen.dart          # 채팅방 정보 ✅
  ├── new_chat_screen.dart           # 새 채팅 시작 ✅
  ├── friend_list_screen.dart        # 친구 목록 ✅
  └── user_profile_screen.dart       # 유저 프로필 ✅
```

#### Widgets
```
lib/features/chat/presentation/widgets/
  ├── chat_list_item.dart            # 채팅 목록 아이템 ✅
  ├── message_bubble.dart            # 메시지 버블 ✅
  ├── message_input.dart             # 메시지 입력 필드 ✅
  └── chat_user_search.dart          # 사용자 검색 ✅
```

#### Providers
```
lib/features/chat/presentation/providers/
  ├── chat_providers.dart            # 채팅 관련 Providers ✅
  └── friend_providers.dart          # 친구 관련 Providers ✅
```

## 구현 상태

### Phase 1: 기본 인프라 ✅
- [x] Firestore Collections 구조 설계 및 생성
- [x] Security Rules 작성 및 배포
- [x] Domain Layer 구현 (Entities, Repository 인터페이스)
- [x] Data Layer 구현 (Models, Firestore Repository)

### Phase 2: 1:1 채팅 기능 ✅
- [x] 채팅 목록 화면 구현
- [x] 채팅 화면 구현 (메시지 표시, 입력)
- [x] 실시간 메시지 동기화
- [x] 사용자 검색 및 새 채팅 시작 기능

### Phase 3: 고급 기능 ✅
- [x] 읽음 상태 표시
- [x] 이미지 전송 기능 (갤러리/카메라 선택)
- [x] 메시지 삭제 기능
- [x] 읽지 않은 메시지 수 표시
- [x] 이미지 전체 화면 보기

### Phase 4: 푸시 알림 ✅
- [x] Cloud Functions로 새 메시지 알림 전송
- [x] 채팅 알림 설정 (앱 내 설정 연동)

### Phase 5: 그룹 채팅 ✅
- [x] 그룹 채팅 생성 (1:1에서 멤버 초대로 변환)
- [x] 그룹 멤버 관리 (초대, 나가기)
- [x] 그룹 정보 수정 (이름 변경)
- [x] 시스템 메시지 (입장/퇴장/초대)

### Phase 6: 친구 시스템 ✅
- [x] 친구 추가/삭제/차단
- [x] QR 코드로 친구 추가
- [x] 친구 검색 (닉네임, 아이디, 이메일)
- [x] 친구에게만 메시지 전송 가능

## 주요 구현 포인트

### 1. 대화방 ID 생성
1:1 채팅의 경우, 두 사용자 ID를 정렬하여 고유한 대화방 ID를 생성합니다.

```dart
String generateConversationId(String userId1, String userId2) {
  final sorted = [userId1, userId2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}
```

### 2. 실시간 메시지 스트림
```dart
Stream<List<Message>> watchMessages(String conversationId) {
  return _firestore
    .collection('conversations')
    .doc(conversationId)
    .collection('messages')
    .orderBy('createdAt', descending: false)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Message.fromFirestore(doc))
      .toList());
}
```

### 3. 멤버 초대 (그룹 채팅 변환)
```dart
Future<void> addMembersToConversation({
  required String conversationId,
  required List<String> memberIds,
  required String addedByNickname,
}) async {
  // 1. 현재 참여자 가져오기
  // 2. 새 멤버 추가
  // 3. 1:1 → 그룹으로 타입 변경 (3명 이상)
  // 4. 시스템 메시지 전송
}
```

### 4. 채팅방 나가기
```dart
Future<void> leaveConversation({
  required String conversationId,
  required String userId,
  required String userNickname,
}) async {
  // 1. 참여자 목록에서 제거
  // 2. 시스템 메시지 전송 ("{닉네임}さんがチャットを退出しました")
  // 3. 마지막 참여자면 대화방 삭제
}
```

### 5. 시스템 메시지 타입
```dart
enum MessageType {
  text,    // 일반 텍스트 메시지
  image,   // 이미지 메시지
  system,  // 시스템 메시지 (입장/퇴장/초대 등)
}
```

### 6. 이미지 전송
```dart
Future<void> _pickAndSendImage() async {
  // 1. 이미지 소스 선택 (갤러리/카메라)
  final source = await showModalBottomSheet<ImageSource>(...);
  
  // 2. 이미지 선택
  final pickedFile = await _imagePicker.pickImage(
    source: source,
    imageQuality: 70,
    maxWidth: 1200,
  );
  
  // 3. Firebase Storage 업로드
  final imageUrl = await _imageUploadService.uploadImage(...);
  
  // 4. 메시지 전송
  await sendMessage(ref, imageUrls: [imageUrl], ...);
}
```

### 7. 타이핑 인디케이터
```dart
// Firestore 구조: conversations/{id}/typing/{userId}
{
  userId: string;
  isTyping: boolean;
  updatedAt: Timestamp;
}

// 3초 타임아웃으로 자동 종료
// 5초 이내 업데이트만 표시
```

### 8. 채팅 푸시 알림 (Cloud Functions)
```typescript
export const onChatMessageCreated = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event) => {
    // 시스템 메시지 제외
    // 발신자 제외한 모든 참여자에게 알림
    // 그룹 채팅: "{그룹명} - {발신자}" 형식
    // 이미지: "📷 사진을 보냈습니다." 표시
  }
);
```

## 라우팅

```dart
// app_routes.dart
static const String chatList = '/chat';
static String chatPath(String conversationId) => '/chat/$conversationId';
static String chatInfoPath(String conversationId) => '/chat/$conversationId/info';
static const String newChat = '/chat/new';
static const String friendList = '/friends';
static String userProfilePath(String userId) => '/user/$userId';

// app_router.dart
GoRoute(
  path: AppRoutes.chatList,
  builder: (context, state) => const ChatListScreen(),
  routes: [
    GoRoute(
      path: 'new',
      builder: (context, state) => const NewChatScreen(),
    ),
    GoRoute(
      path: ':conversationId',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        return ChatScreen(conversationId: conversationId);
      },
      routes: [
        GoRoute(
          path: 'info',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            return ChatInfoScreen(conversationId: conversationId);
          },
        ),
      ],
    ),
  ],
),
GoRoute(
  path: AppRoutes.friendList,
  builder: (context, state) => const FriendListScreen(),
),
GoRoute(
  path: '/user/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return UserProfileScreen(userId: userId);
  },
),
```

## Firestore 인덱스

다음 인덱스가 필요합니다:

```json
{
  "indexes": [
    {
      "collectionGroup": "conversations",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "participants", "arrayConfig": "CONTAINS" },
        { "fieldPath": "lastMessageAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "conversationId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "friends",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    }
  ]
}
```

## 비용 고려사항

### Firestore 읽기/쓰기
- 메시지 전송: 1 write (message) + 1 write (conversation 업데이트)
- 메시지 읽기: 1 read per message
- 채팅 목록 조회: 1 read per conversation

### Cloud Functions
- 새 메시지 알림: 참여자 수만큼 FCM 전송

### 최적화 방안
- 메시지 페이지네이션 (한 번에 20-50개씩 로드)
- 채팅 목록 캐싱
- 읽음 상태는 배치로 업데이트

## 남은 작업

### 우선순위 높음
1. [x] ~~이미지 전송 기능 구현~~ ✅
2. [x] ~~Cloud Functions로 채팅 알림 전송~~ ✅
3. [x] ~~타이핑 인디케이터~~ ✅

### 우선순위 중간
1. [x] ~~메시지 검색 기능~~ ✅
2. [ ] 채팅방 이미지 설정

### 우선순위 낮음
1. [ ] 메시지 반응 (이모지)
2. [ ] 메시지 답장
3. [ ] 메시지 전달
