# 신고 기능 설정 가이드

이 문서는 신고 기능의 설정 및 배포 방법을 안내합니다.

## 개요

신고 기능은 다음과 같이 동작합니다:

1. **Flutter 앱**: 사용자가 게시글/댓글을 신고하면 Firestore `reports` 컬렉션에 문서 생성
2. **Cloud Functions**: `reports` 문서 생성 시 Slack Incoming Webhook으로 알림 전송
3. **Cloud Functions**: 게시글 신고 3개 이상 시 자동으로 게시글을 숨김 처리 (`status: "hidden"`)
4. **Firestore Rules**: 로그인한 사용자만 신고 가능, 중복 신고 방지
5. **Admin 기능**: Admin은 자신이 소속된 교회의 게시글을 수동으로 비표시/표시할 수 있음

## Firebase 설정

### 1. Cloud Functions 설정

#### Slack Webhook URL 설정

Firebase Functions v2에서는 환경 변수를 사용합니다. 다음 방법 중 하나를 선택하세요:

**방법 1: 로컬 테스트용 (.env 파일 사용)**

`functions/.env` 파일 생성:
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

⚠️ **주의**: 
- `.env` 파일은 Git에 커밋하지 마세요. `functions/.gitignore`에 포함되어 있습니다.
- `functions/src/index.ts`에서 dotenv를 사용하여 `.env` 파일을 자동으로 로드합니다.
- 배포 시에는 Firebase Console에서 환경 변수를 설정하거나 Secret Manager를 사용하세요.

**방법 2: Firebase Secret Manager 사용 (배포 시 권장)**

```bash
# Secret 생성 (대화형으로 URL 입력)
firebase functions:secrets:set SLACK_WEBHOOK_URL
# 프롬프트에서 Slack Webhook URL 입력

# 배포 시 Secret 사용
firebase deploy --only functions
```

⚠️ **주의**: 현재 코드는 `process.env.SLACK_WEBHOOK_URL`을 사용하므로, Secret Manager를 사용하려면 코드 수정이 필요합니다. 또는 Firebase Console에서 환경 변수로 설정할 수 있습니다.

**방법 3: 환경 변수 직접 설정 (배포 시)**

Firebase Console에서:
1. Firebase Console → Functions → 설정
2. "환경 변수" 탭에서 `SLACK_WEBHOOK_URL` 추가
3. 값: Slack에서 생성한 Incoming Webhook URL

### 2. Cloud Functions 배포

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

또는 프로젝트 루트에서:

```bash
firebase deploy --only functions
```

### 3. Firestore Rules 배포

```bash
firebase deploy --only firestore:rules
```

또는 모든 규칙과 함께:

```bash
firebase deploy --only firestore
```

## Slack Incoming Webhook 설정

1. Slack 워크스페이스에 로그인
2. [Slack Apps](https://api.slack.com/apps) 페이지로 이동
3. "Create New App" 클릭
4. "From scratch" 선택
5. App 이름과 워크스페이스를 선택
6. "Incoming Webhooks" 기능 활성화
7. "Add New Webhook to Workspace" 클릭
8. 알림을 받을 채널 선택
9. 생성된 Webhook URL을 복사하여 위의 `firebase functions:config:set` 명령에 사용

## Firestore 데이터 구조

### reports 컬렉션

```typescript
{
  targetType: "post" | "comment" | "user",
  targetId: string,
  reason: string,
  reporterId: string,
  createdAt: Timestamp
}
```

## 테스트

### 1. Flutter 앱에서 신고 테스트

1. 게시글 상세 화면에서 우측 상단 메뉴 → "通報する" 선택
2. 신고 사유 선택 및 제출
3. Firestore Console에서 `reports` 컬렉션에 문서가 생성되었는지 확인

### 2. Cloud Functions 테스트

1. Firestore Console에서 `reports` 컬렉션에 수동으로 문서 생성
2. Slack 채널에서 알림이 수신되는지 확인
3. Cloud Functions 로그 확인:

```bash
firebase functions:log --only onReportCreated
```

## 문제 해결

### Slack 알림이 전송되지 않는 경우

1. **환경 변수 확인**:
   - Firebase Console → Functions → 설정에서 환경 변수 확인
   - 또는 로컬 테스트 시 `.env` 파일 확인

2. **Functions 로그 확인**:
   ```bash
   firebase functions:log
   ```

3. **Webhook URL 테스트** (curl 사용):
   ```bash
   curl -X POST -H 'Content-type: application/json' \
   --data '{"text":"테스트 메시지"}' \
   YOUR_WEBHOOK_URL
   ```

### Firestore Rules 오류

1. Rules 문법 확인:
   ```bash
   firebase deploy --only firestore:rules --dry-run
   ```

2. Rules 테스트:
   - Firebase Console → Firestore Database → Rules 탭
   - "Rules Playground" 사용

## 보안 고려사항

1. **Slack Webhook URL 보안**: Functions Config에 저장된 값은 암호화되지 않으므로, 민감한 정보는 사용하지 마세요.
2. **신고 데이터 접근 제한**: 현재는 로그인한 사용자가 모든 신고를 읽을 수 있습니다. 실제 운영 시에는 관리자 역할 체크를 추가하는 것을 권장합니다.
3. **중복 신고 방지**: 애플리케이션 레벨에서 5분 내 동일 유저의 동일 대상 신고를 방지합니다.

## 게시글 자동 숨김 기능

신고가 3개 이상 접수된 게시글은 자동으로 숨김 처리됩니다.

**동작 방식**:
1. `reports` 문서 생성 시 Cloud Functions 트리거 실행
2. 해당 게시글의 신고 개수 확인
3. 신고 개수가 3개 이상이고 게시글 상태가 "published"인 경우
4. 게시글의 `status`를 "hidden"으로 변경

**설정**:
- `HIDE_THRESHOLD = 3` (Cloud Functions 코드에서 설정)
- 필요시 `functions/src/index.ts`에서 값 변경 가능

## Admin 게시글 비표시 기능

Admin은 자신이 소속된 교회의 게시글을 수동으로 비표시/표시할 수 있습니다.

**권한**:
- Admin 역할 (`role: "admin"`)을 가진 사용자만 가능
- 자신이 소속된 교회 (`mainParishId`)의 게시글만 비표시 가능
- 소속 교회가 아니면 권한 없음 에러 표시

**사용 방법**:
1. 게시글 상세 화면에서 우측 상단 메뉴 클릭
2. "非表示にする" (비표시) 또는 "表示する" (표시) 선택
3. 확인 다이얼로그에서 확인

**Firestore Rules**:
- `isAdmin()` helper function: 관리자 여부 확인
- `isAdminOfPostParish()` helper function: 관리자가 자신의 교회 게시글인지 확인
- Posts update 규칙: 관리자는 자신이 소속된 교회의 게시글만 `status`와 `updatedAt` 수정 가능

## 추가 개선 사항

- [ ] 관리자 대시보드에서 신고 목록 조회
- [ ] 신고 처리 상태 추가 (pending, reviewed, resolved 등)
- [ ] 신고 통계 및 분석
- [ ] 자동 신고 처리 임계값 설정 (현재 3개 고정)
