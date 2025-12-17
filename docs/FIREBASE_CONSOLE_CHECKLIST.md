# Firebase Console 설정 확인 체크리스트

## 현재 프로젝트 정보
- **프로젝트 이름**: `credo`
- **프로젝트 ID**: `credo-ceda9`
- **프로젝트 번호**: `182699877294`
- **지원 이메일**: `j-lee@itsol.co.jp`

## 확인해야 할 항목들

### 1. Android 앱 설정 확인

Firebase Console → 프로젝트 설정 → 일반 탭에서:

- [ ] **Android 앱이 등록되어 있는지 확인**
  - 앱 패키지 이름: `com.itz.credo`
  - 앱 ID: `1:182699877294:android:cc1861e78d06f6f0bfde3f`

- [ ] **SHA 인증서 지문 확인**
  - SHA 인증서 지문 섹션이 있는지 확인
  - 다음 SHA-1이 추가되어 있는지 확인:
    ```
    61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A
    ```
  - **없다면**: **디지털 지문 추가** 버튼 클릭하여 추가
  - **있다면**: 값이 정확한지 확인 (특히 중간 부분 `D9:21` 확인)

### 2. Google Sign-In 활성화 확인

Firebase Console → Authentication → Sign-in method:

- [ ] **Google 제공업체 확인**
  - Google 제공업체를 클릭
  - **Enable** 토글이 **ON**인지 확인
  - **프로젝트 지원 이메일**이 설정되어 있는지 확인
  - **저장** 버튼이 있는지 확인 (변경사항이 있다면 저장)

### 3. Google Cloud Console에서 OAuth Client 확인

Firebase Console → 프로젝트 설정 → 일반 탭에서:

- [ ] **"Google Cloud 콘솔" 링크 클릭**
  - 또는 직접 [Google Cloud Console](https://console.cloud.google.com/) 접속
  - 프로젝트 선택: `credo-ceda9` 또는 프로젝트 번호 `182699877294`

- [ ] **APIs & Services → Credentials 확인**
  - OAuth 2.0 Client IDs 섹션 확인
  - **Android** 타입의 OAuth Client ID가 있는지 확인
  - 있다면:
    - Package name: `com.itz.credo`
    - SHA-1: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`
  - **없다면**: 새로 생성 필요 (아래 참고)

### 4. OAuth Client ID 생성 (없는 경우)

Google Cloud Console → APIs & Services → Credentials:

1. **+ CREATE CREDENTIALS** 클릭
2. **OAuth client ID** 선택
3. Application type: **Android** 선택
4. Name: `Android client for credo` (또는 원하는 이름)
5. Package name: `com.itz.credo`
6. SHA-1 certificate fingerprint:
   ```
   61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A
   ```
7. **CREATE** 클릭

### 5. google-services.json 다시 다운로드

Firebase Console → 프로젝트 설정 → 일반 탭:

- [ ] **Android 앱 섹션에서 "google-services.json" 다운로드 버튼 클릭**
- [ ] **다운로드한 파일 열어서 확인**
  - `oauth_client` 배열에 `client_type: 1` (Android)이 있는지 확인
  - 예시:
    ```json
    "oauth_client": [
      {
        "client_id": "...",
        "client_type": 1  // ← 이것이 있어야 함!
      },
      {
        "client_id": "...",
        "client_type": 3  // Web client
      }
    ]
    ```
- [ ] **`client_type: 1`이 있다면**: `android/app/google-services.json`에 덮어쓰기
- [ ] **`client_type: 1`이 없다면**: 
  - SHA 인증서가 제대로 추가되었는지 다시 확인
  - Google Cloud Console에서 Android OAuth Client ID가 생성되었는지 확인
  - 5-10분 대기 후 다시 다운로드 시도

## ✅ 현재 상태 (해결 완료)

현재 `google-services.json` 파일에는:
- ✅ Web Client (`client_type: 3`) - 있음
- ✅ iOS Client (`client_type: 2`) - 있음
- ✅ **Android Client (`client_type: 1`) - 있음!** ← 해결 완료!

### 최종 설정
- **Android OAuth Client ID**: `182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com`
- **Package name**: `com.itz.credo`
- **SHA-1**: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`

## 해결 완료 (2025-12-16)

Google Sign-In이 정상적으로 작동합니다. 위 체크리스트를 따라 설정을 완료했습니다.

### 해결 과정
1. ✅ Firebase Console에서 SHA 인증서 추가
2. ✅ Firebase가 자동으로 Android OAuth Client 생성
3. ✅ `google-services.json` 다시 다운로드 및 적용
4. ✅ Google Sign-In 정상 작동 확인
