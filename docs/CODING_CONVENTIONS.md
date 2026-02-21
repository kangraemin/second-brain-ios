# Coding Conventions

Stash iOS 프로젝트의 코딩 컨벤션.

---

## 1. 네이밍

### Swift 일반

| 대상 | 규칙 | 예시 |
|------|------|------|
| 타입 (struct, class, enum, protocol) | UpperCamelCase | `SavedContent`, `ContentType` |
| 함수, 변수, 상수 | lowerCamelCase | `fetchContent()`, `searchQuery` |
| 전역 상수 | lowerCamelCase | `defaultPageSize` |
| 약어 | 2글자 이하면 대문자 유지 | `urlString`, `htmlParser`, `id` |

### TCA 네이밍

| 대상 | 규칙 | 예시 |
|------|------|------|
| Feature (Reducer) | `{화면명}Feature` | `HomeFeature`, `SearchFeature` |
| View | `{화면명}View` | `HomeView`, `SearchView` |
| Action - 사용자 이벤트 | `{동사}{목적어}` | `saveButtonTapped`, `searchQueryChanged` |
| Action - 위임/내부 | `{명사}{결과}` | `contentSaveResponse`, `searchResultLoaded` |
| Action - 자식 연결 | `{자식명}(action:)` | `detail(action:)` |
| Client | `{도메인}Client` | `ContentClient`, `EmbeddingClient` |

### SwiftData 네이밍

| 대상 | 규칙 | 예시 |
|------|------|------|
| 모델 | `SD{도메인명}` 접두사 | `SDContent`, `SDCategory` |
| 도메인 모델 | 접두사 없음 | `SavedContent`, `Category` |

SwiftData 모델과 도메인 모델을 구분하기 위해 `SD` 접두사를 사용한다.

---

## 2. 파일 구성

### 파일당 하나의 주요 타입

- 하나의 파일에 하나의 주요 타입만 정의한다.
- 관련된 작은 타입(내부 enum 등)은 같은 파일에 둘 수 있다.
- Extension은 같은 파일 또는 `+{프로토콜명}.swift`로 분리한다.

### TCA Feature 파일 구성

```
HomeFeature.swift   → Reducer, State, Action 정의
HomeView.swift      → SwiftUI View
```

State/Action이 커지면 분리 가능:
```
HomeFeature.swift        → Reducer 본체
HomeFeature+State.swift  → State 정의
HomeFeature+Action.swift → Action 정의
```

---

## 3. 코드 스타일

### 접근 제어

- 외부 모듈에 노출할 필요 없으면 `internal` (기본값, 명시하지 않음).
- 파일 내부에서만 사용하면 `private`.
- `public`은 모듈 경계를 넘어야 할 때만.
- **`open`은 사용하지 않는다.**

### 옵셔널 처리

```swift
// Good: guard let으로 early return
guard let url = item.url else { return }

// Good: if let 짧은 바인딩
if let title = content.title {
    // use title
}

// Bad: 강제 언래핑
let url = item.url!
```

### 클로저

```swift
// 후행 클로저 (단일)
items.filter { $0.isActive }

// 후행 클로저 (다중 인자) - 명시적 레이블 사용
Button {
    store.send(.saveButtonTapped)
} label: {
    Text("저장")
}
```

### import 정렬

```swift
import ComposableArchitecture    // 1. 서드파티
import SwiftData                 // 2. Apple 프레임워크
import SwiftUI

// (빈 줄 없이 알파벳 순)
```

---

## 4. TCA 규칙

### Effect 사용

```swift
// Side effect는 반드시 Effect로 래핑
case .saveButtonTapped:
    return .run { [content = state.content] send in
        try await contentClient.save(content)
        await send(.contentSaveResponse(.success(())))
    } catch: { error, send in
        await send(.contentSaveResponse(.failure(error)))
    }

// 동기 작업은 Effect 없이 직접 State 변경
case .searchQueryChanged(let query):
    state.searchQuery = query
    return .none
```

### Navigation

TCA의 `@Presents` / `StackState`를 사용한다:

```swift
// 모달
@Presents var detail: DetailFeature.State?

// 네비게이션 스택
var path = StackState<Path.State>()
```

---

## 5. SwiftUI 규칙

### View 크기 제한

- 하나의 View `body`가 100줄을 넘으면 하위 View로 분리한다.
- 분리 기준: 재사용 가능성이 없어도, 가독성을 위해 분리.

### Preview

```swift
#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
```

모든 View에 Preview를 작성한다. TCA Store를 주입해서 다양한 상태를 미리 볼 수 있게 한다.

---

## 6. 에러 처리

### 패턴

```swift
// Domain 에러 타입 정의
enum StashError: Error, Equatable {
    case parsingFailed(url: String)
    case saveFailed
    case embeddingFailed
    case contentNotFound
}

// Reducer에서 Result 타입으로 처리
case .contentSaveResponse(.failure(let error)):
    state.alert = AlertState {
        TextState("저장 실패")
    }
    return .none
```

### 규칙

- 에러는 도메인별로 `enum`으로 정의한다.
- `Equatable`을 준수해야 TCA State에서 비교 가능하다.
- 사용자에게 보여줄 에러는 `AlertState`로 처리한다.

---

## 7. 주석 규칙

- **무엇(What)**이 아니라 **왜(Why)**를 적는다.
- 자명한 코드에는 주석을 달지 않는다.
- `// MARK: -`로 섹션을 구분한다 (Reducer, View 내부).
- TODO는 `// TODO: 설명`으로 남기고, 가능하면 이슈 번호 포함.
