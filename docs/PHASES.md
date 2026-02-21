# Phase 계획

---

## Phase 0: 프로젝트 셋업
상태: 완료 ✅

Xcode 프로젝트 생성, 의존성 추가, 폴더 구조 확립. 모든 후속 작업의 기반.

### Step 0.1: Xcode 설치
- 구현: Xcode 15+ 설치 (macOS 업그레이드 필요 시 포함)
- 완료 기준: `xcodebuild -version`으로 Xcode 15+ 확인

### Step 0.2: iOS App 프로젝트 생성
- 구현: Xcode에서 iOS App 프로젝트 생성 (SwiftUI, iOS 17+, 번들 ID `com.kangraemin.stash`)
- 완료 기준: 빈 SwiftUI 앱이 시뮬레이터에서 빌드 및 실행 성공

### Step 0.3: SPM 의존성 추가
- 구현: `swift-composable-architecture` 패키지를 SPM으로 추가
- 완료 기준: `import ComposableArchitecture` 컴파일 통과

### Step 0.4: 폴더 구조 생성
- 구현: ARCHITECTURE.md 기준 폴더 구조 생성 (App/, Features/, Domain/, Data/, ML/, Shared/, Resources/)
- 완료 기준: 폴더 구조가 ARCHITECTURE.md와 일치, 빌드 성공 유지

### Step 0.5: App Group capability 추가
- 구현: 메인 앱 타겟에 App Group `group.com.kangraemin.stash` capability 추가
- 완료 기준: App Group capability 활성화, 빌드 성공

### Step 0.6: Share Extension 타겟 생성
- 구현: Share Extension 타겟 추가, App Group capability 설정
- 완료 기준: 두 타겟(메인 앱 + Extension) 모두 빌드 성공

---

## Phase 1: 도메인 모델 + 데이터 계층
상태: 완료 ✅

핵심 도메인 모델 정의, SwiftData 모델, Client Protocol, 저장소 구현. 앱의 데이터 기반 확립.

### Step 1.1: ContentType enum 정의
- 구현: `ContentType` enum (youtube, instagram, naverMap, googleMap, coupang, web) (Domain/Models/ContentType.swift)
- 완료 기준: 빌드 성공

### Step 1.2: SavedContent 도메인 모델 정의
- 구현: `SavedContent` struct (id, title, url, contentType, createdAt 등) (Domain/Models/SavedContent.swift)
- 완료 기준: 빌드 성공

### Step 1.3: SavedContent mock 헬퍼
- 구현: `SavedContent.mock` static 프로퍼티 (테스트/프리뷰용)
- 완료 기준: mock 인스턴스 생성 테스트 통과

### Step 1.4: URL → ContentType 판별 로직
- 구현: URL 도메인 기반 ContentType 판별 함수 (Domain/ContentParsing/ContentTypeParser.swift)
- 완료 기준: YouTube, Instagram, 네이버지도, 구글맵, 쿠팡, 일반 웹 URL 판별 테스트 통과

### Step 1.5: SDContent SwiftData 모델
- 구현: `SDContent` (@Model) SwiftData 모델 정의 (Data/SwiftData/SDContent.swift)
- 완료 기준: 빌드 성공

### Step 1.6: SDContent ↔ SavedContent 매퍼
- 구현: `SDContent` → `SavedContent`, `SavedContent` → `SDContent` 변환 (Data/Mappers/ContentMapper.swift)
- 완료 기준: 양방향 변환 테스트 통과

### Step 1.7: ContentClient Protocol 정의
- 구현: `ContentClient` struct (save, fetch, delete) + DependencyKey 등록 + testValue mock (Domain/Services/ContentClient.swift)
- 완료 기준: 빌드 성공, testValue 존재

### Step 1.8: ContentClient liveValue 구현
- 구현: SwiftData ModelContainer 기반 liveValue 구현, App Group container 경로 사용 (Data/Clients/ContentClientLive.swift)
- 완료 기준: liveValue 구현 완료, 빌드 성공

---

## Phase 2: 핵심 Feature - 홈 화면
상태: 완료 ✅

TCA 기반 홈 화면 Feature 구현. 콘텐츠 목록 표시, 카테고리 필터링.

### Step 2.1: AppFeature Reducer 생성
- 구현: `AppFeature` Reducer 정의 (App/AppFeature.swift)
- 완료 기준: 빌드 성공

### Step 2.2: StashApp 진입점 연결
- 구현: `StashApp.swift`에서 AppFeature Store 생성, 루트 View 연결 (App/StashApp.swift)
- 완료 기준: 앱 실행 시 빈 화면 표시, 빌드 성공

### Step 2.3: HomeFeature State + Action 정의
- 구현: `HomeFeature` Reducer - State (contents, selectedFilter), Action (onAppear, filterTapped) (Features/Home/HomeFeature.swift)
- 완료 기준: 빌드 성공

### Step 2.4: HomeFeature 콘텐츠 로드 로직
- 구현: onAppear 시 `contentClient.fetch()` 호출, 결과를 State에 반영
- 완료 기준: TestStore 테스트 - onAppear 시 콘텐츠 로드 검증

### Step 2.5: HomeFeature 필터 로직
- 구현: filterTapped 시 selectedFilter 변경, 필터된 콘텐츠 목록 반환
- 완료 기준: TestStore 테스트 - 필터 변경 시 State 업데이트 검증

### Step 2.6: HomeView 필터 칩 UI
- 구현: 필터 칩 가로 스크롤 (전체/영상/장소/쇼핑/아티클/인스타) (Features/Home/HomeView.swift)
- 완료 기준: `#Preview` 작성, 필터 칩 표시 확인, 빌드 성공

### Step 2.7: HomeView 카드 그리드 UI
- 구현: 2열 카드 그리드 (LazyVGrid), Store 연결
- 완료 기준: `#Preview`에서 그리드 표시 확인, 빌드 성공

### Step 2.8: ContentCardView 기본 카드
- 구현: 웹 콘텐츠용 기본 카드 (OG 이미지 + 제목 + 도메인) (Features/Home/ContentCardView.swift)
- 완료 기준: `#Preview` 작성, 빌드 성공

### Step 2.9: ContentCardView 소스별 분기
- 구현: ContentType별 카드 레이아웃 분기 (YouTube: 썸네일+제목+채널명, Instagram: 이미지+username, 장소: 이미지+주소, 쇼핑: 이미지+가격)
- 완료 기준: 각 ContentType별 `#Preview` 작성, 빌드 성공

---

## Phase 3: Share Extension
상태: 대기 ⏳

다른 앱에서 1탭 저장 기능. Share Extension에서 URL 수신 → App Group 경유 SwiftData 저장.

### Step 3.1: Share Extension URL 수신
- 구현: ShareViewController에서 NSExtensionItem으로부터 URL 추출 (ShareExtension/ShareViewController.swift)
- 완료 기준: URL 추출 로직 테스트 통과

### Step 3.2: Share Extension SwiftData 저장
- 구현: 추출한 URL을 App Group SwiftData container에 저장
- 완료 기준: 저장 후 데이터 조회 가능, 빌드 성공

### Step 3.3: 저장 완료 피드백 UI
- 구현: 저장 완료 토스트 표시, Extension 종료
- 완료 기준: 저장 후 토스트 표시, Extension 정상 종료, 빌드 성공

### Step 3.4: MetadataClient Protocol 정의
- 구현: OG 태그 파싱 Client Protocol (title, description, imageURL 추출) (Domain/Services/MetadataClient.swift)
- 완료 기준: Protocol 정의 완료, testValue mock 포함, 빌드 성공

### Step 3.5: MetadataClient liveValue 구현
- 구현: LPMetadataProvider 기반 OG 태그 파싱 구현 (Data/Clients/MetadataClientLive.swift)
- 완료 기준: URL에서 메타데이터 추출 테스트 통과

### Step 3.6: 미처리 콘텐츠 메타데이터 업데이트
- 구현: 메인 앱 진입 시 메타데이터가 없는 콘텐츠를 찾아 MetadataClient로 채우기
- 완료 기준: 미처리 콘텐츠의 메타데이터 자동 업데이트 확인, TestStore 테스트 통과

---

## Phase 4: 상세 화면 + 딥링크
상태: 대기 ⏳

콘텐츠 상세 화면, 원본 앱으로의 딥링크, 삭제 기능.

### Step 4.1: DetailFeature Reducer
- 구현: `DetailFeature` State + Action 정의 (Features/Detail/DetailFeature.swift)
- 완료 기준: 빌드 성공

### Step 4.2: HomeFeature → Detail 네비게이션
- 구현: HomeFeature에 StackState path 추가, 카드 탭 시 Detail로 push
- 완료 기준: TestStore 테스트 - 카드 탭 시 path에 Detail 추가 검증

### Step 4.3: DetailView UI
- 구현: 상세 화면 View (Features/Detail/DetailView.swift)
- 완료 기준: `#Preview` 작성, 빌드 성공

### Step 4.4: 딥링크 URL 생성 로직
- 구현: ContentType별 딥링크 URL 생성 (Universal Link / URL scheme / Safari fallback) (Domain/ContentParsing/DeepLinkBuilder.swift)
- 완료 기준: 각 ContentType의 딥링크 URL 생성 테스트 통과

### Step 4.5: 딥링크 실행
- 구현: DetailView에서 "열기" 버튼 탭 시 딥링크 실행 (UIApplication.open)
- 완료 기준: 빌드 성공, TestStore 테스트 통과

### Step 4.6: 콘텐츠 삭제 기능
- 구현: DetailFeature에 삭제 Action + Alert 확인
- 완료 기준: TestStore 테스트 - 삭제 시 contentClient.delete 호출 검증

### Step 4.7: 홈 목록 스와이프 삭제
- 구현: HomeView에서 스와이프 삭제 제스처 추가
- 완료 기준: 빌드 성공

---

## Phase 5: 검색
상태: 대기 ⏳

키워드 검색 → 시맨틱 검색 순서로 구현. Core ML 온디바이스 임베딩.

### 개요
- SearchClient Protocol 정의
- 키워드 검색 liveValue (localizedStandardContains)
- HomeFeature 검색 연동 (디바운스)
- EmbeddingService Protocol 정의
- NLContextualEmbedding 기반 liveValue
- 콘텐츠 저장 시 임베딩 벡터 생성
- 코사인 유사도 벡터 검색
- 키워드 + 시맨틱 결과 병합 랭킹

---

## Phase 6: 설정 + 마무리
상태: 대기 ⏳

설정 화면, 에러 처리, 빈 상태 UI, 최종 품질 다듬기.

### 개요
- SettingsFeature Reducer
- SettingsView UI
- 빈 상태 UI (EmptyStateView)
- 로딩 상태 UI
- 에러 처리 및 사용자 피드백
- 접근성 (VoiceOver, Dynamic Type)
- 성능 최적화 (이미지 캐싱, 대량 데이터 스크롤)
