import Foundation
import SwiftyJSON

enum TestData {
    static var reviewSessionsResponse: JSON {
        self.loadJSON(path: "review-sessions")
    }

    static var textStoryTemplate: JSON {
        self.loadJSON(path: "story-template-text")
    }

    private static func loadJSON(path: String) -> JSON {
        let testBundle = TestBundle().bundle
        let resourcePath = testBundle.path(forResource: path, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: resourcePath), options: .alwaysMapped)
        let json = try! JSON(data: data)
        return json
    }
}

fileprivate final class TestBundle {
    var bundle: Bundle {
        Bundle(for: type(of: self))
    }
}
