import Foundation
import SwiftyJSON

enum TestData {
    static var reviewSessionsResponse: JSON {
        self.loadJSON(path: "review-sessions")
    }

    static var textStoryTemplate: JSON {
        self.loadJSON(path: "story-template-text")
    }

    static var feedbackStoryTemplate: JSON {
        self.loadJSON(path: "story-template-feedback")
    }

    // MARK: Datasets

    static var choiceDataset: JSON {
        self.loadJSON(path: "dataset-choice")
    }

    static var fillBlanksDataset: JSON {
        self.loadJSON(path: "dataset-fill-blanks")
    }

    static var freeAnswerDataset: JSON {
        self.loadJSON(path: "dataset-free-answer")
    }

    static var matchingDataset: JSON {
        self.loadJSON(path: "dataset-matching")
    }

    static var sortingDataset: JSON {
        self.loadJSON(path: "dataset-sorting")
    }

    static var tableDataset: JSON {
        self.loadJSON(path: "dataset-table")
    }

    // MARK: Private API

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
