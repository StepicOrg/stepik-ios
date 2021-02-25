import Foundation

enum SubmissionsFilter {
    struct FilterData {
        var submissionStatus: SubmissionsFilter.Filter.SubmissionStatus?
        var order: SubmissionsFilter.Filter.Order?
        var reviewStatus: SubmissionsFilter.Filter.ReviewStatus?
    }

    /// Present filters
    enum SubmissionsFilterLoad {
        struct Request {}

        struct Response {
            let data: FilterData
        }

        struct ViewModel {
            let data: FilterData
        }
    }

    /// Apply filters to module output
    enum SubmissionsFilterApply {
        struct Request {
            let data: FilterData
        }
    }

    /// Reset filters state
    enum SubmissionsFilterReset {
        struct Request {}
    }

    // MARK: Inner Types

    // Use it for module initializing
    struct PresentationDescription {
        let availableFilters: FilterOptionSet
        let prefilledFilters: [Filter]

        struct FilterOptionSet: OptionSet {
            let rawValue: Int

            static let submissionStatus = FilterOptionSet(rawValue: 1 << 0)
            static let order = FilterOptionSet(rawValue: 1 << 1)
            static let reviewStatus = FilterOptionSet(rawValue: 1 << 2)

            static let `default`: FilterOptionSet = [.submissionStatus, .order]
            static let withPeerReview: FilterOptionSet = [.submissionStatus, .order, .reviewStatus]
        }
    }

    enum Filter: Equatable {
        case submissionStatus(SubmissionStatus)
        case order(Order)
        case reviewStatus(ReviewStatus)

        var dictValue: JSONDictionary? {
            switch self {
            case .submissionStatus(let status):
                return status.dictValue
            case .order(let order):
                return order.dictValue
            case .reviewStatus(let status):
                return status.dictValue
            }
        }

        enum SubmissionStatus: String, CaseIterable, UniqueIdentifiable {
            case any
            case correct
            case wrong
            case evaluation

            static var `default`: SubmissionStatus { .any }

            var uniqueIdentifier: UniqueIdentifierType { "SubmissionStatus\(self.rawValue)" }

            var title: String {
                switch self {
                case .any:
                    return NSLocalizedString("SubmissionsFilterSubmissionStatusAnyTitle", comment: "")
                case .correct:
                    return NSLocalizedString("SubmissionsFilterSubmissionStatusCorrectTitle", comment: "")
                case .wrong:
                    return NSLocalizedString("SubmissionsFilterSubmissionStatusWrongTitle", comment: "")
                case .evaluation:
                    return NSLocalizedString("SubmissionsFilterSubmissionStatusEvaluationTitle", comment: "")
                }
            }

            var dictValue: JSONDictionary? {
                if self == .any {
                    return nil
                }
                return ["status": self.rawValue]
            }
        }

        enum Order: String, CaseIterable, UniqueIdentifiable {
            case ascending = "asc"
            case descending = "desc"

            static var `default`: Order { .descending }

            var uniqueIdentifier: UniqueIdentifierType { "Order\(self.rawValue)" }

            var title: String {
                switch self {
                case .ascending:
                    return NSLocalizedString("SubmissionsFilterOrderAscendingTitle", comment: "")
                case .descending:
                    return NSLocalizedString("SubmissionsFilterOrderDescendingTitle", comment: "")
                }
            }

            var dictValue: JSONDictionary {
                ["order": self.rawValue]
            }
        }

        enum ReviewStatus: String, CaseIterable, UniqueIdentifiable {
            case any
            case done
            case awaiting

            static var `default`: ReviewStatus { .any }

            var uniqueIdentifier: UniqueIdentifierType { "ReviewStatus\(self.rawValue)" }

            var title: String {
                switch self {
                case .any:
                    return NSLocalizedString("SubmissionsFilterReviewStatusAnyTitle", comment: "")
                case .done:
                    return NSLocalizedString("SubmissionsFilterReviewStatusDoneTitle", comment: "")
                case .awaiting:
                    return NSLocalizedString("SubmissionsFilterReviewStatusAwaitingTitle", comment: "")
                }
            }

            var dictValue: JSONDictionary? {
                if self == .any {
                    return nil
                }
                return ["review_status": self.rawValue]
            }
        }
    }
}
