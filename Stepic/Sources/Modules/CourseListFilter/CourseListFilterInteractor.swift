import Foundation
import PromiseKit

protocol CourseListFilterInteractorProtocol {
    func doCourseListFilterLoad(request: CourseListFilter.CourseListFilterLoad.Request)
}

final class CourseListFilterInteractor: CourseListFilterInteractorProtocol {
    weak var moduleOutput: CourseListFilterOutputProtocol?

    private let presenter: CourseListFilterPresenterProtocol
    private let presentationDescription: CourseListFilter.PresentationDescription

    private let contentLanguageService: ContentLanguageServiceProtocol

    private var mutableState = MutableState()

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
                let globalContentLanguage = self.contentLanguageService.globalContentLanguage
                self.mutableState.courseLanguage = .init(contentLanguage: globalContentLanguage)
            }
        }
        if availableFilters.contains(.isPaid) {
            let isPaidOrNil = prefilledFilters.compactMap { filter -> Bool? in
                if case .isPaid(let boolValue) = filter {
                    return boolValue
                }
                return nil
            }.first

            self.mutableState.isPaid = isPaidOrNil ?? false
        }
        if availableFilters.contains(.withCertificate) {
            let withCertificateOrNil = prefilledFilters.compactMap { filter -> Bool? in
                if case .withCertificate(let boolValue) = filter {
                    return boolValue
                }
                return nil
            }.first

            self.mutableState.withCertificate = withCertificateOrNil ?? false
        }
    }

    private func presentCourseListFiltersFromCurrentState() {
        self.presenter.presentCourseListFilters(
            response: .init(
                data: .init(
                    courseLanguage: self.mutableState.courseLanguage,
                    isPaid: self.mutableState.isPaid,
                    withCertificate: self.mutableState.withCertificate
                )
            )
        )
    }

    // MARK: Types

    private struct MutableState {
        var courseLanguage: CourseListFilter.Filter.CourseLanguage?
        var isPaid: Bool?
        var withCertificate: Bool?
    }
}
