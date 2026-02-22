import Dependencies
import Foundation

struct SearchClient {
    var search: @Sendable (String) async throws -> [SavedContent]
}

extension SearchClient: DependencyKey {
    static let testValue = SearchClient(
        search: { _ in [] }
    )
}

extension DependencyValues {
    var searchClient: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
}
