# Testing

---

## 1. 프레임워크

| 용도 | 프레임워크 |
|------|-----------|
| 단위 테스트 | Swift Testing (`@Test`, `#expect`) |
| TCA 테스트 | `TestStore` |
| UI 테스트 | XCUITest (필요 시) |

---

## 2. TCA TestStore 패턴

```swift
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
        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.contentSaveResponse.success) { $0.isSaving = false }
    }
}
```

- 모든 State 변경 검증.
- 모든 Effect 소진.
- 의존성 `withDependencies`로 주입.

---

## 3. 테스트 네이밍

- `@Suite`에 Feature 이름.
- `@Test`에 **한글로** 동작 설명.
- 함수명은 영어 camelCase.

---

## 4. Mock

```swift
extension SavedContent {
    static let mock = SavedContent(
        title: "테스트 콘텐츠", url: "https://example.com",
        contentType: .web, createdAt: .now
    )
}
```

---

## 5. 빌드/테스트 명령

```bash
# 빌드
xcodebuild build -scheme Stash -destination 'platform=iOS Simulator,name=iPhone 16'

# 전체 테스트
xcodebuild test -scheme Stash -destination 'platform=iOS Simulator,name=iPhone 16'

# 특정 테스트
xcodebuild test -scheme Stash -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:StashTests/HomeFeatureTests
```

---

## 6. 단계 완료 조건

매 Step 완료 시:
1. 해당 기능 검증 테스트 작성
2. 모든 테스트 통과
3. 빌드 성공, warning 0
