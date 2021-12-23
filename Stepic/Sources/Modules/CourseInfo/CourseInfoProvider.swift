import Foundation
import PromiseKit

protocol CourseInfoProviderProtocol {
    func fetchCached() -> Promise<Course?>
    func fetchRemote() -> Promise<Course?>

    func fetchUserCourse() -> Promise<UserCourse?>
    func updateUserCourse(_ userCourse: UserCourse) -> Promise<UserCourse>

    func checkPromoCode(name: String) -> Promise<PromoCode>
    func fetchMobileTier(promoCodeName: String?, dataSourceType: DataSourceType) -> Promise<MobileTierPlainObject?>

    func addCourseToWishlist() -> Promise<Void>
    func deleteCourseFromWishlist() -> Promise<Void>
}

final class CourseInfoProvider: CourseInfoProviderProtocol {
    private let courseID: Course.IdType

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol

    private let reviewSummariesPersistenceService: CourseReviewSummariesPersistenceServiceProtocol
    private let reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol

    private let coursePurchasesPersistenceService: CoursePurchasesPersistenceServiceProtocol
    private let coursePurchasesNetworkService: CoursePurchasesNetworkServiceProtocol

    private let userCoursesNetworkService: UserCoursesNetworkServiceProtocol

    private let promoCodesNetworkService: PromoCodesNetworkServiceProtocol

    private let wishlistRepository: WishlistRepositoryProtocol

    private let mobileTiersRepository: MobileTiersRepositoryProtocol

    init(
        courseID: Course.IdType,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        reviewSummariesPersistenceService: CourseReviewSummariesPersistenceServiceProtocol,
        reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol,
        coursePurchasesPersistenceService: CoursePurchasesPersistenceServiceProtocol,
        coursePurchasesNetworkService: CoursePurchasesNetworkServiceProtocol,
        userCoursesNetworkService: UserCoursesNetworkServiceProtocol,
        promoCodesNetworkService: PromoCodesNetworkServiceProtocol,
        wishlistRepository: WishlistRepositoryProtocol,
        mobileTiersRepository: MobileTiersRepositoryProtocol
    ) {
        self.courseID = courseID
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.progressesPersistenceService = progressesPersistenceService
        self.reviewSummariesNetworkService = reviewSummariesNetworkService
        self.reviewSummariesPersistenceService = reviewSummariesPersistenceService
        self.coursePurchasesPersistenceService = coursePurchasesPersistenceService
        self.coursePurchasesNetworkService = coursePurchasesNetworkService
        self.userCoursesNetworkService = userCoursesNetworkService
        self.promoCodesNetworkService = promoCodesNetworkService
        self.wishlistRepository = wishlistRepository
        self.mobileTiersRepository = mobileTiersRepository
    }

    func fetchCached() -> Promise<Course?> {
        Promise { seal in
            self.fetchAndMergeCourse(
                courseFetchMethod: self.coursesPersistenceService.fetch(id:),
                progressFetchMethod: self.progressesPersistenceService.fetch(id:),
                reviewSummaryFetchMethod: self.reviewSummariesPersistenceService.fetch(id:),
                purchasesFetchMethod: self.fetchCachedPurchases(courseID:)
            ).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote() -> Promise<Course?> {
        Promise { seal in
            self.fetchAndMergeCourse(
                courseFetchMethod: self.coursesNetworkService.fetch(id:),
                progressFetchMethod: self.progressesNetworkService.fetch(id:),
                reviewSummaryFetchMethod: self.reviewSummariesNetworkService.fetch(id:),
                purchasesFetchMethod: self.coursePurchasesNetworkService.fetch(courseID:)
            ).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchUserCourse() -> Promise<UserCourse?> {
        Promise { seal in
            self.userCoursesNetworkService.fetch(courseID: self.courseID).done { userCourse in
                seal.fulfill(userCourse)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func updateUserCourse(_ userCourse: UserCourse) -> Promise<UserCourse> {
        Promise { seal in
            self.userCoursesNetworkService.update(userCourse: userCourse).done { userCourse in
                seal.fulfill(userCourse)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func checkPromoCode(name: String) -> Promise<PromoCode> {
        self.promoCodesNetworkService.checkPromoCode(courseID: self.courseID, name: name)
    }

    func fetchMobileTier(promoCodeName: String?, dataSourceType: DataSourceType) -> Promise<MobileTierPlainObject?> {
        self.mobileTiersRepository
            .fetch(courseID: self.courseID, promoCodeName: promoCodeName, dataSourceType: dataSourceType)
    }

    func addCourseToWishlist() -> Promise<Void> {
        self.wishlistRepository.addCourseToWishlist(courseID: self.courseID)
    }

    func deleteCourseFromWishlist() -> Promise<Void> {
        self.wishlistRepository.deleteCourseFromWishlist(courseID: self.courseID, sourceType: .remote)
    }

    // MARK: Private API

    private func fetchAndMergeCourse(
        courseFetchMethod: @escaping (Course.IdType) -> Promise<Course?>,
        progressFetchMethod: @escaping (Progress.IdType) -> Promise<Progress?>,
        reviewSummaryFetchMethod: @escaping (CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?>,
        purchasesFetchMethod: @escaping (Course.IdType) -> Promise<[CoursePurchase]>
    ) -> Promise<Course?> {
        Promise { seal in
            courseFetchMethod(self.courseID).then {
                course -> Promise<(Course?, Progress?, CourseReviewSummary?, [CoursePurchase])> in
                let progressFetch: Promise<Progress?> = {
                    if let progressID = course?.progressID {
                        return progressFetchMethod(progressID)
                    }
                    return .value(nil)
                }()

                let reviewSummaryFetch: Promise<CourseReviewSummary?> = {
                    if let reviewSummaryID = course?.reviewSummaryID {
                        return reviewSummaryFetchMethod(reviewSummaryID)
                    }
                    return .value(nil)
                }()

                let purchasesFetch: Promise<[CoursePurchase]> = {
                    guard let course = course else {
                        return .value([])
                    }

                    if course.isPaid && !course.enrolled {
                        return purchasesFetchMethod(course.id)
                    }

                    return .value([])
                }()

                return when(fulfilled: Promise.value(course), progressFetch, reviewSummaryFetch, purchasesFetch)
            }.done { course, progress, reviewSummary, coursePurchases in
                guard let course = course else {
                    seal.fulfill(nil)
                    return
                }

                course.progress = progress
                course.reviewSummary = reviewSummary
                course.purchases = coursePurchases

                self.fetchMobileTiers(course: course).done { course in
                    CoreDataHelper.shared.save()
                    seal.fulfill(course)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func fetchCachedPurchases(courseID: Course.IdType) -> Promise<[CoursePurchase]> {
        Promise { seal in
            self.coursePurchasesPersistenceService.fetch(courseID: courseID).done { seal.fulfill($0) }
        }
    }

    private func fetchMobileTiers(course: Course) -> Guarantee<Course> {
        firstly { () -> Guarantee<[MobileTier]> in
            course.isPaid ? self.mobileTiersRepository.fetch(courseID: course.id) : .value([])
        }.then { mobileTiers -> Guarantee<Course> in
            course.mobileTiers = mobileTiers
            return .value(course)
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
