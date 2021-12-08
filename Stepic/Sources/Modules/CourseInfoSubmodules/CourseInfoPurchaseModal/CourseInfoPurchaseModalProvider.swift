import Foundation
import PromiseKit

protocol CourseInfoPurchaseModalProviderProtocol {
    func fetchCourse() -> Promise<Course?>

    func calculateMobileTier(promoCodeName: String?) -> Promise<MobileTierPlainObject?>
    func fetchMobileTierFromCache(mobileTierID: MobileTier.IdType) -> Guarantee<MobileTier?>

    func addCourseToWishlist() -> Promise<Void>
}

final class CourseInfoPurchaseModalProvider: CourseInfoPurchaseModalProviderProtocol {
    private let courseID: Course.IdType

    private let coursesRepository: CoursesRepositoryProtocol

    private let mobileTiersRepository: MobileTiersRepositoryProtocol
    private let mobileTiersPersistenceService: MobileTiersPersistenceServiceProtocol

    private let wishlistRepository: WishlistRepositoryProtocol

    init(
        courseID: Course.IdType,
        coursesRepository: CoursesRepositoryProtocol,
        mobileTiersRepository: MobileTiersRepositoryProtocol,
        mobileTiersPersistenceService: MobileTiersPersistenceServiceProtocol,
        wishlistRepository: WishlistRepositoryProtocol
    ) {
        self.courseID = courseID
        self.coursesRepository = coursesRepository
        self.mobileTiersRepository = mobileTiersRepository
        self.mobileTiersPersistenceService = mobileTiersPersistenceService
        self.wishlistRepository = wishlistRepository
    }

    func fetchCourse() -> Promise<Course?> {
        self.coursesRepository.fetch(id: self.courseID, fetchPolicy: .remoteFirst)
    }

    func calculateMobileTier(promoCodeName: String?) -> Promise<MobileTierPlainObject?> {
        self.mobileTiersRepository.fetch(courseID: self.courseID, promoCodeName: promoCodeName, dataSourceType: .remote)
    }

    func fetchMobileTierFromCache(mobileTierID: MobileTier.IdType) -> Guarantee<MobileTier?> {
        self.mobileTiersPersistenceService.fetch(id: mobileTierID)
    }

    func addCourseToWishlist() -> Promise<Void> {
        self.wishlistRepository.addCourseToWishlist(courseID: self.courseID)
    }
}
