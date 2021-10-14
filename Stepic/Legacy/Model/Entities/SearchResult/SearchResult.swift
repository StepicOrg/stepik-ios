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
        let commentUserInfo: UserInfo? = {
            if let commentUser = self.commentUser {
                return UserInfo(
                    id: commentUser.id,
                    avatarURL: commentUser.avatarURL,
                    firstName: commentUser.firstName,
                    lastName: commentUser.lastName
                )
            }
            return nil
        }()

        let unitProgress: ProgressPlainObject? = {
            if let progress = self.lesson?.unit?.progress {
                return ProgressPlainObject(progress: progress)
            }
            return nil
        }()

        return SearchResultPlainObject(
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
            sectionPosition: self.lesson?.unit?.section?.position,
            unitID: self.lesson?.unit?.id,
            unitPosition: self.lesson?.unit?.position,
            unitProgress: unitProgress,
            lessonID: self.lessonID,
            lessonOwnerID: self.lessonOwnerID,
            lessonTitle: self.lessonTitle,
            lessonCoverURL: self.lessonCover,
            lessonVoteDelta: self.lesson?.voteDelta,
            lessonTimeToComplete: self.lesson?.timeToComplete,
            lessonPassedBy: self.lesson?.passedBy,
            lessonCanEdit: self.lesson?.canEdit,
            stepID: self.stepID,
            stepPosition: self.stepPosition,
            stepDiscussionProxyID: self.step?.discussionProxyID,
            commentID: self.commentID,
            commentParentID: self.commentParentID,
            commentUserID: self.commentUserID,
            commentText: self.commentText,
            commentUserInfo: commentUserInfo
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
