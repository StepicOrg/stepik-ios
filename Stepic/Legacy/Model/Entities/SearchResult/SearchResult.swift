import CoreData
import Foundation

final class SearchResult: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedPosition), ascending: true)]
    }
}

// MARK: - SearchResult (PlainObject Support) -

extension SearchResult {
    var plainObject: SearchResultPlainObject {
        SearchResultPlainObject(
            id: self.id,
            position: self.position,
            score: self.score,
            targetID: self.targetID,
            targetTypeString: self.targetTypeString,
            courseID: self.courseID,
            courseOwnerID: self.courseOwnerID,
            courseAuthorsIDs: self.courseAuthorsArray,
            courseTitle: self.courseTitle,
            courseCoverURL: self.courseCover,
            lessonID: self.lessonID,
            lessonOwnerID: self.lessonOwnerID,
            lessonTitle: self.lessonTitle,
            lessonCoverURL: self.lessonCover,
            stepID: self.stepID,
            stepPosition: self.stepPosition,
            commentID: self.commentID,
            commentParentID: self.commentParentID,
            commentUserID: self.commentUserID,
            commentText: self.commentText
        )
    }

    static func insert(into context: NSManagedObjectContext, searchResult: SearchResultPlainObject) -> SearchResult {
        let entity: SearchResult = context.insertObject()

        entity.id = searchResult.id
        entity.position = searchResult.position
        entity.score = searchResult.score

        entity.targetID = searchResult.targetID
        entity.targetTypeString = searchResult.targetTypeString

        entity.courseID = searchResult.courseID
        entity.courseOwnerID = searchResult.courseOwnerID
        entity.courseAuthorsArray = searchResult.courseAuthorsIDs
        entity.courseTitle = searchResult.courseTitle
        entity.courseCover = searchResult.courseCoverURL

        entity.lessonID = searchResult.lessonID
        entity.lessonOwnerID = searchResult.lessonOwnerID
        entity.lessonTitle = searchResult.lessonTitle
        entity.lessonCover = searchResult.lessonCoverURL

        entity.stepID = searchResult.stepID
        entity.stepPosition = searchResult.stepPosition

        entity.commentID = searchResult.commentID
        entity.commentParentID = searchResult.commentParentID
        entity.commentUserID = searchResult.commentUserID
        entity.commentText = searchResult.commentText

        return entity
    }
}
