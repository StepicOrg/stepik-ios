import Foundation

enum CourseListFilter {
    /// Present filters
    enum CourseListFilterLoad {
        struct Request {}

        struct Data {
            let courseLanguage: CourseListFilter.Filter.CourseLanguage?
            let isFree: Bool?
            let withCertificate: Bool?
        }

        struct Response {
            let data: Data
        }

        struct ViewModel {
            let viewModel: CourseListFilterViewModel
        }
    }

    /// Applu filter to course list
    enum CourseListFilterApply {
        struct Request {
            let courseLanguage: CourseListFilter.Filter.CourseLanguage?
            let isFree: Bool?
            let withCertificate: Bool?
        }
    }

    // MARK: Inner Types

    // Use it for module initializing
    struct PresentationDescription {
        let availableFilters: FilterOptionSet
        let prefilledFilters: [Filter]

        struct FilterOptionSet: OptionSet {
            let rawValue: Int

            static let courseLanguage = FilterOptionSet(rawValue: 1 << 0)
            static let isPaid = FilterOptionSet(rawValue: 1 << 1)
            static let withCertificate = FilterOptionSet(rawValue: 1 << 2)

            static let all: FilterOptionSet = [.courseLanguage, .withCertificate, .isPaid]
        }
    }

    enum Filter {
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

        enum CourseLanguage: String, CaseIterable, UniqueIdentifiable {
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
