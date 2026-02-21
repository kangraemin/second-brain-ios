# Second Brain iOS - Development Guide

## 1. 개발 원칙

### 1.1 단계별 개발 (Phased Development)
- 모든 개발은 **큰 단계(Phase) → 작은 단계(Step)** 로 쪼개서 진행한다.
- 각 단계는 **의미 단위**로 구성한다. 하나의 단계 = 하나의 기능 또는 하나의 관심사.
- 한 단계에서 여러 관심사를 섞지 않는다.

### 1.2 테스트 주도 단계 완료
- 모든 단계는 **해당 단계가 완료되었음을 증명하는 테스트**가 있어야 한다.
- 테스트가 **모두 통과**해야만 다음 단계로 넘어간다.
- 테스트는 단계의 핵심 동작을 검증하며, 불필요한 테스트는 작성하지 않는다.

### 1.3 빌드 안정성
- **매 단계 완료 시점에 빌드가 성공**해야 한다.
- 빌드가 깨진 상태로 다음 단계에 진입하지 않는다.
- 컴파일 경고(warning)도 가능한 한 0으로 유지한다.

---

## 2. 아키텍처

### 2.1 TCA (The Composable Architecture)

```
App
├── Features/           # 기능 단위 모듈
│   ├── Home/
│   │   ├── HomeFeature.swift       # Reducer + State + Action
│   │   └── HomeView.swift          # SwiftUI View
│   ├── Search/
│   │   ├── SearchFeature.swift
│   │   └── SearchView.swift
│   ├── Save/
│   │   ├── SaveFeature.swift
│   │   └── SaveView.swift
│   └── Detail/
│       ├── DetailFeature.swift
│       └── DetailView.swift
├── Core/               # 공통 비즈니스 로직
│   ├── Models/         # 데이터 모델
│   ├── Services/       # 외부 의존성 (AI, DB, Network)
│   └── Extensions/     # Swift 확장
├── ShareExtension/     # Share Extension 타겟
├── SafariExtension/    # Safari Extension 타겟
└── Resources/          # 에셋, 로컬라이제이션
```

### 2.2 TCA 규칙

**Reducer 구조:**
```swift
@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        // 화면에 필요한 상태만 선언
    }

    enum Action {
        // 사용자 행동 + 내부 이벤트
        case onAppear
        case searchQueryChanged(String)
        case saveButtonTapped
        // delegate: 부모에게 전달할 이벤트
        case delegate(Delegate)

        enum Delegate {
            case itemSelected(SavedItem)
        }
    }

    @Dependency(\.aiService) var aiService
    @Dependency(\.storageService) var storageService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    // 비동기 작업
                }
            // ...
            }
        }
    }
}
```

**View 구조:**
```swift
struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        // store.state로 직접 접근
        // store.send(.action)으로 이벤트 전달
    }
}
```

**지켜야 할 것:**
- View에 비즈니스 로직 금지. 모든 로직은 Reducer에서 처리.
- Side Effect는 반드시 `Effect`로 표현. Reducer body 밖에서 async 호출 금지.
- State는 반드시 `Equatable`. 불필요한 렌더링 방지.
- 자식 Feature 간 통신은 `Delegate` Action 패턴 사용.

---

## 3. DI (Dependency Injection)

### 3.1 Factory 라이브러리 사용

TCA의 `@Dependency`와 Factory를 **함께** 사용한다.

**TCA Dependency 등록 (주요 서비스):**
```swift
// Dependencies.swift
extension DependencyValues {
    var aiService: AIServiceProtocol {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}

private enum AIServiceKey: DependencyKey {
    static let liveValue: AIServiceProtocol = AIService()
    static let testValue: AIServiceProtocol = MockAIService()
}
```

**Factory Container (비-TCA 영역):**
```swift
extension Container {
    var storageService: Factory<StorageServiceProtocol> {
        Factory(self) { StorageService() }
    }

    var embeddingService: Factory<EmbeddingServiceProtocol> {
        Factory(self) { EmbeddingService() }
    }
}
```

### 3.2 DI 규칙
- 모든 서비스는 **Protocol로 추상화**한다.
- 구현체를 직접 생성하지 않는다. 반드시 DI를 통해 주입받는다.
- 테스트에서는 Mock 구현체를 주입한다.
- Reducer에서는 `@Dependency`, 그 외에서는 `@Injected`를 사용한다.

```swift
// Good
@Dependency(\.aiService) var aiService

// Bad
let aiService = AIService()  // 직접 생성 금지
```

---

## 4. 코딩 컨벤션 (Kodeco Swift Style Guide 기반)

### 4.1 네이밍
- **타입명**: UpperCamelCase (`SavedItem`, `HomeFeature`)
- **변수/함수명**: lowerCamelCase (`savedItems`, `fetchRecentItems()`)
- **약어**: 2글자는 전부 대문자 (`ID`, `URL`), 3글자 이상은 CamelCase (`Http`)
- **Bool**: `is`, `has`, `should` 접두어 (`isLoading`, `hasResults`)
- **Protocol**: 명사 또는 `~able`/`~ing` (`Searchable`, `StorageServiceProtocol`)

### 4.2 구조
- 한 파일 = 하나의 주요 타입. 관련 extension은 같은 파일에 허용.
- MARK 주석으로 섹션 구분:
```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
```

### 4.3 스타일
- 들여쓰기: **스페이스 4칸** (탭 아님)
- 줄 길이: **120자** 이하 권장
- 후행 쉼표 사용:
```swift
let colors = [
    "red",
    "green",
    "blue",  // 후행 쉼표
]
```
- `self` 사용: 컴파일러가 요구할 때만 (클로저 캡처 등)
- 타입 추론 활용: 타입이 명확하면 생략
```swift
// Good
let message = "hello"
// Bad
let message: String = "hello"
```

### 4.4 SwiftUI 컨벤션
- View body는 가능한 한 짧게. 복잡하면 서브뷰로 분리.
- 서브뷰는 `private` computed property 또는 별도 struct.
- modifier 체이닝은 한 줄에 하나씩:
```swift
Text("Hello")
    .font(.title)
    .foregroundStyle(.primary)
    .padding()
```

---

## 5. 주석 가이드

### 5.1 원칙
- **코드가 "무엇을"** 하는지는 코드 자체로 표현한다.
- **코드가 "왜"** 그렇게 하는지를 주석으로 설명한다.
- 자명한 코드에 주석 달지 않는다.

### 5.2 필수 주석
- **파일 헤더**: 파일의 역할을 한 줄로 설명
```swift
/// 온디바이스 AI를 통한 콘텐츠 요약/태그/분류 서비스
struct AIService: AIServiceProtocol { ... }
```
- **public API**: 외부에 노출되는 함수/프로퍼티에 `///` 문서 주석
```swift
/// 저장된 아이템에서 시맨틱 검색을 수행한다.
/// - Parameter query: 자연어 검색 쿼리 (예: "그 파스타 레시피")
/// - Returns: 유사도 순으로 정렬된 검색 결과
func search(query: String) async throws -> [SearchResult]
```
- **비자명한 로직**: 복잡한 알고리즘, 우회(workaround), 의도적인 선택
```swift
// NLContextualEmbedding은 빈 문자열에 crash하므로 guard 필요
guard !text.isEmpty else { return [] }
```

### 5.3 금지
- 주석 처리된 코드 (`// let old = ...`) — 삭제한다.
- 변경 이력 주석 (`// 2026.02.21 수정`) — Git이 관리한다.
- 자명한 주석 (`// 아이템 개수를 반환` 같은 것)

---

## 6. 테스트 가이드

### 6.1 테스트 프레임워크
- **Swift Testing** (`@Test`, `#expect`) 기본 사용
- TCA의 `TestStore`를 활용한 Reducer 테스트

### 6.2 테스트 구조
```swift
@Test("검색 쿼리 입력 시 결과가 업데이트된다")
func searchQueryUpdatesResults() async {
    let store = TestStore(initialState: SearchFeature.State()) {
        SearchFeature()
    } withDependencies: {
        $0.storageService = MockStorageService()
    }

    await store.send(.searchQueryChanged("파스타")) {
        $0.query = "파스타"
    }

    await store.receive(.searchResultsLoaded(mockResults)) {
        $0.results = mockResults
    }
}
```

### 6.3 테스트 범위
| 대상 | 필수 여부 | 방법 |
|------|----------|------|
| Reducer 로직 | **필수** | `TestStore`로 State/Action 검증 |
| Service 로직 | **필수** | Mock 의존성 주입 후 단위 테스트 |
| View | 선택 | Snapshot 테스트 (필요 시) |
| 통합 테스트 | 단계 완료 시 | 핵심 시나리오 E2E 검증 |

### 6.4 테스트 네이밍
- 함수명으로 **행동과 기대 결과**를 표현:
```swift
@Test("빈 쿼리로 검색하면 전체 아이템을 반환한다")
func emptyQueryReturnsAllItems() async { ... }
```

### 6.5 Mock 규칙
- 모든 외부 서비스는 Protocol + Mock 쌍으로 존재한다.
- Mock은 `Tests/Mocks/` 디렉토리에 모아둔다.
- Mock은 테스트에 필요한 최소한의 동작만 구현한다.

---

## 7. Git 컨벤션

### 7.1 브랜치
- `main`: 항상 빌드 성공 상태
- `develop`: 개발 통합 브랜치
- `feature/단계명`: 각 개발 단계별 브랜치

### 7.2 커밋 메시지
```
type(scope): 간결한 설명

본문 (선택)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**type:**
- `feat`: 새 기능
- `fix`: 버그 수정
- `refactor`: 리팩토링 (동작 변경 없음)
- `test`: 테스트 추가/수정
- `chore`: 빌드, 설정 등
- `docs`: 문서

### 7.3 단계 완료 시
- 해당 단계의 모든 테스트 통과 확인
- 빌드 성공 확인
- `develop`에 머지
- 태그: `phase-X.step-Y`

---

## 8. 프로젝트 구성 요약

| 항목 | 선택 |
|------|------|
| 언어 | Swift 6 |
| UI | SwiftUI |
| 아키텍처 | TCA (The Composable Architecture) |
| DI | Factory + TCA Dependencies |
| 로컬 DB | SwiftData |
| AI 처리 | Apple Foundation Models (iOS 26+) |
| 시맨틱 검색 | NLContextualEmbedding (iOS 17+) |
| 테스트 | Swift Testing + TCA TestStore |
| 최소 타겟 | iOS 26 |
| 코딩 스타일 | Kodeco Swift Style Guide |
| 패키지 관리 | Swift Package Manager |

---

## 9. 단계 진행 체크리스트

각 단계를 완료하기 전에 반드시 확인:

- [ ] 해당 단계의 기능이 의미 단위로 완성되었는가?
- [ ] 단계 완료를 증명하는 테스트가 작성되었는가?
- [ ] 모든 테스트가 통과하는가?
- [ ] 빌드가 성공하는가? (warning 0)
- [ ] DI 규칙을 지켰는가? (직접 생성 없음, Protocol 추상화)
- [ ] 코딩 컨벤션을 따랐는가?
- [ ] 필요한 주석이 달려있는가? (why 위주)
- [ ] 불필요한 코드/주석이 없는가?
