import CoreSpotlight
import Foundation
import MobileCoreServices

protocol SpotlightSearchableItem {
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

struct CourseSpotlightSearchableItem: SpotlightSearchableItem {
    let course: Course

    var uniqueIdentifier: UniqueIdentifierType { "\(self.course.id)" }

    var domainIdentifier: UniqueIdentifierType { SpotlightDomainIdentifier.course.identifier }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        return attributeSet
    }
}
