import Foundation
import PromiseKit

protocol SubmissionsFilterInteractorProtocol {
    func doSubmissionsFilterLoad(request: SubmissionsFilter.SubmissionsFilterLoad.Request)
    func doSubmissionsFilterApply(request: SubmissionsFilter.SubmissionsFilterApply.Request)
    func doSubmissionsFilterReset(request: SubmissionsFilter.SubmissionsFilterReset.Request)
}

final class SubmissionsFilterInteractor: SubmissionsFilterInteractorProtocol {
    weak var moduleOutput: SubmissionsFilterOutputProtocol?

    private let presenter: SubmissionsFilterPresenterProtocol
    private let presentationDescription: SubmissionsFilter.PresentationDescription

    private var mutableState = MutableState()
    private var defaultState = MutableState()

    init(
        presenter: SubmissionsFilterPresenterProtocol,
        presentationDescription: SubmissionsFilter.PresentationDescription
    ) {
        self.presenter = presenter
        self.presentationDescription = presentationDescription

        self.initMutableState()
    }

    func doSubmissionsFilterLoad(request: SubmissionsFilter.SubmissionsFilterLoad.Request) {
        self.presentSubmissionsFilterFromCurrentState()
    }

    func doSubmissionsFilterApply(request: SubmissionsFilter.SubmissionsFilterApply.Request) {
        self.mutableState.submissionStatus = request.data.submissionStatus
        self.mutableState.order = request.data.order
        self.mutableState.reviewStatus = request.data.reviewStatus

        self.moduleOutput?.handleSubmissionsFilterDidFinishWithFilters(self.mutableState.filters)
        self.moduleOutput?.handleSubmissionsFilterActive(self.mutableState.filters != self.defaultState.filters)
    }

    func doSubmissionsFilterReset(request: SubmissionsFilter.SubmissionsFilterReset.Request) {
        self.mutableState = self.defaultState
        self.presentSubmissionsFilterFromCurrentState()
    }

    // MARK: Private API

    private func initMutableState() {
        let availableFilters = self.presentationDescription.availableFilters
        let prefilledFilters = self.presentationDescription.prefilledFilters

        if availableFilters.contains(.submissionStatus) {
            let statusOrNil = prefilledFilters.compactMap { filter -> SubmissionsFilter.Filter.SubmissionStatus? in
                if case .submissionStatus(let status) = filter {
                    return status
                }
                return nil
            }.first

            self.mutableState.submissionStatus = statusOrNil ?? .default
            self.defaultState.submissionStatus = .default
        }

        if availableFilters.contains(.order) {
            let orderOrNil = prefilledFilters.compactMap { filter -> SubmissionsFilter.Filter.Order? in
                if case .order(let order) = filter {
                    return order
                }
                return nil
            }.first

            self.mutableState.order = orderOrNil ?? .default
            self.defaultState.order = .default
        }

        if availableFilters.contains(.reviewStatus) {
            let statusOrNil = prefilledFilters.compactMap { filter -> SubmissionsFilter.Filter.ReviewStatus? in
                if case .reviewStatus(let status) = filter {
                    return status
                }
                return nil
            }.first

            self.mutableState.reviewStatus = statusOrNil ?? .default
            self.defaultState.reviewStatus = .default
        }
    }

    private func presentSubmissionsFilterFromCurrentState() {
        self.presenter.presentSubmissionsFilter(
            response: .init(
                data: .init(
                    submissionStatus: self.mutableState.submissionStatus,
                    order: self.mutableState.order,
                    reviewStatus: self.mutableState.reviewStatus
                )
            )
        )
    }

    // MARK: Types

    private struct MutableState {
        var submissionStatus: SubmissionsFilter.Filter.SubmissionStatus?
        var order: SubmissionsFilter.Filter.Order?
        var reviewStatus: SubmissionsFilter.Filter.ReviewStatus?

        var filters: [SubmissionsFilter.Filter] {
            var result = [SubmissionsFilter.Filter]()

            if let submissionStatus = self.submissionStatus {
                result.append(.submissionStatus(submissionStatus))
            }

            if let order = self.order {
                result.append(.order(order))
            }

            if let reviewStatus = self.reviewStatus {
                result.append(.reviewStatus(reviewStatus))
            }

            return result
        }
    }
}
