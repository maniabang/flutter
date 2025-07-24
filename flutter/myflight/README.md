# ✈️ travel-record-flutter

여행 기록 & 항공권 검색 Flutter 앱  
출입국 증명서 OCR → 국가/날짜 자동 추출 → 여행 기록 저장 → 항공권 최저가 검색까지 한 번에!

> **Flutter**로 만드는 실사용 가능한 여행 기록 플랫폼  
> 무료 OCR, 로컬 저장, 항공권 API 연동까지 모두 경험할 수 있습니다.

---

## 🎨 디자인

- (예시) [Figma 디자인 링크](https://www.figma.com/)  
  _디자인은 추후 업데이트 예정_

## 🚀 실행 방법

### 1. Flutter 설치

- **Homebrew로 설치 (macOS)**
  ```sh
  brew install --cask flutter
  ```
- 또는 [Flutter 공식 설치 가이드](https://docs.flutter.dev/get-started/install) 참고

## 🛠️ 사용 기술스택

- **Flutter** (크로스플랫폼 앱 프레임워크)
- **file_picker** (PDF/이미지 업로드)
- **google_ml_kit** (로컬 OCR, 한글 지원)
- **riverpod** (경량 상태관리)
- **dio** (API 호출, 항공권 API 연동)
- **hive** (로컬 데이터 저장)
- **PWA** (향후 웹 빌드 지원 예정)

---

## 📦 패키지 설치 순서

1. 프로젝트 생성
   `flutter create myflight`
2. 필수 패키지 설치
   `flutter pub add file_picker google_ml_kit riverpod dio hive`
3. 프로젝트 실행
  `flutter run`


---

## 🗺️ 1주일 완성 로드맵

| Day | 주요 목표                              |
| --- | -------------------------------------- |
| 1   | 기획, 개발 환경 세팅, 레포지토리 생성  |
| 2   | 필수 패키지 설치 및 프로젝트 구조 설계 |
| 3   | 파일 업로드 & OCR(텍스트 추출) 구현    |
| 4   | 파싱 로직 + 기본 UI                    |
| 5   | 로컬 저장/조회 기능                    |
| 6   | 항공권 API 연동 준비                   |
| 7   | 전체 통합, QA, APK 빌드                |

---

## ✈️ 추천 무료 항공권 API

- [Skyscanner Rapid API](https://rapidapi.com/skyscanner/api/skyscanner-flight-search)
- [Kiwi.com Tequila API](https://tequila.kiwi.com/portal/login)

## 🗒️ 향후 계획 & 체크리스트

- [ ] Flutter 프로젝트 생성 및 패키지 설치
- [ ] 파일 업로드 & OCR 기능 구현
- [ ] OCR 결과 파싱(국가/날짜) 및 UI 개발
- [ ] 로컬 저장/조회 기능
- [ ] 항공권 API 연동 및 리스트 출력
- [ ] 전체 통합, QA, APK 빌드

---

## 💡 개발 TIP

- OCR은 google_ml_kit 사용 (API키 불필요, 무료, 한글 인식률 높음)
- 복잡한 레이아웃은 Regex 후처리로 정확도 개선
- 모든 기능은 무료/오프라인 우선
```
