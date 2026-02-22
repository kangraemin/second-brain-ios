import Dependencies
import Foundation

struct EmbeddingClient {
    var embed: @Sendable (String) async throws -> [Float]
}

extension EmbeddingClient: DependencyKey {
    static let testValue = EmbeddingClient(
        embed: { _ in Array(repeating: 0.0, count: 128) }
    )
}

extension DependencyValues {
    var embeddingClient: EmbeddingClient {
        get { self[EmbeddingClient.self] }
        set { self[EmbeddingClient.self] = newValue }
    }
}
