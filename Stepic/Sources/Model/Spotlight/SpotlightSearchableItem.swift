import CoreSpotlight
import Foundation
import MobileCoreServices

/// An item that can be indexed in Spotlight index.
protocol SpotlightSearchableItem: AnyObject {
    var uniqueIdentifier: UniqueIdentifierType { get }
    var domainIdentifier: UniqueIdentifierType { get }
    var attributeSet: CSSearchableItemAttributeSet { get }
}

extension SpotlightSearchableItem {
    var searchableItem: CSSearchableItem {
        CSSearchableItem(
            uniqueIdentifier: self.uniqueIdentifier,
            domainIdentifier: self.domainIdentifier,
            attributeSet: self.attributeSet
        )
    }
}

final class CourseSpotlightSearchableItem: SpotlightSearchableItem {
    private let course: Course

    var uniqueIdentifier: UniqueIdentifierType {
        "\(self.course.id)"
    }

    var domainIdentifier: UniqueIdentifierType {
        SpotlightDomainIdentifier.course.identifier
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributeSet.relatedUniqueIdentifier = self.uniqueIdentifier
        attributeSet.title = self.course.title
        attributeSet.contentDescription = self.course.summary
        attributeSet.url = URL(string: "\(StepikApplicationsInfo.stepikURL)/\(self.course.id)")

        // Load cached course cover image data
        if let coverURL = URL(string: self.course.coverURLString) {
            let nukeImageDataProvider = NukeImageDataProvider(url: coverURL)
            attributeSet.thumbnailData = nukeImageDataProvider.data
        }

        return attributeSet
    }

    init(course: Course) {
        self.course = course
    }
}
