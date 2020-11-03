import Foundation
import PromiseKit

protocol CourseListFilterInteractorProtocol {
    func doCourseListFilterLoad(request: CourseListFilter.CourseListFilterLoad.Request)
    func doCourseListFilterApply(request: CourseListFilter.CourseListFilterApply.Request)
    func doCourseListFilterReset(request: CourseListFilter.CourseListFilterReset.Request)
}

final class CourseListFilterInteractor: CourseListFilterInteractorProtocol {
    weak var moduleOutput: CourseListFilterOutputProtocol?

    private let presenter: CourseListFilterPresenterProtocol
    private let presentationDescription: CourseListFilter.PresentationDescription

    private let contentLanguageService: ContentLanguageServiceProtocol

    private var mutableState = MutableState()
    private var defaultState = MutableState()

    init(
        presenter: CourseListFilterPresenterProtocol,
        presentationDescription: CourseListFilter.PresentationDescription,
        contentLanguageService: ContentLanguageServiceProtocol
    ) {
        self.presenter = presenter
        self.presentationDescription = presentationDescription
        self.contentLanguageService = contentLanguageService

        self.initMutableState()
    }

    func doCourseListFilterLoad(request: CourseListFilter.CourseListFilterLoad.Request) {
        self.presentCourseListFiltersFromCurrentState()
    }

    func doCourseListFilterApply(request: CourseListFilter.CourseListFilterApply.Request) {
        self.mutableState.courseLanguage = request.data.courseLanguage
        self.mutableState.isFree = request.data.isFree
        self.mutableState.withCertificate = request.data.withCertificate

        var finalState = MutableState(courseLanguage: self.mutableState.courseLanguage)
        if self.mutableState.isFree ?? false {
            finalState.isFree = true
        }
        if self.mutableState.withCertificate ?? false {
            finalState.withCertificate = true
        }

        self.moduleOutput?.handleCourseListFilterDidFinishWithFilters(finalState.filters)
    }

    func doCourseListFilterReset(request: CourseListFilter.CourseListFilterReset.Request) {
        self.mutableState = self.defaultState
        self.presentCourseListFiltersFromCurrentState()
    }

    // MARK: Private API

    private func initMutableState() {
        let availableFilters = self.presentationDescription.availableFilters
        let prefilledFilters = self.presentationDescription.prefilledFilters

        if availableFilters.contains(.courseLanguage) {
            let courseLanguageOrNil = prefilledFilters.compactMap { filter -> CourseListFilter.Filter.CourseLanguage? in
                if case .courseLanguage(let courseLanguage) = filter {
                    return courseLanguage
                }
                return nil
            }.first

            if let courseLanguage = courseLanguageOrNil {
                self.mutableState.courseLanguage = courseLanguage
            } else {
                self.mutableState.courseLanguage = .init(
                    contentLanguage: self.contentLanguageService.globalContentLanguage
                )
            }

            if let defaultCourseLanguage = self.presentationDescription.defaultCourseLanguage {
                self.defaultState.courseLanguage = defaultCourseLanguage
            } else {
                self.defaultState.courseLanguage = .init(
                    contentLanguage: self.contentLanguageService.globalContentLanguage
                )
            }
        }
        if availableFilters.contains(.isPaid) {
            let isPaidOrNil = prefilledFilters.compactMap { filter -> Bool? in
                if case .isPaid(let boolValue) = filter {
                    return boolValue
                }
                return nil
            }.first

            self.mutableState.isFree = isPaidOrNil == false ? true : false
            self.defaultState.isFree = false
        }
        if availableFilters.contains(.withCertificate) {
            let withCertificateOrNil = prefilledFilters.compactMap { filter -> Bool? in
                if case .withCertificate(let boolValue) = filter {
                    return boolValue
                }
                return nil
            }.first

            self.mutableState.withCertificate = withCertificateOrNil ?? false
            self.defaultState.withCertificate = false
        }
    }

    private func presentCourseListFiltersFromCurrentState() {
        self.presenter.presentCourseListFilters(
            response: .init(
                data: .init(
                    courseLanguage: self.mutableState.courseLanguage,
                    isFree: self.mutableState.isFree,
                    withCertificate: self.mutableState.withCertificate
                )
            )
        )
    }

    // MARK: Types

    private struct MutableState {
        var courseLanguage: CourseListFilter.Filter.CourseLanguage?
        var withCertificate: Bool?
        var isFree: Bool?

        var filters: [CourseListFilter.Filter] {
            var result = [CourseListFilter.Filter]()

            if let courseLanguage = self.courseLanguage {
                result.append(.courseLanguage(courseLanguage))
            }

            if let withCertificate = self.withCertificate {
                result.append(.withCertificate(withCertificate))
            }

            if let isFree = self.isFree {
                result.append(.isPaid(!isFree))
            }

            return result
        }
    }
}
