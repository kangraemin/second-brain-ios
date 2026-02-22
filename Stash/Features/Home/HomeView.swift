import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(spacing: 0) {
                filterChips
                    .padding(.vertical, 12)

                Divider()

                if store.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if store.filteredContents.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    cardGrid
                }
            }
            .navigationTitle("Stash")
            .searchable(
                text: Binding(
                    get: { store.searchQuery },
                    set: { store.send(.searchQueryChanged($0)) }
                ),
                prompt: "콘텐츠 검색"
            )
            .onAppear { store.send(.onAppear) }
        } destination: { store in
            switch store.case {
            case .detail(let detailStore):
                DetailView(store: detailStore)
            }
        }
    }

    // MARK: - Card Grid

    private var cardGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ],
                spacing: 12
            ) {
                ForEach(store.filteredContents) { content in
                    Button {
                        store.send(.contentCardTapped(content))
                    } label: {
                        ContentCardView(content: content)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            store.send(.swipeDeleteTapped(content))
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            if store.searchQuery.isEmpty {
                Text("저장된 콘텐츠가 없습니다")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("공유하기로 콘텐츠를 저장해 보세요")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                Text("검색 결과가 없습니다")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("다른 키워드로 검색해 보세요")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HomeFeature.ContentFilter.allCases, id: \.self) { filter in
                    FilterChipView(
                        title: filter.rawValue,
                        isSelected: store.selectedFilter == filter
                    ) {
                        store.send(.filterTapped(filter))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - FilterChipView

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.fetch = {
                [.mock, .mockYouTube, .mockInstagram, .mockNaverMap, .mockCoupang]
            }
        }
    )
}
