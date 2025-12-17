# Google Sign-In 문제 해결 가이드

## ✅ 문제 해결 완료 (2025-12-16)

**`ApiException: 10` (DEVELOPER_ERROR) 문제가 해결되었습니다!**

## 최종 설정 상태

### Firebase Console에 등록된 SHA 인증서
- **SHA-1**: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`
- **SHA-256**: `a3:7f:31:ef:90:67:6c:5c:68:87:d5:a3:2c:5a:94:de:4a:9f:ee:a7:67:d6:7c:57:0f:ef:06:cd:aa:60:d9:2a`

### OAuth Client IDs
- ✅ **Android Client**: `182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com`
- ✅ **Web Client**: `182699877294-cok4t52b66k9atp9u2n8es6o87d6dj5m.apps.googleusercontent.com`

### 해결 방법
1. Firebase Console에서 SHA 인증서 추가 (`61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`)
2. Firebase가 자동으로 Android OAuth Client 생성
3. `google-services.json` 다시 다운로드 및 적용
4. Google Sign-In 정상 작동 확인

---

## 참고: ApiException: 10 (DEVELOPER_ERROR) 해결 방법 (이전 내용)

### 1. Google Cloud Console에서 OAuth 설정 확인

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 선택: `credo-ceda9`
3. **APIs & Services** → **Credentials** 이동
4. **OAuth 2.0 Client IDs** 섹션 확인
5. Android용 OAuth Client ID가 있는지 확인:
   - **Application type**: Android
   - **Package name**: `com.itz.credo`
   - **SHA-1 certificate fingerprint**: `61:db:3e:ce:ce:32:09:21:57:58:20:49:5a:6c:8a:64:8e:5c:1d:3a`

### 2. OAuth Client ID가 없는 경우 생성

1. Google Cloud Console → **APIs & Services** → **Credentials**
2. **+ CREATE CREDENTIALS** → **OAuth client ID** 클릭
3. **Application type**: Android 선택
4. **Name**: `Credo Android` (또는 원하는 이름)
5. **Package name**: `com.itz.credo` 입력
6. **SHA-1 certificate fingerprint**: `61:db:3e:ce:ce:32:09:21:57:58:20:49:5a:6c:8a:64:8e:5c:1d:3a` 입력
7. **CREATE** 클릭

### 3. Web Client ID 확인

Google Sign-In을 사용하려면 Web Client ID도 필요합니다:

1. Google Cloud Console → **APIs & Services** → **Credentials**
2. **OAuth 2.0 Client IDs**에서 **Web application** 타입의 Client ID 확인
3. 없다면 생성:
   - **Application type**: Web application
   - **Name**: `Credo Web`
   - **Authorized JavaScript origins**: (필요시 추가)
   - **Authorized redirect URIs**: (필요시 추가)

### 4. Firebase Console에서 OAuth 동의 화면 확인

1. Google Cloud Console → **APIs & Services** → **OAuth consent screen**
2. **Publishing status**가 **Testing** 또는 **In production**인지 확인
3. **Test users**에 테스트할 Google 계정 추가 (Testing 상태인 경우)

### 5. 앱 재빌드 및 테스트

1. `flutter clean`
2. `flutter pub get`
3. 앱 완전히 종료
4. `flutter run` 또는 앱 재시작
5. Google Sign-In 다시 시도

## 추가 확인 사항

### google-services.json 파일 확인

현재 `google-services.json`에 포함된 OAuth Client:
- **client_type: 3** (Web client): `182699877294-6qcgdug0hnqdkq9j5lkkglgct39qla9f.apps.googleusercontent.com`

이 Client ID가 Google Cloud Console에 존재하는지 확인하세요.

### 코드에서 serverClientId 설정

코드에서 이미 `serverClientId`를 명시적으로 설정했습니다:
```dart
GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: '182699877294-6qcgdug0hnqdkq9j5lkkglgct39qla9f.apps.googleusercontent.com',
)
```

## 문제가 계속되는 경우

1. **Google Cloud Console에서 OAuth Client ID 삭제 후 재생성**
2. **Firebase Console에서 앱 삭제 후 재등록** (최후의 수단)
3. **다른 기기에서 테스트** (특정 기기 문제일 수 있음)
4. **Google Play Services 업데이트 확인**
