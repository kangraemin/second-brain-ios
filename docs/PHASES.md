# Phase 계획

---

## Phase 0: 프로젝트 셋업
상태: 대기 ⏳

Xcode 프로젝트 생성, 의존성 추가, 폴더 구조 확립. 모든 후속 작업의 기반.

### Step 0.1: Xcode 설치 및 프로젝트 생성
- 구현: Xcode 15+ 설치, iOS App 프로젝트 생성 (SwiftUI, iOS 17+, 번들 ID `com.kangraemin.stash`)
- 완료 기준: Xcode에서 빈 SwiftUI 앱이 시뮬레이터에서 빌드 및 실행 성공

### Step 0.2: SPM 의존성 추가
- 구현: `swift-composable-architecture` 패키지를 SPM으로 추가
- 완료 기준: TCA import 후 빌드 성공 (`import ComposableArchitecture` 컴파일 통과)

### Step 0.3: 폴더 구조 생성
- 구현: ARCHITECTURE.md 기준 폴더 구조 생성 (App/, Features/, Domain/, Data/, ML/, Shared/, Resources/)
- 완료 기준: 폴더 구조가 ARCHITECTURE.md와 일치, 빌드 성공 유지

### Step 0.4: App Group 설정
- 구현: App Group `group.com.kangraemin.stash` 추가, Share Extension 타겟 생성
- 완료 기준: 두 타겟 모두 빌드 성공, App Group capability 활성화

---

## Phase 1: 도메인 모델 + 데이터 계층
상태: 대기 ⏳

핵심 도메인 모델 정의, SwiftData 모델, Client Protocol, 저장소 구현. 앱의 데이터 기반 확립.

### Step 1.1: 도메인 모델 정의
- 구현: `SavedContent` 모델 (title, url, contentType, createdAt 등), `ContentType` enum 정의 (Domain/Models/)
- 완료 기준: 모델 정의 완료, 빌드 성공, `SavedContent.mock` 테스트 헬퍼 존재

### Step 1.2: ContentType 자동 분류 로직
- 구현: URL 도메인 기반 ContentType 판별 (Domain/ContentParsing/), YouTube/Instagram/네이버지도/구글맵/쿠팡 등 패턴 매칭
- 완료 기준: 각 소스 URL에 대한 ContentType 판별 테스트 통과

### Step 1.3: SwiftData 모델 정의
- 구현: `SDContent` (@Model), `SavedContent` ↔ `SDContent` 매퍼 (Data/SwiftData/, Data/Mappers/)
- 완료 기준: SwiftData 모델 컴파일 성공, 매퍼 변환 테스트 통과

### Step 1.4: ContentClient Protocol 정의
- 구현: `ContentClient` struct (save, fetch, delete 등) Protocol 정의 (Domain/Services/)
- 완료 기준: Protocol 정의 완료, testValue mock 포함, 빌드 성공

### Step 1.5: ContentClient 구현 (SwiftData)
- 구현: `ContentClient`의 liveValue 구현 (Data/Clients/), SwiftData ModelContainer 사용, App Group container 경로
- 완료 기준: liveValue 구현 완료, 빌드 성공

---

## Phase 2: 핵심 Feature - 홈 화면
상태: 대기 ⏳

TCA 기반 홈 화면 Feature 구현. 콘텐츠 목록 표시, 카테고리 필터링.

### Step 2.1: AppFeature 루트 설정
- 구현: `AppFeature` Reducer + `StashApp.swift` 진입점, AppFeature에서 HomeFeature 포함
- 완료 기준: 앱 실행 시 빈 HomeView 표시, 빌드 성공

### Step 2.2: HomeFeature Reducer
- 구현: `HomeFeature` (State: contents, selectedFilter / Action: onAppear, filterTapped 등), `@Dependency(\.contentClient)` 사용
- 완료 기준: TestStore 테스트 - onAppear 시 콘텐츠 로드, 필터 변경 시 State 업데이트

### Step 2.3: HomeView UI
- 구현: 검색바, 필터 칩 (전체/영상/장소/쇼핑/아티클/인스타), 2열 카드 그리드 (LazyVGrid)
- 완료 기준: HomeView에 필터 칩과 그리드가 표시됨, `#Preview` 작성, 빌드 성공

### Step 2.4: ContentCardView (소스별 카드)
- 구현: 소스별 카드 디자인 (YouTube 썸네일+제목, Instagram 이미지+캡션, 장소 이미지+주소, 쇼핑 상품+가격, 웹 OG이미지+제목)
- 완료 기준: 각 ContentType별 카드가 올바르게 렌더링, `#Preview` 작성, 빌드 성공

---

## Phase 3: Share Extension
상태: 대기 ⏳

다른 앱에서 1탭 저장 기능. Share Extension에서 URL 수신 → App Group 경유 SwiftData 저장.

### Step 3.1: Share Extension 진입점
- 구현: ShareViewController, URL 수신 및 파싱 (NSExtensionItem에서 URL 추출)
- 완료 기준: Share Extension 타겟 빌드 성공, URL 수신 로직 테스트 통과

### Step 3.2: App Group 경유 저장
- 구현: Share Extension에서 App Group SwiftData container에 URL 저장, 저장 완료 토스트 표시
- 완료 기준: Extension에서 저장한 콘텐츠가 메인 앱에서 조회 가능, 빌드 성공

### Step 3.3: 메인 앱 백그라운드 메타데이터 처리
- 구현: 메인 앱 진입 시 미처리 콘텐츠의 메타데이터(OG 태그, 썸네일 등) 추출 및 업데이트
- 완료 기준: Share Extension 저장 후 메인 앱에서 메타데이터가 채워진 카드 표시

---

## Phase 4: 상세 화면 + 딥링크
상태: 대기 ⏳

콘텐츠 상세 화면, 원본 앱으로의 딥링크, 삭제/편집 기능.

### Step 4.1: DetailFeature + DetailView
- 구현: 상세 화면 Reducer + View, 스택 네비게이션으로 홈에서 진입
- 완료 기준: 카드 탭 시 상세 화면 표시, TestStore 테스트 통과

### Step 4.2: 딥링크 구현
- 구현: ContentType별 딥링크 (Universal Link / URL scheme / Safari fallback)
- 완료 기준: 각 ContentType의 딥링크 URL 생성 테스트 통과

### Step 4.3: 콘텐츠 삭제
- 구현: 상세 화면 및 스와이프에서 삭제 기능, 삭제 확인 Alert
- 완료 기준: 삭제 후 목록에서 제거 확인, TestStore 테스트 통과

---

## Phase 5: 검색
상태: 대기 ⏳

키워드 검색 → 시맨틱 검색 순서로 구현. Core ML 온디바이스 임베딩.

### Step 5.1: 키워드 검색
- 구현: `SearchClient` Protocol + liveValue (localizedStandardContains 기반), 디바운스 적용
- 완료 기준: 검색 쿼리 입력 시 필터링된 결과 반환, TestStore 테스트 통과

### Step 5.2: Core ML 임베딩 서비스
- 구현: `EmbeddingService` (NLContextualEmbedding 기반), 콘텐츠 저장 시 임베딩 벡터 생성 및 저장
- 완료 기준: 텍스트 입력 시 벡터 생성, 빌드 성공

### Step 5.3: 벡터 검색 + 결과 병합
- 구현: 코사인 유사도 검색, 키워드 + 시맨틱 결과 병합 랭킹
- 완료 기준: 시맨틱 검색 결과 반환 테스트 통과, 병합 랭킹 테스트 통과

---

## Phase 6: 설정 + 마무리
상태: 대기 ⏳

설정 화면, 에러 처리, 빈 상태 UI, 최종 품질 다듬기.

### 개요
- 설정 화면 (SettingsFeature)
- 빈 상태 / 로딩 상태 UI
- 에러 처리 및 사용자 피드백
- 접근성 (VoiceOver, Dynamic Type)
- 성능 최적화 (이미지 캐싱, 대량 데이터 스크롤)
