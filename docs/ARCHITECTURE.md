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
│   └── AppFeature.swift        # 루트 TCA Feature
│
├── Features/                   # TCA Feature 모듈 (화면 단위)
│   ├── Home/
│   │   ├── HomeFeature.swift   # Reducer + State + Action
│   │   └── HomeView.swift
│   ├── Search/
│   ├── Detail/
│   ├── CategoryList/
│   └── Settings/
│
├── Domain/                     # 비즈니스 로직
│   ├── Models/                 # 도메인 모델 (순수 Swift 타입)
│   ├── ContentParsing/         # URL/콘텐츠 파싱 로직
│   └── Services/               # Protocol 정의 (추상화 계층)
│
├── Data/                       # 데이터 계층
│   ├── SwiftData/              # SwiftData 모델 + 저장소 구현
│   ├── Clients/                # TCA DependencyClient 구현
│   └── Mappers/                # SwiftData 모델 ↔ 도메인 모델 변환
│
├── ML/                         # Core ML 관련
│   ├── EmbeddingService/       # 텍스트 임베딩 생성
│   ├── VectorSearch/           # 벡터 유사도 검색
│   └── Models/                 # .mlmodel 파일
│
├── ShareExtension/             # Share Extension 타겟
│   ├── ShareViewController.swift
│   └── ShareFeature.swift      # Share Extension용 TCA Feature
│
├── Shared/                     # 메인 앱 + Extension 공유 코드
│   ├── AppGroup/               # App Group 설정, 공유 컨테이너
│   └── Common/                 # 공통 유틸, 확장
│
└── Resources/                  # 에셋, 로컬라이제이션
```

---

## 3. 핵심 아키텍처 패턴

### TCA Feature 구조

모든 화면은 TCA Feature로 구성한다:

```swift
@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        // 화면 상태
    }

    enum Action {
        // 사용자 액션 + 내부 액션
    }

    @Dependency(\.contentClient) var contentClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // 로직
        }
    }
}
```

### 의존성 주입 (DI)

TCA의 `@Dependency` 시스템을 사용한다:

```swift
// 1. Client Protocol 정의 (Domain/Services/)
struct ContentClient {
    var save: @Sendable (SavedContent) async throws -> Void
    var fetch: @Sendable () async throws -> [SavedContent]
    var search: @Sendable (String) async throws -> [SavedContent]
}

// 2. DependencyKey 등록 (Data/Clients/)
extension ContentClient: DependencyKey {
    static let liveValue = ContentClient(...)
    static let testValue = ContentClient(...)  // 테스트용
}

// 3. Reducer에서 사용
@Dependency(\.contentClient) var contentClient
```

**규칙:**
- Reducer에서 외부 의존성에 직접 접근하지 않는다. 반드시 `@Dependency`로 주입.
- 모든 Client는 `testValue`를 제공해야 한다.

### 데이터 흐름

```
[Share Extension] → App Group Container → [SwiftData]
                                              ↓
[Main App] → TCA Feature → Client → [SwiftData] → 도메인 모델
                                         ↓
                              [Core ML Embedding] → 벡터 검색
```

---

## 4. Share Extension 설계

Share Extension은 **별도 타겟**으로, 메인 앱과 App Group을 통해 데이터를 공유한다.

- **App Group ID**: `group.com.kangraemin.stash`
- SwiftData의 `ModelContainer`를 App Group 컨테이너 경로에 생성
- Share Extension에서 저장 → 메인 앱에서 즉시 접근 가능

### 콘텐츠 파싱 파이프라인

```
URL 입력 → ContentParser → ContentType 판별 → 메타데이터 추출 → SavedContent 생성
```

**ContentType** (지원 소스):
- `.youtube` → 영상 제목, 썸네일, 채널명
- `.instagram` → 포스트/릴스 메타데이터
- `.naverMap` / `.googleMap` → 장소명, 좌표, 카테고리
- `.coupang` → 상품명, 가격, 이미지
- `.safari` / `.web` → OG 태그 기반 메타데이터 (범용)

---

## 5. 시맨틱 검색 설계

### 온디바이스 파이프라인

```
콘텐츠 저장 시:
  텍스트 → Core ML 임베딩 모델 → 벡터 → SwiftData에 저장

검색 시:
  검색어 → Core ML 임베딩 → 쿼리 벡터 → 코사인 유사도 → 정렬된 결과
```

- 임베딩 모델: Apple의 NLEmbedding 또는 커스텀 Core ML 모델
- 벡터 저장: SwiftData 모델에 `[Float]` 필드로 저장
- 검색: 코사인 유사도 기반 가장 유사한 콘텐츠 반환

---

## 6. 딥링크 설계

저장된 콘텐츠에서 원본 앱으로 이동:

| 소스 | 딥링크 방식 |
|------|-----------|
| YouTube | `youtube://` URL scheme 또는 Universal Link |
| Instagram | `instagram://` URL scheme |
| 네이버지도 | `nmap://` URL scheme |
| 구글맵 | `comgooglemaps://` URL scheme |
| 쿠팡 | `coupang://` URL scheme |
| 기타 | Safari로 원본 URL 열기 (fallback) |

**규칙**: 앱이 설치되어 있으면 딥링크, 없으면 웹 URL로 fallback.

---

## 7. 모듈 의존성 방향

```
App → Features → Domain ← Data
                    ↑        ↑
                    ML    SwiftData

ShareExtension → Shared → Domain ← Data
```

- **Domain**은 어떤 것에도 의존하지 않는다 (순수 Swift).
- **Features**는 Domain에만 의존한다 (Data 직접 참조 금지).
- **Data**는 Domain의 Protocol을 구현한다.
