# Firebase Console에서 Google Sign-In 설정하기

## ✅ 설정 완료 (2025-12-16)

**Google Sign-In 설정이 완료되었고 정상 작동 중입니다.**

## 프로젝트 정보

- **Firebase 프로젝트**: `credo-ceda9` (Project Number: 182699877294)
- **Android 패키지 이름**: `com.itz.credo`
- **SHA-1 인증서**: `61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A`

## 최종 설정 상태

### OAuth Client IDs
- ✅ **Android Client** (`client_type: 1`): `182699877294-k867euifu2i799aroak3bnpig39i49h1.apps.googleusercontent.com`
- ✅ **Web Client** (`client_type: 3`): `182699877294-cok4t52b66k9atp9u2n8es6o87d6dj5m.apps.googleusercontent.com`
- ✅ **iOS Client** (`client_type: 2`): `182699877294-4fpobp2ijkdjaijt6ttfjo02o7v6cvg2.apps.googleusercontent.com`

### 해결 방법 요약
1. Firebase Console에서 SHA 인증서 추가
2. Firebase가 자동으로 Android OAuth Client 생성
3. `google-services.json` 다시 다운로드 및 적용
4. Google Sign-In 정상 작동 확인

---

## 참고: 설정 방법 (이전 내용)

## 해결 방법: Firebase Console에서 직접 설정

Firebase Console에서 Google Sign-In을 활성화하면 자동으로 필요한 OAuth Client ID가 생성됩니다.

### 1. Firebase Console에서 Google Sign-In 활성화

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. 프로젝트: `credo-ceda9` 선택
3. **Authentication** (인증) 메뉴 클릭
4. **Sign-in method** (로그인 방법) 탭 선택
5. **Google** 제공업체 찾기
6. **Google** 클릭하여 설정 열기
7. **Enable** (사용 설정) 토글을 **ON**으로 설정
8. **프로젝트 지원 이메일** 선택 (또는 입력)
9. **저장** 클릭

### 2. SHA 인증서 확인

Firebase Console에서 Google Sign-In을 활성화하면:
- Firebase가 자동으로 Google Cloud 프로젝트를 생성하거나 연결합니다
- 필요한 OAuth Client ID가 자동으로 생성됩니다

하지만 **SHA 인증서는 여전히 수동으로 추가해야 합니다**:

1. Firebase Console → 프로젝트 설정 → 일반 탭
2. Android 앱 (`com.itz.credo`) 선택
3. **SHA 인증서 지문** 섹션에서 **디지털 지문 추가** 클릭
4. 올바른 SHA-1 추가:
   ```
   61:DB:3E:CE:CE:32:D9:21:57:58:20:49:5A:6C:8A:64:8E:5C:1D:3A
   ```
5. **저장** 클릭

### 3. google-services.json 다시 다운로드

1. Firebase Console → 프로젝트 설정 → 일반 탭
2. Android 앱 섹션에서 **google-services.json** 다운로드 버튼 클릭
3. 다운로드한 파일을 `android/app/google-services.json`에 덮어쓰기

### 4. 앱 재시작

1. 앱 완전히 종료
2. 앱 재시작
3. Google Sign-In 다시 시도

## 중요 사항

**Firebase Console에서 Google Sign-In을 활성화하면 자동으로 필요한 OAuth 설정이 완료됩니다.**

Google Cloud Console에서 수동으로 OAuth Client ID를 만들 필요가 없습니다. Firebase가 자동으로 처리합니다.

다만 **SHA 인증서는 반드시 Firebase Console에 추가해야 합니다.**
