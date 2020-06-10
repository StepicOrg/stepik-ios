import CoreData
import Foundation
import PromiseKit

protocol CourseReviewSummariesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [CourseReviewSummary.IdType], page: Int) -> Promise<([CourseReviewSummary], Meta)>
    func fetch(id: CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?>

    func deleteAll() -> Promise<Void>
}

final class CourseReviewSummariesPersistenceService: CourseReviewSummariesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    // swiftlint:disable:next unavailable_function
    func fetch(ids: [CourseReviewSummary.IdType], page: Int = 1) -> Promise<([CourseReviewSummary], Meta)> {
        fatalError("Not implemented yet")
    }

    func fetch(id: CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?> {
        Promise { seal in
            CourseReviewSummary.fetchAsync(ids: [id]).done { reviewsSummary in
                seal.fulfill(reviewsSummary.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<CourseReviewSummary> = CourseReviewSummary.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let courseReviewSummaries = try self.managedObjectContext.fetch(request)
                    for courseReviewSummary in courseReviewSummaries {
                        self.managedObjectContext.delete(courseReviewSummary)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CourseReviewSummariesPersistenceService :: failed delete all reviews with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case deleteFailed
    }
}
