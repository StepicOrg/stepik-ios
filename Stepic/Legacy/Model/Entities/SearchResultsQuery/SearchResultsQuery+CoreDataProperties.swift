import CoreData
import Foundation

extension SearchResultsQuery {
    @NSManaged var managedId: String
    @NSManaged var managedQuery: String
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedLastSearchDate: Date

    @NSManaged var managedSearchResults: NSOrderedSet?

    var id: String {
        get {
            self.managedId
        }
        set {
            self.managedId = newValue
        }
    }

    var query: String {
        get {
            self.managedQuery
        }
        set {
            self.managedQuery = newValue
        }
    }

    var courseID: Course.IdType? {
        get {
            self.managedCourseId?.intValue
        }
        set {
            self.managedCourseId = newValue as NSNumber?
        }
    }

    var lastSearchDate: Date {
        get {
            self.managedLastSearchDate
        }
        set {
            self.managedLastSearchDate = newValue
        }
    }

    var searchResults: [SearchResult] {
        get {
            (self.managedSearchResults?.array as? [SearchResult]) ?? []
        }
        set {
            self.managedSearchResults = NSOrderedSet(array: newValue)
        }
    }
}
