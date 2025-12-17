# Android OAuth Client ID 누락 문제 해결

## ✅ 문제 해결 완료 (2025-12-16)

**Google 로그인 문제가 성공적으로 해결되었습니다!**

## 해결된 문제

이전에 `google-services.json` 파일에 **Android용 OAuth Client ID (`client_type: 1`)가 없었습니다.**

### 해결 전 상태
- ✅ Web Client (`client_type: 3`) - 있음
- ✅ iOS Client (`client_type: 2`) - 있음
- ❌ **Android Client (`client_type: 1`) - 없음** ← 이것이 문제였음!

### 해결 후 상태
- ✅ Web Client (`client_type: 3`) - 있음
- ✅ iOS Client (`client_type: 2`) - 있음
- ✅ **Android Client (`client_type: 1`) - 추가됨!** ← 해결 완료!

## 최종 설정

현재 `google-services.json` 파일의 Android OAuth Client 설정:

```json
"oauth_client": [
  {
    "client_id": "182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.itz.credo",
      "certificate_hash": "61db3ecece32d921575820495a6c8a648e5c1d3a"
    }
  },
  {
    "client_id": "182699877294-cok4t52b66k9atp9u2n8es6o87d6dj5m.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

### 해결 방법 요약

1. **Firebase Console에서 SHA 인증서 추가**
   - SHA-1: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`
   - Firebase가 자동으로 Android OAuth Client를 생성함

2. **google-services.json 다시 다운로드**
   - Android OAuth Client (`client_type: 1`)가 포함된 파일 다운로드
   - 프로젝트에 적용

3. **앱 재시작 및 테스트**
   - Google Sign-In 정상 작동 확인

---

## 참고: 문제 해결 방법 (이전 내용)

## 해결 방법

### 방법 1: Firebase Console에서 자동 생성 (권장)

1. **Firebase Console 접속**
   - [Firebase Console](https://console.firebase.google.com/)
   - 프로젝트: `credo-ceda9` 선택

2. **Google Sign-In 활성화 확인**
   - Authentication → Sign-in method → Google
   - **Enable**이 **ON**인지 확인
   - 만약 OFF라면 ON으로 설정하고 저장

3. **SHA 인증서 확인 및 추가**
   - 프로젝트 설정 → 일반 탭
   - Android 앱 (`com.itz.credo`) 선택
   - **SHA 인증서 지문** 섹션 확인
   - 다음 SHA-1이 추가되어 있는지 확인:
     ```
     61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A
     ```
   - 없다면 **디지털 지문 추가** 클릭하여 추가
   - **저장** 클릭

4. **잠시 대기 (5-10분)**
   - SHA 인증서를 추가하면 Firebase가 자동으로 Android OAuth Client를 생성합니다
   - 생성에는 몇 분이 걸릴 수 있습니다

5. **google-services.json 다시 다운로드**
   - 프로젝트 설정 → 일반 탭
   - Android 앱 섹션에서 **google-services.json** 다운로드
   - 파일을 열어서 `oauth_client` 배열에 `client_type: 1`이 있는지 확인
   - 있다면 `android/app/google-services.json`에 덮어쓰기

### 방법 2: Google Cloud Console에서 수동 생성 (방법 1이 작동하지 않는 경우)

1. **Firebase Console에서 Google Cloud 프로젝트 확인**
   - 프로젝트 설정 → 일반 탭
   - **프로젝트 ID**: `credo-ceda9`
   - **프로젝트 번호**: `182699877294`

2. **Google Cloud Console 접속**
   - [Google Cloud Console](https://console.cloud.google.com/)
   - 프로젝트 선택 드롭다운에서 **프로젝트 번호로 검색**: `182699877294`
   - 또는 프로젝트 ID로 검색: `credo-ceda9`

3. **OAuth 2.0 Client ID 생성**
   - APIs & Services → Credentials
   - **+ CREATE CREDENTIALS** → **OAuth client ID**
   - Application type: **Android** 선택
   - Name: `Android client for credo` (또는 원하는 이름)
   - Package name: `com.itz.credo`
   - SHA-1 certificate fingerprint: 
     ```
     61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A
     ```
   - **CREATE** 클릭

4. **google-services.json 다시 다운로드**
   - Firebase Console → 프로젝트 설정 → 일반 탭
   - **google-services.json** 다시 다운로드
   - `android/app/google-services.json`에 덮어쓰기

## 확인 방법

업데이트된 `google-services.json` 파일에서 다음을 확인하세요:

```json
"oauth_client": [
  {
    "client_id": "...",
    "client_type": 1  // ← 이것이 있어야 합니다!
  },
  {
    "client_id": "...",
    "client_type": 3  // Web client
  }
]
```

`client_type: 1`이 있으면 성공입니다!

## 다음 단계

1. `google-services.json` 업데이트 후 앱 완전히 종료
2. 앱 재시작
3. Google Sign-In 다시 시도
4. `ApiException: 10` 오류가 해결되었는지 확인
