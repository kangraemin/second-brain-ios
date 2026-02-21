# Architecture

Stash iOS 앱의 아키텍처 가이드.

---

## 1. 기술 스택

| 항목 | 선택 |
|------|------|
| UI | SwiftUI |
| 아키텍처 | TCA (The Composable Architecture) |
| 데이터 | SwiftData (로컬 우선) |
| AI/검색 | Core ML (온디바이스 임베딩 + 시맨틱 검색) |
| 최소 타겟 | iOS 17+ |

---

## 2. 프로젝트 구조

```
Stash/
├── App/                        # 앱 진입점
│   ├── StashApp.swift
│   └── AppFeature.swift
│
├── Features/                   # TCA Feature 모듈 (화면 단위)
│   ├── Home/
│   │   ├── HomeFeature.swift
│   │   └── HomeView.swift
│   ├── Search/
│   ├── Detail/
│   ├── CategoryList/
│   └── Settings/
│
├── Domain/                     # 비즈니스 로직 (순수 Swift, 외부 의존 없음)
│   ├── Models/                 # 도메인 모델
│   ├── ContentParsing/         # URL/콘텐츠 파싱
│   └── Services/               # Client Protocol 정의
│
├── Data/                       # 데이터 계층
│   ├── SwiftData/              # SwiftData 모델 + 저장소
│   ├── Clients/                # TCA DependencyClient 구현
│   └── Mappers/                # SwiftData ↔ 도메인 모델 변환
│
├── ML/                         # Core ML
│   ├── EmbeddingService/
│   └── VectorSearch/
│
├── ShareExtension/             # Share Extension 타겟
│
├── Shared/                     # 메인 앱 + Extension 공유
│   └── AppGroup/
│
└── Resources/
```

---

## 3. TCA Feature 패턴

```swift
@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable { }
    enum Action { }
    @Dependency(\.contentClient) var contentClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in }
    }
}
```

---

## 4. 의존성 주입 (DI)

TCA `@Dependency` 시스템 사용:

```swift
// Protocol 정의 (Domain/Services/)
struct ContentClient {
    var save: @Sendable (SavedContent) async throws -> Void
    var fetch: @Sendable () async throws -> [SavedContent]
}

// 구현 등록 (Data/Clients/)
extension ContentClient: DependencyKey {
    static let liveValue = ContentClient(...)
    static let testValue = ContentClient(...)
}
```

**규칙**: Reducer에서 외부 의존성 직접 접근 금지. 반드시 `@Dependency`로 주입.

---

## 5. 데이터 흐름

```
[Share Extension] → App Group Container → [SwiftData]
                                              ↓
[Main App] → TCA Feature → Client → [SwiftData] → 도메인 모델
                                         ↓
                              [Core ML Embedding] → 벡터 검색
```

- Share Extension: URL만 저장 (120MB 메모리 제한)
- 메인 앱: 메타데이터 추출, 임베딩 생성 등 무거운 작업 처리
- App Group ID: `group.com.kangraemin.stash`

---

## 6. 콘텐츠 타입 + 딥링크

| ContentType | 소스 | 딥링크 |
|-------------|------|--------|
| `.youtube` | youtube.com, youtu.be | Universal Link |
| `.instagram` | instagram.com | Universal Link |
| `.naverMap` | map.naver.com, naver.me | `nmap://` scheme |
| `.googleMap` | maps.google.com, maps.app.goo.gl | Universal Link |
| `.coupang` | coupang.com, coupa.ng | Universal Link |
| `.web` | 기타 | Safari |

---

## 7. 모듈 의존성 방향

```
App → Features → Domain ← Data
                    ↑        ↑
                    ML    SwiftData

ShareExtension → Shared → Domain ← Data
```

- **Domain**은 어떤 것에도 의존하지 않는다 (순수 Swift).
- **Features**는 Domain에만 의존한다.
- **Data**는 Domain의 Protocol을 구현한다.
