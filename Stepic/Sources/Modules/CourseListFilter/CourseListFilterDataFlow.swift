import Foundation

enum CourseListFilter {
    struct FilterData {
        let courseLanguage: CourseListFilter.Filter.CourseLanguage?
        let isFree: Bool?
        let withCertificate: Bool?
    }

    /// Present filters
    enum CourseListFilterLoad {
        struct Request {}

        struct Response {
            let data: FilterData
        }

        struct ViewModel {
            let viewModel: CourseListFilterViewModel
        }
    }

    /// Apply filters to course list
    enum CourseListFilterApply {
        struct Request {
            let data: FilterData
        }
    }

    /// Reset filters state
    enum CourseListFilterReset {
        struct Request {}
    }

    // MARK: Inner Types

    // Use it for module initializing
    struct PresentationDescription {
        let availableFilters: FilterOptionSet
        let prefilledFilters: [Filter]
        let defaultCourseLanguage: Filter.CourseLanguage?

        struct FilterOptionSet: OptionSet {
            let rawValue: Int

            static let courseLanguage = FilterOptionSet(rawValue: 1 << 0)
            static let isPaid = FilterOptionSet(rawValue: 1 << 1)
            static let withCertificate = FilterOptionSet(rawValue: 1 << 2)

            static let all: FilterOptionSet = [.courseLanguage, .withCertificate, .isPaid]
        }
    }

    enum Filter: Equatable {
        case courseLanguage(CourseLanguage)
        case isPaid(Bool)
        case withCertificate(Bool)

        var dictValue: JSONDictionary? {
            switch self {
            case .courseLanguage(let language):
                return language.dictValue
            case .isPaid(let isOn):
                return ["is_paid": isOn]
            case .withCertificate(let isOn):
                return ["with_certificate": isOn]
            }
        }

        enum CourseLanguage: String, CaseIterable, Equatable, UniqueIdentifiable {
            case any
            case russian
            case english

            var uniqueIdentifier: UniqueIdentifierType { "CourseLanguage\(self.rawValue)" }

            var title: String {
                switch self {
                case .any:
                    return NSLocalizedString("CourseListFilterCourseLanguageAnyTitle", comment: "")
                case .russian:
                    return "Русский"
                case .english:
                    return "English"
                }
            }

            var dictValue: JSONDictionary? {
                let valueOrNil: String? = {
                    switch self {
                    case .any:
                        return nil
                    case .russian:
                        return "ru"
                    case .english:
                        return "en"
                    }
                }()

                if let value = valueOrNil {
                    return ["language": value]
                }

                return nil
            }

            init(contentLanguage: ContentLanguage) {
                switch contentLanguage {
                case .english:
                    self = .english
                case .russian:
                    self = .russian
                }
            }
        }
    }
}
