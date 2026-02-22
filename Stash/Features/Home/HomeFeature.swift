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
        var isUpdatingMetadata = false
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
        case metadataUpdateCompleted([SavedContent])
        case metadataUpdateFailed
    }

    @Dependency(\.contentClient) var contentClient
    @Dependency(\.metadataClient) var metadataClient

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
                state.contents = IdentifiedArrayOf(uniqueElements: contents)
                state.filteredContents = applyFilter(state.selectedFilter, to: state.contents)

                let needsUpdate = contents.filter { $0.needsMetadataUpdate }
                guard !needsUpdate.isEmpty else { return .none }

                state.isUpdatingMetadata = true
                return .run { [contentClient, metadataClient] send in
                    var updated: [SavedContent] = []
                    for var content in needsUpdate {
                        do {
                            let metadata = try await metadataClient.fetch(content.url)
                            if let title = metadata.title { content.title = title }
                            content.summary = metadata.description
                            content.thumbnailURL = metadata.imageURL
                            if let siteName = metadata.siteName {
                                content.metadata["siteName"] = siteName
                            }
                            try await contentClient.update(content)
                            updated.append(content)
                        } catch {
                            // 개별 실패는 무시
                        }
                    }
                    await send(.metadataUpdateCompleted(updated))
                }

            case .contentsLoadFailed:
                state.isLoading = false
                return .none

            case .metadataUpdateCompleted(let updatedContents):
                state.isUpdatingMetadata = false
                for content in updatedContents {
                    state.contents[id: content.id] = content
                }
                state.filteredContents = applyFilter(state.selectedFilter, to: state.contents)
                return .none

            case .metadataUpdateFailed:
                state.isUpdatingMetadata = false
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

// MARK: - Metadata Update Check

private extension SavedContent {
    var needsMetadataUpdate: Bool {
        metadata.isEmpty && thumbnailURL == nil && summary == nil
    }
}
