import Foundation
import SwiftData

@Model
final class SDContent {
    @Attribute(.unique) var id: UUID
    var title: String
    var urlString: String
    var contentTypeRawValue: String
    var createdAt: Date
    var thumbnailURLString: String?
    var summary: String?
    var metadataJSON: String?
    var embeddingData: Data?

    init(
        id: UUID,
        title: String,
        urlString: String,
        contentTypeRawValue: String,
        createdAt: Date,
        thumbnailURLString: String? = nil,
        summary: String? = nil,
        metadataJSON: String? = nil,
        embeddingData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.urlString = urlString
        self.contentTypeRawValue = contentTypeRawValue
        self.createdAt = createdAt
        self.thumbnailURLString = thumbnailURLString
        self.summary = summary
        self.metadataJSON = metadataJSON
        self.embeddingData = embeddingData
    }
}
