import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack {
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
            .onAppear { store.send(.onAppear) }
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
                    ContentCardView(content: content)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("저장된 콘텐츠가 없습니다")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("공유하기로 콘텐츠를 저장해 보세요")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
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

// MARK: - ContentCardView (placeholder — Step 2.8에서 교체)

struct ContentCardView: View {
    let content: SavedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .aspectRatio(16 / 9, contentMode: .fit)
                .overlay {
                    Text(content.contentType.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

            Text(content.title)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(2)

            Text(content.url.host ?? "")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
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
