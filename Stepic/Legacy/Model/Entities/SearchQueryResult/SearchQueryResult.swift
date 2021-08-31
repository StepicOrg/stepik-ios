import CoreData
import Foundation

final class SearchQueryResult: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = String

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedLastSearchDate), ascending: false)]
    }

    static func insertSearchByCourseResults(
        into context: NSManagedObjectContext,
        courseID: Course.IdType,
        query: String,
        searchResults: [SearchResultPlainObject]
    ) -> SearchQueryResult {
        let entity: SearchQueryResult = context.insertObject()

        entity.id = self.makeID(courseID: courseID, query: query)
        entity.query = query
        entity.courseID = courseID
        entity.lastSearchDate = Date()
        entity.searchResults = searchResults.map { SearchResult.insert(into: context, searchResult: $0) }

        return entity
    }

    private static func makeID(courseID: Course.IdType, query: String) -> IdType {
        let processedQuery = query.trimmed().lowercased()
        return "\(courseID)-\(processedQuery)"
    }
}
