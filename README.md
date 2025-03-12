# AIM Test App

AIM Coding Test Project입니다.

## 📌 개발 환경
- **운영체제**: Windows
- **개발툴**: IntelliJ IDEA 2021.2.3
- **Flutter 버전**: 3.27.3
- **Dart 버전**: 3.6.1

### 주요 기능
- 회원가입 및 로그인 (`id`, `password`, `휴대폰 번호`, `이메일` validation 포함)
- 로그인정보 저장
- 자산 배분 화면 (`Pie Chart` 라이브러리는 fl_chart 사용)
- 자산 비율 상세보기 (포트폴리오 목록)
- 특정 자산 클릭 시 해당 주식/채권 목록 상세보기

## 📌 사용 된 라이브러리
- **State Management**: `flutter_riverpod`
- **Networking**: `dio`
- **Storage**: `encrypted_shared_preferences`
- **UI Components**: `fl_chart` (파이 차트)
- **Form Validation**: `flutter_form_builder`
