import CoreData
import Foundation
import PromiseKit

protocol CourseReviewsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [CourseReview.IdType]) -> Guarantee<[CourseReview]>
    func fetch(by courseID: Course.IdType) -> Promise<[CourseReview]>
    func fetch(by courseID: Course.IdType, userID: User.IdType) -> Promise<CourseReview?>

    func delete(by courseReviewID: CourseReview.IdType) -> Promise<Void>
    func deleteAll() -> Promise<Void>
}

final class CourseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [CourseReview.IdType]) -> Guarantee<[CourseReview]> {
        Guarantee { seal in
            CourseReview.fetchAsync(ids: ids).done { reviews in
                let reviews = Array(Set(reviews)).reordered(order: ids, transform: { $0.id })
                seal(reviews)
            }
        }
    }

    func fetch(by courseID: Course.IdType) -> Promise<[CourseReview]> {
        Promise { seal in
            CourseReview.fetch(courseID: courseID).done {
                seal.fulfill($0)
            }
        }
    }

    func fetch(by courseID: Course.IdType, userID: User.IdType) -> Promise<CourseReview?> {
        Promise { seal in
            CourseReview.fetch(courseID: courseID, userID: userID).done { reviews in
                seal.fulfill(reviews.first)
            }
        }
    }

    func delete(by courseReviewID: CourseReview.IdType) -> Promise<Void> {
        Promise { seal in
            CourseReview.delete(courseReviewID).done {
                seal.fulfill(())
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<CourseReview> = CourseReview.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let courseReviews = try self.managedObjectContext.fetch(request)
                    for courseReview in courseReviews {
                        self.managedObjectContext.delete(courseReview)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CourseReviewsPersistenceService :: failed delete all course reviews with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
