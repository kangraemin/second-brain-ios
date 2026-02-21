import ComposableArchitecture
import Foundation
import Testing

@testable import Stash

@MainActor
struct HomeFeatureTests {
    @Test("onAppear 시 콘텐츠가 로드된다")
    func onAppearLoadsContents() async {
        let mockContents: [SavedContent] = [.mock, .mockYouTube, .mockInstagram]

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
        let allContents: [SavedContent] = [.mock, .mockYouTube, .mockInstagram, .mockCoupang]

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
        let allContents: [SavedContent] = [.mock, .mockYouTube, .mockInstagram]

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
        let allContents: [SavedContent] = [.mock, .mockYouTube, .mockInstagram, .mockCoupang]

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
            .mock, .mockYouTube, .mockNaverMap, .mockGoogleMap, .mockCoupang,
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
        let allContents: [SavedContent] = [.mock, .mockYouTube, .mockInstagram, .mockCoupang]

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
}
