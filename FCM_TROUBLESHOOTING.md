# FCM 알림 전송 문제 해결 가이드

## 현재 상황
- 서비스 계정 키 파일은 로드되고 있음
- 하지만 여전히 "Request is missing required authentication credential" 에러 발생

## 기본 해결 단계

### 1. FCM API 활성화 확인
```bash
gcloud services list --enabled --project=credo-ceda9 | grep -i fcm
```

다음 API들이 활성화되어 있어야 합니다:
- `fcm.googleapis.com` (Firebase Cloud Messaging API)
- `fcmregistrations.googleapis.com` (FCM Registration API)

활성화되지 않았다면:
```bash
gcloud services enable fcm.googleapis.com --project=credo-ceda9
gcloud services enable fcmregistrations.googleapis.com --project=credo-ceda9
```

### 2. 서비스 계정 권한 확인
```bash
# firebase-adminsdk-fbsvc 서비스 계정 권한 확인
gcloud projects get-iam-policy credo-ceda9 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com" \
  --format="table(bindings.role)"
```

다음 역할이 있어야 합니다:
- `roles/firebasecloudmessaging.admin` 또는
- `roles/firebasemessaging.admin`

### 3. 서비스 계정 키 파일 확인
```bash
# 키 파일이 올바른지 확인
cd /Users/charlotteyi/Documents/Github/credo/functions
cat serviceAccountKey.json | jq -r '.client_email'
# 출력: firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com
```

### 4. Google Cloud Console에서 직접 확인

#### A. FCM API 활성화
1. https://console.cloud.google.com/apis/library/fcm.googleapis.com?project=credo-ceda9
2. "사용 설정" 버튼 클릭 (이미 활성화되어 있으면 "관리" 표시)

#### B. 서비스 계정 권한 확인
1. https://console.cloud.google.com/iam-admin/serviceaccounts?project=credo-ceda9
2. `firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com` 클릭
3. "권한" 탭에서 `Firebase Cloud Messaging API Admin` 역할 확인

#### C. Cloud Functions 서비스 계정 확인
1. https://console.cloud.google.com/functions/details/us-central1/sendTestNotification?project=credo-ceda9
2. "구성" 탭 → "서비스 계정" 확인
3. `firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com`인지 확인

### 5. 대안: Firebase Console에서 직접 테스트
1. https://console.firebase.google.com/project/credo-ceda9/notification/compose
2. "테스트 메시지 전송" 클릭
3. FCM 토큰 입력: `ff9fnze7s06st7h3rxpyfz:APA91bHBOV57mtHnei2ZtkMUhtBiqxw9ethWkerzOScpKDoqsM8B_fXIHTm7qEiXgLWANBOECRyeM0ypeskEhQXm9ycgx8tT7IXcif6SOkwt2pcqh7ENz7Y`
4. 전송 성공하면 FCM 자체는 정상 작동하는 것

### 6. 서비스 계정 키 재생성 (최후의 수단)
1. https://console.cloud.google.com/iam-admin/serviceaccounts?project=credo-ceda9
2. `firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com` 클릭
3. "키" 탭 → "키 추가" → "JSON 만들기"
4. 다운로드한 파일을 `functions/serviceAccountKey.json`으로 복사
5. 재배포

### 7. 코드 수정: 환경 변수 사용 (권장)
서비스 계정 키를 환경 변수로 설정:
```bash
cd /Users/charlotteyi/Documents/Github/credo/functions
SERVICE_ACCOUNT_KEY=$(cat serviceAccountKey.json | jq -c .)
firebase functions:config:set service_account.key="$SERVICE_ACCOUNT_KEY"
firebase deploy --only functions:sendTestNotification
```

## 체크리스트
- [ ] FCM API 활성화 확인
- [ ] 서비스 계정 권한 확인
- [ ] 서비스 계정 키 파일 존재 및 유효성 확인
- [ ] Cloud Functions 서비스 계정 설정 확인
- [ ] Firebase Console에서 직접 테스트
- [ ] 서비스 계정 키 재생성 (필요시)
- [ ] 환경 변수로 키 설정 (권장)

