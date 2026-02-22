import ComposableArchitecture
import Foundation
import Testing

@testable import Stash

@MainActor
struct HomeFeatureTests {
    @Test("onAppear 시 콘텐츠가 로드된다")
    func onAppearLoadsContents() async {
        let mockContents: [SavedContent] = [.mockYouTube, .mockInstagram]

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.fetch = { mockContents }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.contentsLoaded) {
            $0.isLoading = false
            $0.contents = IdentifiedArrayOf(uniqueElements: mockContents)
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: mockContents)
        }
    }

    @Test("콘텐츠 로드 실패 시 isLoading이 false로 변경된다")
    func onAppearLoadFailure() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.fetch = { throw NSError(domain: "test", code: -1) }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.contentsLoadFailed) {
            $0.isLoading = false
        }
    }

    @Test("필터 변경 시 filteredContents가 업데이트된다")
    func filterTappedUpdatesFilteredContents() async {
        let allContents: [SavedContent] = [.mockYouTube, .mockInstagram, .mockCoupang]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)

        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.filterTapped(.shopping)) {
            $0.selectedFilter = .shopping
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: [SavedContent.mockCoupang])
        }
    }

    @Test("전체 필터 선택 시 모든 콘텐츠가 표시된다")
    func allFilterShowsEverything() async {
        let allContents: [SavedContent] = [.mockYouTube, .mockInstagram]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: [SavedContent.mockYouTube])
        state.selectedFilter = .video

        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.filterTapped(.all)) {
            $0.selectedFilter = .all
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)
        }
    }

    @Test("영상 필터 선택 시 YouTube 콘텐츠만 표시된다")
    func videoFilterShowsOnlyYouTube() async {
        let allContents: [SavedContent] = [.mockYouTube, .mockInstagram, .mockCoupang]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)

        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.filterTapped(.video)) {
            $0.selectedFilter = .video
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: [SavedContent.mockYouTube])
        }
    }

    @Test("장소 필터 선택 시 네이버지도와 구글맵 콘텐츠가 표시된다")
    func placeFilterShowsMaps() async {
        let allContents: [SavedContent] = [
            .mockYouTube, .mockNaverMap, .mockGoogleMap, .mockCoupang,
        ]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)

        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.filterTapped(.place)) {
            $0.selectedFilter = .place
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: [
                SavedContent.mockNaverMap, SavedContent.mockGoogleMap,
            ])
        }
    }

    @Test("인스타 필터 선택 시 Instagram 콘텐츠만 표시된다")
    func instagramFilterShowsOnlyInstagram() async {
        let allContents: [SavedContent] = [.mockYouTube, .mockInstagram, .mockCoupang]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)

        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.filterTapped(.instagram)) {
            $0.selectedFilter = .instagram
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: [SavedContent.mockInstagram])
        }
    }

    @Test("아티클 필터 선택 시 web 콘텐츠만 표시된다")
    func articleFilterShowsOnlyWeb() async {
        let allContents: [SavedContent] = [.mock, .mockYouTube, .mockInstagram, .mockCoupang]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)

        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.filterTapped(.article)) {
            $0.selectedFilter = .article
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: [SavedContent.mock])
        }
    }

    // MARK: - 메타데이터 업데이트

    @Test("메타데이터 없는 콘텐츠 로드 시 자동으로 fetch + update 한다")
    func metadataAutoUpdate() async {
        let needsUpdate = SavedContent.mock  // metadata=[:], thumbnailURL=nil, summary=nil
        let mockContents: [SavedContent] = [needsUpdate]

        let fetchedMetadata = ContentMetadata(
            title: "업데이트된 제목",
            description: "업데이트된 설명",
            imageURL: URL(string: "https://example.com/og.png"),
            siteName: "Example"
        )

        var updatedContent = needsUpdate
        updatedContent.title = "업데이트된 제목"
        updatedContent.summary = "업데이트된 설명"
        updatedContent.thumbnailURL = URL(string: "https://example.com/og.png")
        updatedContent.metadata = ["siteName": "Example"]

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.fetch = { mockContents }
            $0.contentClient.update = { _ in }
            $0.metadataClient.fetch = { _ in fetchedMetadata }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.contentsLoaded) {
            $0.isLoading = false
            $0.contents = IdentifiedArrayOf(uniqueElements: mockContents)
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: mockContents)
            $0.isUpdatingMetadata = true
        }

        await store.receive(\.metadataUpdateCompleted) {
            $0.isUpdatingMetadata = false
            $0.contents = IdentifiedArrayOf(uniqueElements: [updatedContent])
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: [updatedContent])
        }
    }

    @Test("메타데이터가 이미 있는 콘텐츠는 fetch하지 않는다")
    func noUpdateWhenMetadataExists() async {
        // mockYouTube은 metadata, thumbnailURL, summary 모두 있음
        let mockContents: [SavedContent] = [.mockYouTube, .mockInstagram]

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.fetch = { mockContents }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        // metadataUpdateCompleted가 발생하지 않아야 한다
        await store.receive(\.contentsLoaded) {
            $0.isLoading = false
            $0.contents = IdentifiedArrayOf(uniqueElements: mockContents)
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: mockContents)
        }
    }

    @Test("메타데이터 fetch 실패 시 해당 항목은 건너뛴다")
    func metadataFetchFailureSkipsItem() async {
        let mockContents: [SavedContent] = [.mock]

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.fetch = { mockContents }
            $0.metadataClient.fetch = { _ in throw NSError(domain: "test", code: -1) }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.contentsLoaded) {
            $0.isLoading = false
            $0.contents = IdentifiedArrayOf(uniqueElements: mockContents)
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: mockContents)
            $0.isUpdatingMetadata = true
        }

        await store.receive(\.metadataUpdateCompleted) {
            $0.isUpdatingMetadata = false
        }
    }

    // MARK: - 검색

    @Test("빈 검색어 입력 시 전체 콘텐츠가 표시된다")
    func emptySearchShowsAll() async {
        let allContents: [SavedContent] = [.mockYouTube, .mockInstagram, .mockCoupang]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)
        state.searchQuery = "이전 검색어"

        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.searchQueryChanged("")) {
            $0.searchQuery = ""
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)
        }
    }

    @Test("검색어 입력 시 검색 결과가 반영된다")
    func searchQueryUpdatesResults() async {
        let allContents: [SavedContent] = [.mockYouTube, .mockInstagram, .mockCoupang]
        let searchResults: [SavedContent] = [.mockYouTube]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)

        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.searchClient.search = { _ in searchResults }
            $0.mainQueue = .immediate
        }

        await store.send(.searchQueryChanged("Swift")) {
            $0.searchQuery = "Swift"
        }

        await store.receive(\.searchResultsReceived) {
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: searchResults)
        }
    }

    @Test("검색 결과에 필터가 함께 적용된다")
    func searchWithFilterApplied() async {
        let allContents: [SavedContent] = [.mockYouTube, .mockInstagram, .mockCoupang]
        let searchResults: [SavedContent] = [.mockYouTube, .mockCoupang]

        var state = HomeFeature.State()
        state.contents = IdentifiedArrayOf(uniqueElements: allContents)
        state.filteredContents = IdentifiedArrayOf(uniqueElements: allContents)
        state.selectedFilter = .shopping

        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.searchClient.search = { _ in searchResults }
            $0.mainQueue = .immediate
        }

        await store.send(.searchQueryChanged("Apple")) {
            $0.searchQuery = "Apple"
        }

        await store.receive(\.searchResultsReceived) {
            $0.filteredContents = IdentifiedArrayOf(uniqueElements: [SavedContent.mockCoupang])
        }
    }
}
