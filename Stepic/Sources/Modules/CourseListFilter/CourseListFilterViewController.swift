import UIKit

protocol CourseListFilterViewControllerProtocol: AnyObject {
    func displayCourseListFilters(viewModel: CourseListFilter.CourseListFilterLoad.ViewModel)
}

extension CourseListFilterViewController {
    struct Appearance {
        let navigationBarTintColor = UIColor.stepikVioletFixed

        let switchOnTintColor = UIColor.stepikVioletFixed

        let showResultCellBackgroundColor = UIColor.stepikVioletFixed
        let showResultCellTextColor = UIColor.white
    }
}

final class CourseListFilterViewController: UIViewController {
    private let interactor: CourseListFilterInteractorProtocol

    let appearance = Appearance()

    var courseListFilterView: CourseListFilterView? { self.view as? CourseListFilterView }

    init(interactor: CourseListFilterInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseListFilterView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.interactor.doCourseListFilterLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.setNeedsNavigationBarAppearanceUpdate(sender: self)
        }
    }

    // MARK: Private API

    private func setup() {
        self.title = NSLocalizedString("CourseListFilterTitle", comment: "")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("CourseListFilterResetButtonTitle", comment: ""),
            style: .plain,
            target: nil,
            action: #selector(self.resetClicked)
        )
    }

    @objc
    private func resetClicked() {
    }

    // MARK: Types

    private enum Section {
        case courseLanguage
        case courseDetails

        var title: String {
            switch self {
            case .courseLanguage:
                return NSLocalizedString("CourseListFilterSectionCourseLanguageTitle", comment: "")
            case .courseDetails:
                return NSLocalizedString("CourseListFilterSectionCourseDetailsTitle", comment: "")
            }
        }
    }

    private enum Row: String, UniqueIdentifiable {
        case withCertificate
        case isFree
        case showResult

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }

        var title: String {
            switch self {
            case .withCertificate:
                return NSLocalizedString("CourseListFilterRowWithCertificateTitle", comment: "")
            case .isFree:
                return NSLocalizedString("CourseListFilterRowIsFreeTitle", comment: "")
            case .showResult:
                return NSLocalizedString("CourseListFilterRowShowResultTitle", comment: "")
            }
        }
    }
}

extension CourseListFilterViewController: CourseListFilterViewControllerProtocol {
    func displayCourseListFilters(viewModel: CourseListFilter.CourseListFilterLoad.ViewModel) {
        var sections = [SettingsTableSectionViewModel]()

        if let courseLanguage = viewModel.viewModel.courseLanguage {
            let courseLanguageCells = CourseListFilter.Filter.CourseLanguage.allCases.map { language in
                SettingsTableSectionViewModel.Cell(
                    uniqueIdentifier: courseLanguage.uniqueIdentifier,
                    type: .rightDetail(
                        options: RightDetailCellOptions(
                            title: .init(text: language.title),
                            detailType: .switch(
                                .init(
                                    isOn: courseLanguage == language,
                                    appearance: .init(onTintColor: self.appearance.switchOnTintColor)
                                )
                            ),
                            accessoryType: .none
                        )
                    )
                )
            }

            sections.append(
                .init(
                    header: .init(title: Section.courseLanguage.title),
                    cells: courseLanguageCells,
                    footer: nil
                )
            )
        }

        if viewModel.viewModel.withCertificate != nil || viewModel.viewModel.isPaid != nil {
            var courseDetailsCells = [SettingsTableSectionViewModel.Cell]()

            if let withCertificate = viewModel.viewModel.withCertificate {
                courseDetailsCells.append(
                    SettingsTableSectionViewModel.Cell(
                        uniqueIdentifier: Row.withCertificate.uniqueIdentifier,
                        type: .rightDetail(
                            options: RightDetailCellOptions(
                                title: .init(text: Row.withCertificate.title),
                                detailType: .switch(
                                    .init(
                                        isOn: withCertificate,
                                        appearance: .init(onTintColor: self.appearance.switchOnTintColor)
                                    )
                                ),
                                accessoryType: .none
                            )
                        )
                    )
                )
            }

            if let isPaid = viewModel.viewModel.isPaid {
                courseDetailsCells.append(
                    SettingsTableSectionViewModel.Cell(
                        uniqueIdentifier: Row.isFree.uniqueIdentifier,
                        type: .rightDetail(
                            options: RightDetailCellOptions(
                                title: .init(text: Row.isFree.title),
                                detailType: .switch(
                                    .init(
                                        isOn: isPaid,
                                        appearance: .init(onTintColor: self.appearance.switchOnTintColor)
                                    )
                                ),
                                accessoryType: .none
                            )
                        )
                    )
                )
            }

            sections.append(
                .init(
                    header: .init(title: Section.courseDetails.title),
                    cells: courseDetailsCells,
                    footer: nil
                )
            )
        }

        let showResultCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.showResult.uniqueIdentifier,
            type: .rightDetail(
                options: .init(
                    title: .init(
                        text: Row.showResult.title,
                        appearance: .init(
                            textColor: self.appearance.showResultCellTextColor,
                            textAlignment: .center
                        )
                    ),
                    accessoryType: .none
                )
            ),
            appearance: .init(
                backgroundColor: self.appearance.showResultCellBackgroundColor,
                selectedBackgroundColor: self.appearance.showResultCellBackgroundColor.withAlphaComponent(0.5)
            )
        )
        sections.append(.init(header: nil, cells: [showResultCell], footer: nil))

        self.courseListFilterView?.configure(viewModel: SettingsTableViewModel(sections: sections))
    }
}

// MARK: - CourseListFilterViewController: StyledNavigationControllerPresentable -

extension CourseListFilterViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        var appearance: StyledNavigationController.NavigationBarAppearanceState = {
            if #available(iOS 13.0, *) {
                return .pageSheetAppearance()
            } else {
                return .init()
            }
        }()
        appearance.tintColor = self.appearance.navigationBarTintColor

        return appearance
    }
}
