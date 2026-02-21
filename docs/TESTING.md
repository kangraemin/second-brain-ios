# Testing

Stash iOS 프로젝트의 테스트 가이드.

---

## 1. 테스트 프레임워크

| 용도 | 프레임워크 |
|------|-----------|
| 단위 테스트 | Swift Testing (`@Test`, `#expect`) |
| TCA Reducer 테스트 | `TestStore` (TCA 내장) |
| UI 테스트 | XCUITest (필요 시) |

---

## 2. TCA Reducer 테스트

### 기본 패턴

```swift
import ComposableArchitecture
import Testing

@Suite("HomeFeature Tests")
struct HomeFeatureTests {
    @Test("콘텐츠 저장 시 목록에 추가된다")
    func saveContent() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.save = { _ in }
            $0.contentClient.fetch = { [.mock] }
        }

        await store.send(.saveButtonTapped) {
            $0.isSaving = true
        }
        await store.receive(\.contentSaveResponse.success) {
            $0.isSaving = false
        }
    }
}
```

### TestStore 규칙

- **모든 State 변경을 검증한다.** TestStore는 예상하지 않은 State 변경 시 실패한다.
- **모든 Effect를 소진한다.** 처리하지 않은 Effect가 남으면 실패한다.
- **의존성을 명시적으로 주입한다.** `withDependencies`로 테스트용 구현 제공.

---

## 3. 테스트 네이밍

```swift
// Swift Testing 스타일
@Suite("{Feature} Tests")
struct SomeFeatureTests {
    @Test("한글로 동작을 설명한다")
    func descriptiveName() async { }
}
```

- `@Suite`에 Feature 이름.
- `@Test`에 **한글로** 테스트가 검증하는 동작을 설명.
- 함수명은 영어 camelCase.

---

## 4. 테스트 구성

### 파일 구조

```
StashTests/
├── Features/
│   ├── HomeFeatureTests.swift
│   ├── SearchFeatureTests.swift
│   └── DetailFeatureTests.swift
├── Domain/
│   ├── ContentParserTests.swift
│   └── DeepLinkTests.swift
├── Data/
│   └── ContentClientTests.swift
└── ML/
    └── EmbeddingServiceTests.swift
```

### Mock 데이터

```swift
// 도메인 모델에 테스트용 static factory
extension SavedContent {
    static let mock = SavedContent(
        title: "테스트 콘텐츠",
        url: "https://example.com",
        contentType: .web,
        createdAt: .now
    )

    static func mock(
        title: String = "테스트 콘텐츠",
        contentType: ContentType = .web
    ) -> Self {
        // ...
    }
}
```

---

## 5. 빌드 및 테스트 실행

```bash
# 전체 테스트 실행
xcodebuild test \
  -scheme Stash \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -resultBundlePath TestResults

# 특정 테스트 Suite 실행
xcodebuild test \
  -scheme Stash \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:StashTests/HomeFeatureTests

# 특정 테스트 메서드 실행
xcodebuild test \
  -scheme Stash \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:StashTests/HomeFeatureTests/saveContent

# 빌드만 (테스트 없이)
xcodebuild build \
  -scheme Stash \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## 6. 테스트 범위

### 필수 테스트 대상

| 대상 | 테스트 방법 |
|------|-----------|
| TCA Reducer | `TestStore` - 모든 Action/State 변경 검증 |
| ContentParser | 단위 테스트 - 각 ContentType별 파싱 검증 |
| 딥링크 생성 | 단위 테스트 - URL scheme 생성 검증 |
| 벡터 검색 | 단위 테스트 - 유사도 계산 정확성 |

### 테스트 제외 대상

- SwiftUI View 레이아웃 (Preview로 확인)
- SwiftData 모델 단순 CRUD (통합 테스트에서 커버)
- 순수 UI 인터랙션 (필요 시 XCUITest)

---

## 7. 단계 완료 조건

매 개발 단계(Step) 완료 시 반드시:

1. 해당 단계의 기능을 검증하는 테스트 작성
2. 모든 테스트 통과 (`xcodebuild test` 성공)
3. 빌드 성공 (`xcodebuild build` 성공, warning 0)
