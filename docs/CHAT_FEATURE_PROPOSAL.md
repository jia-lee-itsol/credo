# 채팅 기능 구현 제안서

## 개요
사용자 간 1:1 채팅 및 그룹 채팅 기능을 추가하여 앱 내에서 실시간 메시지 교환을 가능하게 합니다.

## 기능 요구사항

### 1. 핵심 기능
- ✅ **1:1 채팅**: 두 사용자 간 개인 메시지
- ✅ **그룹 채팅**: 여러 사용자와의 그룹 대화 (선택사항)
- ✅ **실시간 메시지 동기화**: Firestore Stream을 통한 실시간 업데이트
- ✅ **읽음 상태 표시**: 메시지 읽음/안 읽음 상태 표시
- ✅ **이미지 전송**: 채팅에서 이미지 공유
- ✅ **푸시 알림**: 새 메시지 수신 시 알림

### 2. UI/UX 기능
- ✅ **채팅 목록 화면**: 대화 목록 (최신 메시지 미리보기)
- ✅ **채팅 화면**: 메시지 입력 및 표시
- ✅ **사용자 검색**: 채팅 시작을 위한 사용자 검색
- ✅ **읽음 표시**: 메시지 읽음 상태 표시
- ✅ **타이핑 인디케이터**: 상대방이 입력 중임을 표시 (선택사항)

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

#### 2. `messages/{messageId}`
개별 메시지를 저장합니다.

```typescript
{
  messageId: string;                // 문서 ID
  conversationId: string;           // 대화방 ID
  senderId: string;                 // 발신자 userId
  content: string;                  // 메시지 내용
  imageUrls?: string[];             // 이미지 URL 배열
  readBy: {                         // 읽음 상태
    [userId: string]: Timestamp;    // userId별 읽은 시간
  };
  createdAt: Timestamp;
  updatedAt?: Timestamp;
  // 삭제된 메시지
  deletedAt?: Timestamp;
  deletedBy?: string;
}
```

#### 3. `conversationParticipants/{participantId}`
사용자별 대화방 목록을 빠르게 조회하기 위한 인덱스 컬렉션 (선택사항)

```typescript
{
  participantId: string;             // "{userId}_{conversationId}"
  userId: string;
  conversationId: string;
  lastReadAt?: Timestamp;          // 마지막으로 읽은 시간
  unreadCount: number;             // 읽지 않은 메시지 수
  createdAt: Timestamp;
}
```

## Firestore Security Rules

```javascript
// Conversations Collection
match /conversations/{conversationId} {
  // 읽기: 참여자만 읽기 가능
  allow read: if request.auth != null 
    && request.auth.uid in resource.data.participants;
  
  // 생성: 자신을 참여자로 포함해야 함
  allow create: if request.auth != null 
    && request.auth.uid in request.resource.data.participants;
  
  // 수정: 참여자만 수정 가능 (lastMessage, lastMessageAt 등)
  allow update: if request.auth != null 
    && request.auth.uid in resource.data.participants;
  
  // 삭제: 참여자만 삭제 가능
  allow delete: if request.auth != null 
    && request.auth.uid in resource.data.participants;
  
  // Messages 서브컬렉션
  match /messages/{messageId} {
    // 읽기: 대화방 참여자만 읽기 가능
    allow read: if request.auth != null 
      && request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
    
    // 생성: 대화방 참여자만 메시지 전송 가능
    allow create: if request.auth != null 
      && request.auth.uid == request.resource.data.senderId
      && request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
    
    // 수정: 발신자만 수정 가능 (readBy 업데이트 포함)
    allow update: if request.auth != null 
      && (resource.data.senderId == request.auth.uid 
          || request.resource.data.diff(resource.data).affectedKeys().hasOnly(['readBy', 'updatedAt']));
    
    // 삭제: 발신자만 삭제 가능
    allow delete: if request.auth != null 
      && resource.data.senderId == request.auth.uid;
  }
}
```

## 아키텍처 구조

### Domain Layer

#### Entities
```
lib/features/chat/domain/entities/
  ├── conversation_entity.dart      # 대화방 엔티티
  ├── message_entity.dart           # 메시지 엔티티
  └── chat_user_entity.dart         # 채팅 사용자 정보 엔티티
```

#### Repositories
```
lib/features/chat/domain/repositories/
  └── chat_repository.dart          # 채팅 Repository 인터페이스
```

#### Use Cases
```
lib/features/chat/domain/usecases/
  ├── create_conversation_usecase.dart
  ├── send_message_usecase.dart
  ├── watch_conversations_usecase.dart
  ├── watch_messages_usecase.dart
  └── mark_message_read_usecase.dart
```

### Data Layer

#### Models
```
lib/features/chat/data/models/
  ├── conversation_model.dart        # Freezed 모델
  ├── message_model.dart            # Freezed 모델
  └── chat_user_model.dart          # Freezed 모델
```

#### Repositories
```
lib/features/chat/data/repositories/
  └── firestore_chat_repository.dart # Firestore 구현
```

### Presentation Layer

#### Screens
```
lib/features/chat/presentation/screens/
  ├── chat_list_screen.dart          # 채팅 목록
  ├── chat_screen.dart               # 채팅 화면
  └── new_chat_screen.dart           # 새 채팅 시작
```

#### Widgets
```
lib/features/chat/presentation/widgets/
  ├── chat_list_item.dart            # 채팅 목록 아이템
  ├── message_bubble.dart            # 메시지 버블
  ├── message_input.dart             # 메시지 입력 필드
  └── chat_user_search.dart          # 사용자 검색
```

#### Providers
```
lib/features/chat/presentation/providers/
  ├── chat_providers.dart            # Riverpod providers
  └── chat_notifiers.dart            # State notifiers
```

## 구현 단계

### Phase 1: 기본 인프라 (1주)
- [ ] Firestore Collections 구조 설계 및 생성
- [ ] Security Rules 작성 및 배포
- [ ] Domain Layer 구현 (Entities, Repository 인터페이스)
- [ ] Data Layer 구현 (Models, Firestore Repository)

### Phase 2: 1:1 채팅 기능 (2주)
- [ ] 채팅 목록 화면 구현
- [ ] 채팅 화면 구현 (메시지 표시, 입력)
- [ ] 실시간 메시지 동기화
- [ ] 사용자 검색 및 새 채팅 시작 기능

### Phase 3: 고급 기능 (1주)
- [ ] 읽음 상태 표시
- [ ] 이미지 전송 기능
- [ ] 메시지 삭제 기능
- [ ] 읽지 않은 메시지 수 표시

### Phase 4: 푸시 알림 (1주)
- [ ] Cloud Functions로 새 메시지 알림 전송
- [ ] 채팅 알림 설정 (앱 내 설정 연동)

### Phase 5: 그룹 채팅 (선택사항, 2주)
- [ ] 그룹 채팅 생성
- [ ] 그룹 멤버 관리
- [ ] 그룹 정보 수정

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

### 3. 읽음 상태 업데이트
```dart
Future<void> markAsRead(String messageId, String userId) async {
  await _firestore
    .collection('messages')
    .doc(messageId)
    .update({
      'readBy.$userId': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
}
```

### 4. 푸시 알림 (Cloud Functions)
```typescript
// functions/src/index.ts
export const onMessageCreated = functions.firestore
  .document('conversations/{conversationId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const conversationId = context.params.conversationId;
    
    // 대화방 정보 가져오기
    const conversation = await admin.firestore()
      .collection('conversations')
      .doc(conversationId)
      .get();
    
    const participants = conversation.data()?.participants || [];
    const senderId = message.senderId;
    
    // 발신자를 제외한 모든 참여자에게 알림 전송
    const recipients = participants.filter((id: string) => id !== senderId);
    
    // 각 수신자에게 알림 전송
    for (const recipientId of recipients) {
      await sendChatNotification(recipientId, message, conversation.data());
    }
  });
```

## UI/UX 디자인 제안

### 채팅 목록 화면
- 앱 하단 네비게이션에 "채팅" 탭 추가
- 각 채팅 항목: 상대방 프로필 이미지, 이름, 마지막 메시지 미리보기, 시간, 읽지 않은 메시지 수 배지
- 최신 메시지가 있는 채팅이 위로 정렬

### 채팅 화면
- 상단: 상대방 프로필 정보 (이름, 프로필 이미지)
- 중간: 메시지 리스트 (자신의 메시지는 오른쪽, 상대방 메시지는 왼쪽)
- 하단: 메시지 입력 필드 (텍스트 입력, 이미지 첨부 버튼, 전송 버튼)
- 읽음 표시: 메시지 하단에 "읽음" 표시

## 라우팅 추가

```dart
// app_routes.dart
static const String chatList = '/chat';
static String chatPath(String conversationId) => '/chat/$conversationId';
static const String newChat = '/chat/new';

// app_router.dart
GoRoute(
  path: AppRoutes.chatList,
  builder: (context, state) => const ChatListScreen(),
),
GoRoute(
  path: '/chat/:conversationId',
  builder: (context, state) {
    final conversationId = state.pathParameters['conversationId']!;
    return ChatScreen(conversationId: conversationId);
  },
),
GoRoute(
  path: AppRoutes.newChat,
  builder: (context, state) => const NewChatScreen(),
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

## 다음 단계

1. 이 제안서 검토 및 승인
2. Phase 1부터 순차적으로 구현 시작
3. 각 Phase 완료 후 테스트 및 피드백 수집

