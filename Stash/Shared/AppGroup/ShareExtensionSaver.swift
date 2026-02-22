import Foundation
import SwiftData

enum ShareExtensionSaver {
    private static let appGroupID = "group.com.kangraemin.stash"

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([SDContent.self])
        let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        )!.appendingPathComponent("Stash.sqlite")
        let config = ModelConfiguration(url: url)
        return try ModelContainer(for: schema, configurations: [config])
    }

    static func save(url: URL, container: ModelContainer) throws {
        let contentType = ContentTypeParser.parse(url: url)
        let content = SavedContent(
            id: UUID(),
            title: url.host ?? url.absoluteString,
            url: url,
            contentType: contentType,
            createdAt: .now,
            metadata: [:]
        )
        let sd = ContentMapper.toData(content)
        let context = ModelContext(container)
        context.insert(sd)
        try context.save()
    }
}
