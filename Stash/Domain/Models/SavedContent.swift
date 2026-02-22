import Foundation

struct SavedContent: Identifiable, Equatable {
    let id: UUID
    var title: String
    var url: URL
    var contentType: ContentType
    var createdAt: Date
    var thumbnailURL: URL?
    var summary: String?
    var metadata: [String: String]
    var embeddingVector: [Float]?
}
