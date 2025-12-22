# FCM 인증 문제 해결 가이드

## 문제
Cloud Functions에서 FCM 메시지 전송 시 다음 에러 발생:
```
Request is missing required authentication credential. Expected OAuth 2 access token, login cookie or other valid authentication credential.
```

## 원인
Firebase Admin SDK가 FCM API를 호출할 때 필요한 인증 자격 증명을 찾을 수 없음.

## 해결 방법

### 방법 1: Google Cloud Console에서 서비스 계정에 권한 부여 (권장)

1. **Google Cloud Console 접속**
   - https://console.cloud.google.com/
   - 프로젝트: `credo-ceda9` 선택

2. **IAM 및 관리자 > 서비스 계정** 이동
   - https://console.cloud.google.com/iam-admin/serviceaccounts?project=credo-ceda9

3. **서비스 계정 찾기**
   - `firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com` 검색

4. **서비스 계정 클릭 > 권한 탭**

5. **역할 추가** 클릭

6. **다음 역할 추가:**
   - `Firebase Cloud Messaging API Admin` (또는 `Firebase Cloud Messaging API Service Agent`)
   - `Service Account Token Creator` (필요한 경우)

7. **저장**

### 방법 2: Google Cloud Console에서 API 활성화 확인

1. **API 및 서비스 > 사용 설정된 API** 이동
   - https://console.cloud.google.com/apis/dashboard?project=credo-ceda9

2. **다음 API가 활성화되어 있는지 확인:**
   - Firebase Cloud Messaging API
   - Firebase Installations API

3. **활성화되지 않은 경우 "API 사용 설정" 클릭**

### 방법 3: Cloud Functions 서비스 계정 확인

현재 Cloud Functions는 다음 서비스 계정을 사용:
- `firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com` (onCall 옵션에서 지정)

이 서비스 계정에 FCM API 권한이 있는지 확인해야 합니다.

## 확인 방법

1. **서비스 계정 권한 확인:**
   ```bash
   gcloud projects get-iam-policy credo-ceda9 \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount:firebase-adminsdk-fbsvc@credo-ceda9.iam.gserviceaccount.com" \
     --format="table(bindings.role)"
   ```

2. **FCM API 활성화 확인:**
   ```bash
   gcloud services list --enabled --project=credo-ceda9 | grep fcm
   ```

## 참고

- Cloud Functions v2에서는 `onCall`의 `serviceAccount` 옵션으로 지정된 서비스 계정이 사용됩니다.
- 이 서비스 계정에 FCM API에 접근할 수 있는 권한이 필요합니다.
- 서비스 계정 키 파일을 사용하는 방법도 있지만, 보안상 권장하지 않습니다.

