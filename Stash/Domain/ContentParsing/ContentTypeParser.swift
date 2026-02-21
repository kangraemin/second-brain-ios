import Foundation

struct ContentTypeParser {
    static func parse(url: URL) -> ContentType {
        guard let host = url.host?.lowercased() else {
            return .web
        }

        if host == "youtube.com" || host.hasSuffix(".youtube.com") || host == "youtu.be" {
            return .youtube
        }

        if host == "instagram.com" || host.hasSuffix(".instagram.com") {
            return .instagram
        }

        if host == "map.naver.com" || host == "naver.me" {
            return .naverMap
        }

        if host == "maps.google.com" || host == "maps.app.goo.gl" {
            return .googleMap
        }

        if host == "goo.gl" && url.path.hasPrefix("/maps") {
            return .googleMap
        }

        if host == "coupang.com" || host.hasSuffix(".coupang.com") || host == "coupa.ng" {
            return .coupang
        }

        return .web
    }
}
