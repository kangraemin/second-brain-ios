# SwiftUI + TCA Guide

---

## 1. View + Store

```swift
struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            // ...
        }
    }
}
```

- `@Bindable` + `@ObservableState` 조합 (iOS 17+).
- `WithViewStore` 사용하지 않음 (레거시).

---

## 2. Navigation

### 스택
```swift
@Reducer
enum Path {
    case detail(DetailFeature)
    case category(CategoryFeature)
}
var path = StackState<Path.State>()
```

### 모달
```swift
@Presents var addContent: AddContentFeature.State?

.sheet(item: $store.scope(state: \.addContent, action: \.addContent)) { store in
    AddContentView(store: store)
}
```

---

## 3. 리스트

```swift
ForEach(store.scope(state: \.contents, action: \.contents)) { rowStore in
    ContentRowView(store: rowStore)
}
```

`IdentifiedArrayOf` 사용.

---

## 4. 비동기

```swift
// 화면 진입
case .onAppear:
    return .run { send in
        let contents = try await contentClient.fetch()
        await send(.contentsLoaded(contents))
    }

// 디바운스 검색
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

## 5. Alert

```swift
@Presents var alert: AlertState<Action.Alert>?

.alert($store.scope(state: \.alert, action: \.alert))
```
