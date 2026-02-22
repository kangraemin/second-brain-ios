import Foundation
import SwiftData
import Testing
@testable import Stash

struct ShareExtensionSaverTests {

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([SDContent.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test("URL 저장 후 SwiftData에서 조회할 수 있다")
    func saveAndFetch() throws {
        let container = try makeInMemoryContainer()
        let url = URL(string: "https://www.youtube.com/watch?v=abc123")!

        try ShareExtensionSaver.save(url: url, container: container)

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SDContent>()
        let results = try context.fetch(descriptor)

        #expect(results.count == 1)
        #expect(results.first?.urlString == "https://www.youtube.com/watch?v=abc123")
    }

    @Test("YouTube URL은 .youtube ContentType으로 저장된다")
    func youtubeContentType() throws {
        let container = try makeInMemoryContainer()
        let url = URL(string: "https://www.youtube.com/watch?v=abc123")!

        try ShareExtensionSaver.save(url: url, container: container)

        let context = ModelContext(container)
        let results = try context.fetch(FetchDescriptor<SDContent>())

        #expect(results.first?.contentTypeRawValue == ContentType.youtube.rawValue)
    }

    @Test("Instagram URL은 .instagram ContentType으로 저장된다")
    func instagramContentType() throws {
        let container = try makeInMemoryContainer()
        let url = URL(string: "https://www.instagram.com/p/ABC123")!

        try ShareExtensionSaver.save(url: url, container: container)

        let context = ModelContext(container)
        let results = try context.fetch(FetchDescriptor<SDContent>())

        #expect(results.first?.contentTypeRawValue == ContentType.instagram.rawValue)
    }

    @Test("title은 url.host로 설정된다")
    func titleIsHost() throws {
        let container = try makeInMemoryContainer()
        let url = URL(string: "https://www.example.com/page")!

        try ShareExtensionSaver.save(url: url, container: container)

        let context = ModelContext(container)
        let results = try context.fetch(FetchDescriptor<SDContent>())

        #expect(results.first?.title == "www.example.com")
    }

    @Test("metadata는 빈 상태로 저장된다")
    func emptyMetadata() throws {
        let container = try makeInMemoryContainer()
        let url = URL(string: "https://example.com")!

        try ShareExtensionSaver.save(url: url, container: container)

        let context = ModelContext(container)
        let results = try context.fetch(FetchDescriptor<SDContent>())

        #expect(results.first?.metadataJSON == nil)
    }
}
