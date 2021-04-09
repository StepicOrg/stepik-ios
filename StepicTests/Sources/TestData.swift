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

    // MARK: Feedbacks

    static var choiceSubmissionFeedback: JSON {
        self.loadJSON(path: "feedback-choice-submission")
    }

    static var fillBlanksSubmissionFeedback: JSON {
        self.loadJSON(path: "feedback-fill-blanks")
    }

    // MARK: Replies

    static var choiceReply: JSON {
        self.loadJSON(path: "reply-choice")
    }

    static var codeReply: JSON {
        self.loadJSON(path: "reply-code")
    }

    static var fillBlanksReply: JSON {
        self.loadJSON(path: "reply-fill-blanks")
    }

    static var freeAnswerReply: JSON {
        self.loadJSON(path: "reply-free-answer")
    }

    static var matchingReply: JSON {
        self.loadJSON(path: "reply-matching")
    }

    static var mathReply: JSON {
        self.loadJSON(path: "reply-math")
    }

    static var numberReply: JSON {
        self.loadJSON(path: "reply-number")
    }

    static var sortingReply: JSON {
        self.loadJSON(path: "reply-sorting")
    }

    static var sqlReply: JSON {
        self.loadJSON(path: "reply-sorting")
    }

    static var tableReply: JSON {
        self.loadJSON(path: "reply-table")
    }

    static var textReply: JSON {
        self.loadJSON(path: "reply-text")
    }

    // MARK: CatalogBlocks

    static var fullCourseListsCatalogBlock: JSON {
        self.loadJSON(path: "catalog-block-full-course-lists")
    }

    static var simpleCourseListsCatalogBlock: JSON {
        self.loadJSON(path: "catalog-block-simple-course-lists")
    }

    static var authorsCatalogBlock: JSON {
        self.loadJSON(path: "catalog-block-authors")
    }

    static var organizationsCatalogBlock: JSON {
        self.loadJSON(path: "catalog-block-organizations")
    }

    static var recommendedCoursesCatalogBlock: JSON {
        self.loadJSON(path: "catalog-block-recommended-courses")
    }

    static var specializationsStepikAcademyCatalogBlock: JSON {
        self.loadJSON(path: "catalog-block-specializations-stepik-academy")
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
