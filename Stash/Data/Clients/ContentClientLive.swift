import Foundation
import SwiftData

@ModelActor
actor ContentModelActor {
    private static let appGroupID = "group.com.kangraemin.stash"

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([SDContent.self])
        let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        )!.appendingPathComponent("Stash.sqlite")
        let config = ModelConfiguration(url: url)
        return try ModelContainer(for: schema, configurations: [config])
    }

    func save(_ content: SavedContent) throws {
        let sd = ContentMapper.toData(content)
        modelContext.insert(sd)
        try modelContext.save()
    }

    func fetchAll() throws -> [SavedContent] {
        let descriptor = FetchDescriptor<SDContent>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let results = try modelContext.fetch(descriptor)
        return results.map { ContentMapper.toDomain($0) }
    }

    func delete(id: UUID) throws {
        let predicate = #Predicate<SDContent> { $0.id == id }
        let descriptor = FetchDescriptor<SDContent>(predicate: predicate)
        if let target = try modelContext.fetch(descriptor).first {
            modelContext.delete(target)
            try modelContext.save()
        }
    }

    func update(_ content: SavedContent) throws {
        let targetID = content.id
        let predicate = #Predicate<SDContent> { $0.id == targetID }
        let descriptor = FetchDescriptor<SDContent>(predicate: predicate)
        if let existing = try modelContext.fetch(descriptor).first {
            existing.title = content.title
            existing.thumbnailURLString = content.thumbnailURL?.absoluteString
            existing.summary = content.summary
            existing.metadataJSON = ContentMapper.encodeMetadata(content.metadata)
            existing.embeddingData = ContentMapper.encodeEmbedding(content.embeddingVector)
            try modelContext.save()
        }
    }
}
