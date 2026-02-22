import Foundation
import NaturalLanguage

extension EmbeddingClient {
    static let liveValue = EmbeddingClient(
        embed: { text in
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return []
            }

            if let embedding = NLEmbedding.sentenceEmbedding(for: .korean),
               let vector = embedding.vector(for: text)
            {
                return vector.map { Float($0) }
            }

            if let embedding = NLEmbedding.sentenceEmbedding(for: .english),
               let vector = embedding.vector(for: text)
            {
                return vector.map { Float($0) }
            }

            return []
        }
    )
}
