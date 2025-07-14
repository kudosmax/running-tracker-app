# 🏃‍♂️ Running Tracker - 설정 가이드

## Firebase 설정

### 1. Firebase 프로젝트 생성
1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: `running-tracker`
4. Google Analytics 활성화 (선택사항)

### 2. Authentication 설정
1. Firebase Console → Authentication → Get started
2. Sign-in method 탭에서 다음 활성화:
   - **Email/Password**: 활성화
   - **Google**: 활성화 (프로젝트 지원 이메일 설정)
   - **GitHub**: 활성화 (GitHub OAuth App 필요)

### 3. Realtime Database 설정
1. Firebase Console → Realtime Database → 데이터베이스 만들기
2. 위치: `asia-southeast1` 선택
3. 보안 규칙을 다음과 같이 설정:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### 4. Firebase Configuration
1. 프로젝트 설정 → 일반 탭
2. "내 앱" 섹션에서 각 플랫폼별 앱 추가:
   - Web
   - Android  
   - iOS

3. 각 플랫폼의 config 정보를 `lib/firebase_options.dart`에 업데이트

## GitHub OAuth 설정

### 1. GitHub OAuth App 생성
1. GitHub → Settings → Developer settings → OAuth Apps
2. "New OAuth App" 클릭
3. 설정:
   - **Application name**: `Running Tracker`
   - **Homepage URL**: `https://your-domain.com`
   - **Authorization callback URL**: 
     - Web: `https://run-tracker-c16ee.firebaseapp.com/__/auth/handler`
     - Mobile: Firebase에서 제공하는 Deep Link URL

### 2. Firebase에 GitHub 설정
1. Firebase Console → Authentication → Sign-in method
2. GitHub 활성화
3. Client ID와 Client Secret 입력 (GitHub OAuth App에서 생성)

## Google OAuth 설정

### 1. Google Cloud Console 설정
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 선택 (Firebase와 동일한 프로젝트)
3. APIs & Services → Credentials
4. OAuth 2.0 Client IDs 생성:
   - **Web application** (웹용)
   - **Android** (안드로이드용)
   - **iOS** (iOS용)

### 2. 승인된 리디렉션 URI 설정
- Web: `https://run-tracker-c16ee.firebaseapp.com/__/auth/handler`
- Android: `com.googleusercontent.apps.YOUR_ANDROID_CLIENT_ID`
- iOS: Bundle ID 사용

## 앱 설정

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 플랫폼별 설정

#### Android
1. `android/app/google-services.json` 파일 추가
2. `android/app/build.gradle`에 Google Services 플러그인 추가
3. SHA-1 fingerprint를 Firebase Console에 추가

#### iOS
1. `ios/Runner/GoogleService-Info.plist` 파일 추가
2. URL Scheme 설정
3. Bundle ID 확인

#### Web
1. `web/index.html`에 Firebase SDK 스크립트 추가
2. Firebase config 객체 추가

### 3. 실행
```bash
flutter run
```

## 보안 주의사항

1. **API 키 보호**: 실제 배포 시 API 키를 환경 변수로 관리
2. **도메인 제한**: Firebase 콘솔에서 승인된 도메인만 설정
3. **Database 규칙**: 사용자별 데이터 접근 제한 확인
4. **GitHub Secret**: GitHub OAuth App의 Client Secret은 안전하게 보관

## 문제 해결

### 일반적인 오류
- **Firebase 연결 실패**: firebase_options.dart의 설정 확인
- **Google 로그인 실패**: SHA-1 fingerprint 및 OAuth Client ID 확인
- **GitHub 로그인 실패**: Callback URL 및 Client ID/Secret 확인
- **Database 권한 오류**: Realtime Database 보안 규칙 확인

### 디버깅 팁
- Firebase Console의 Authentication 탭에서 사용자 로그인 상태 확인
- 개발자 도구에서 네트워크 요청 확인
- Flutter의 debugPrint 출력 확인