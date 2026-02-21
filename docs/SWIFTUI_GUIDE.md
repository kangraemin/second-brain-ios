# SwiftUI + TCA Guide

Stash에서의 SwiftUI와 TCA 사용 패턴.

---

## 1. View + Store 연결

### 기본 패턴

```swift
struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            // 콘텐츠
        }
    }
}
```

- iOS 17+ `@Bindable` + `@ObservableState` 조합 사용.
- `WithViewStore`는 사용하지 않는다 (레거시).

### Action 전송

```swift
Button("저장") {
    store.send(.saveButtonTapped)
}

TextField("검색", text: $store.searchQuery.sending(\.searchQueryChanged))
```

---

## 2. Navigation 패턴

### 스택 네비게이션

```swift
@Reducer
struct AppFeature {
    @Reducer
    enum Path {
        case detail(DetailFeature)
        case category(CategoryFeature)
    }

    @ObservableState
    struct State {
        var path = StackState<Path.State>()
    }
}
```

### 모달 / Sheet

```swift
@ObservableState
struct State {
    @Presents var addContent: AddContentFeature.State?
}

// View에서
.sheet(item: $store.scope(state: \.addContent, action: \.addContent)) { store in
    AddContentView(store: store)
}
```

---

## 3. 리스트 패턴

### IdentifiedArray 사용

```swift
@ObservableState
struct State {
    var contents: IdentifiedArrayOf<ContentRowFeature.State> = []
}

// View
ForEach(store.scope(state: \.contents, action: \.contents)) { rowStore in
    ContentRowView(store: rowStore)
}
```

- 리스트 아이템이 자체 로직을 가지면 별도 Feature로 분리.
- 단순 표시만 하면 도메인 모델을 직접 `ForEach`해도 된다.

---

## 4. 비동기 작업 패턴

### 화면 진입 시 데이터 로드

```swift
// Reducer
case .onAppear:
    return .run { send in
        let contents = try await contentClient.fetch()
        await send(.contentsLoaded(contents))
    }

// View
.onAppear { store.send(.onAppear) }
```

### 디바운스 검색

```swift
case .searchQueryChanged(let query):
    state.searchQuery = query
    return .run { send in
        try await clock.sleep(for: .milliseconds(300))
        let results = try await searchClient.search(query)
        await send(.searchResultLoaded(results))
    }
    .cancellable(id: CancelID.search, cancelInFlight: true)
```

---

## 5. Alert / ConfirmationDialog

```swift
// State
@Presents var alert: AlertState<Action.Alert>?

// Reducer
case .deleteConfirmed:
    state.alert = AlertState {
        TextState("삭제하시겠습니까?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDelete) {
            TextState("삭제")
        }
    }
    return .none

// View
.alert($store.scope(state: \.alert, action: \.alert))
```

---

## 6. Share Extension View

Share Extension은 제한된 환경이므로:

- 최소한의 UI만 구성 (저장 확인 + 카테고리 선택 정도).
- 무거운 작업(임베딩 생성 등)은 메인 앱에서 처리.
- `NSExtensionContext`에서 URL/텍스트 추출 → TCA Feature로 전달.

```swift
struct ShareView: View {
    let store: StoreOf<ShareFeature>

    var body: some View {
        NavigationStack {
            // 카테고리 선택, 메모 입력
            // 저장 버튼
        }
    }
}
```
