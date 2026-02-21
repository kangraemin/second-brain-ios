import ComposableArchitecture
import Foundation

struct ContentClient {
    var save: @Sendable (SavedContent) async throws -> Void
    var fetch: @Sendable () async throws -> [SavedContent]
    var delete: @Sendable (UUID) async throws -> Void
}

extension ContentClient: DependencyKey {
    static let liveValue = ContentClient(
        save: { _ in fatalError("liveValue not implemented yet") },
        fetch: { fatalError("liveValue not implemented yet") },
        delete: { _ in fatalError("liveValue not implemented yet") }
    )

    static let testValue = ContentClient(
        save: { _ in },
        fetch: { [] },
        delete: { _ in }
    )
}

extension DependencyValues {
    var contentClient: ContentClient {
        get { self[ContentClient.self] }
        set { self[ContentClient.self] = newValue }
    }
}
