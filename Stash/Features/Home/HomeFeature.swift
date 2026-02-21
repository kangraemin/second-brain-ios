import ComposableArchitecture
import Foundation

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var contents: IdentifiedArrayOf<SavedContent> = []
        var filteredContents: IdentifiedArrayOf<SavedContent> = []
        var selectedFilter: ContentFilter = .all
        var isLoading = false
    }

    enum ContentFilter: String, CaseIterable, Equatable {
        case all = "전체"
        case video = "영상"
        case place = "장소"
        case shopping = "쇼핑"
        case article = "아티클"
        case instagram = "인스타"
    }

    enum Action {
        case onAppear
        case filterTapped(ContentFilter)
        case contentsLoaded([SavedContent])
        case contentsLoadFailed
    }

    @Dependency(\.contentClient) var contentClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    do {
                        let contents = try await contentClient.fetch()
                        await send(.contentsLoaded(contents))
                    } catch {
                        await send(.contentsLoadFailed)
                    }
                }

            case .contentsLoaded(let contents):
                state.isLoading = false
                var array = IdentifiedArrayOf<SavedContent>()
                for content in contents {
                    array.append(content)
                }
                state.contents = array
                state.filteredContents = applyFilter(state.selectedFilter, to: state.contents)
                return .none

            case .contentsLoadFailed:
                state.isLoading = false
                return .none

            case .filterTapped(let filter):
                state.selectedFilter = filter
                state.filteredContents = applyFilter(filter, to: state.contents)
                return .none
            }
        }
    }
}

// MARK: - Filter Logic

private func applyFilter(
    _ filter: HomeFeature.ContentFilter,
    to contents: IdentifiedArrayOf<SavedContent>
) -> IdentifiedArrayOf<SavedContent> {
    switch filter {
    case .all:
        return contents
    case .video:
        return contents.filter { $0.contentType == .youtube }
    case .place:
        return contents.filter { $0.contentType == .naverMap || $0.contentType == .googleMap }
    case .shopping:
        return contents.filter { $0.contentType == .coupang }
    case .article:
        return contents.filter { $0.contentType == .web }
    case .instagram:
        return contents.filter { $0.contentType == .instagram }
    }
}
