import Foundation
import Testing
@testable import Stash

struct ContentTypeParserTests {

    // MARK: - YouTube

    @Test("YouTube URL (www.youtube.com)을 올바르게 판별한다")
    func youtubeWWW() {
        let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
        #expect(ContentTypeParser.parse(url: url) == .youtube)
    }

    @Test("YouTube 단축 URL (youtu.be)을 올바르게 판별한다")
    func youtubeShort() {
        let url = URL(string: "https://youtu.be/dQw4w9WgXcQ")!
        #expect(ContentTypeParser.parse(url: url) == .youtube)
    }

    @Test("YouTube 모바일 URL (m.youtube.com)을 올바르게 판별한다")
    func youtubeMobile() {
        let url = URL(string: "https://m.youtube.com/watch?v=dQw4w9WgXcQ")!
        #expect(ContentTypeParser.parse(url: url) == .youtube)
    }

    // MARK: - Instagram

    @Test("Instagram URL (www.instagram.com)을 올바르게 판별한다")
    func instagramWWW() {
        let url = URL(string: "https://www.instagram.com/p/ABC123")!
        #expect(ContentTypeParser.parse(url: url) == .instagram)
    }

    @Test("Instagram URL (instagram.com)을 올바르게 판별한다")
    func instagramBare() {
        let url = URL(string: "https://instagram.com/p/ABC123")!
        #expect(ContentTypeParser.parse(url: url) == .instagram)
    }

    // MARK: - 네이버지도

    @Test("네이버지도 URL (map.naver.com)을 올바르게 판별한다")
    func naverMap() {
        let url = URL(string: "https://map.naver.com/v5/search/맛집")!
        #expect(ContentTypeParser.parse(url: url) == .naverMap)
    }

    @Test("네이버지도 단축 URL (naver.me)을 올바르게 판별한다")
    func naverMapShort() {
        let url = URL(string: "https://naver.me/xAbCdEfG")!
        #expect(ContentTypeParser.parse(url: url) == .naverMap)
    }

    // MARK: - 구글맵

    @Test("구글맵 URL (maps.google.com)을 올바르게 판별한다")
    func googleMap() {
        let url = URL(string: "https://maps.google.com/maps?q=Seoul")!
        #expect(ContentTypeParser.parse(url: url) == .googleMap)
    }

    @Test("구글맵 단축 URL (maps.app.goo.gl)을 올바르게 판별한다")
    func googleMapShort() {
        let url = URL(string: "https://maps.app.goo.gl/xAbCdEfG")!
        #expect(ContentTypeParser.parse(url: url) == .googleMap)
    }

    @Test("구글맵 goo.gl/maps URL을 올바르게 판별한다")
    func googleMapGooGl() {
        let url = URL(string: "https://goo.gl/maps/xAbCdEfG")!
        #expect(ContentTypeParser.parse(url: url) == .googleMap)
    }

    // MARK: - 쿠팡

    @Test("쿠팡 URL (www.coupang.com)을 올바르게 판별한다")
    func coupangWWW() {
        let url = URL(string: "https://www.coupang.com/vp/products/123456")!
        #expect(ContentTypeParser.parse(url: url) == .coupang)
    }

    @Test("쿠팡 단축 URL (coupa.ng)을 올바르게 판별한다")
    func coupangShort() {
        let url = URL(string: "https://coupa.ng/abc123")!
        #expect(ContentTypeParser.parse(url: url) == .coupang)
    }

    // MARK: - 일반 웹

    @Test("일반 웹 URL을 web으로 판별한다")
    func webGeneric() {
        let url = URL(string: "https://example.com/article/123")!
        #expect(ContentTypeParser.parse(url: url) == .web)
    }

    @Test("알 수 없는 도메인을 web으로 판별한다")
    func webUnknown() {
        let url = URL(string: "https://blog.naver.com/post/123")!
        #expect(ContentTypeParser.parse(url: url) == .web)
    }

    // MARK: - 대소문자 무시

    @Test("대소문자가 섞인 URL도 올바르게 판별한다")
    func caseInsensitive() {
        let url = URL(string: "https://WWW.YouTube.COM/watch?v=abc")!
        #expect(ContentTypeParser.parse(url: url) == .youtube)
    }
}
