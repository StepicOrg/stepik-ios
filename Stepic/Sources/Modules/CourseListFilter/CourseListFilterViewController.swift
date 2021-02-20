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

    private var formState = FormState()

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
        view.delegate = self
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

        self.navigationItem.leftBarButtonItem = .stepikCloseBarButtonItem(
            target: self,
            action: #selector(self.closeClicked)
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("ResetButtonTitle", comment: ""),
            style: .plain,
            target: self,
            action: #selector(self.resetClicked)
        )
    }

    @objc
    private func closeClicked() {
        self.dismiss(animated: true)
    }

    @objc
    private func resetClicked() {
        self.interactor.doCourseListFilterReset(request: .init())
    }

    // MARK: Types

    private enum Section: String {
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

    private struct FormState {
        var courseLanguage: CourseListFilter.Filter.CourseLanguage?
        var isFree: Bool?
        var withCertificate: Bool?

        var data: CourseListFilter.FilterData {
            .init(
                courseLanguage: self.courseLanguage,
                isFree: self.isFree,
                withCertificate: self.withCertificate
            )
        }
    }
}

// MARK: - CourseListFilterViewController: CourseListFilterViewControllerProtocol -

extension CourseListFilterViewController: CourseListFilterViewControllerProtocol {
    func displayCourseListFilters(viewModel: CourseListFilter.CourseListFilterLoad.ViewModel) {
        self.formState = .init(
            courseLanguage: viewModel.viewModel.courseLanguage,
            isFree: viewModel.viewModel.isFree,
            withCertificate: viewModel.viewModel.withCertificate
        )

        self.display(newViewModel: viewModel.viewModel)
    }

    // MARK: Private Helpers

    private func display(newViewModel viewModel: CourseListFilterViewModel) {
        var sections = [SettingsTableSectionViewModel]()

        if let selectedCourseLanguage = viewModel.courseLanguage {
            let courseLanguageCells = CourseListFilter.Filter.CourseLanguage.allCases.map { anCourseLanguage in
                SettingsTableSectionViewModel.Cell(
                    uniqueIdentifier: anCourseLanguage.uniqueIdentifier,
                    type: .rightDetail(
                        options: RightDetailCellOptions(
                            title: .init(text: anCourseLanguage.title),
                            detailType: .checkBox(
                                .init(
                                    isOn: selectedCourseLanguage == anCourseLanguage,
                                    checkBoxGroup: Section.courseLanguage.rawValue,
                                    checkBoxGroupMustHaveSelection: true
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

        if viewModel.withCertificate != nil || viewModel.isFree != nil {
            var courseDetailsCells = [SettingsTableSectionViewModel.Cell]()

            if let withCertificate = viewModel.withCertificate {
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

            if let isPaid = viewModel.isFree {
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

// MARK: CourseListFilterViewController: CourseListFilterViewDelegate

extension CourseListFilterViewController: CourseListFilterViewDelegate {
    func settingsTableView(
        _ tableView: SettingsTableView,
        didSelectCell cell: SettingsTableSectionViewModel.Cell,
        at indexPath: IndexPath
    ) {
        guard let row = Row(rawValue: cell.uniqueIdentifier) else {
            return
        }

        guard case .showResult = row else {
            return
        }

        self.handleShowResultClicked()
    }

    func settingsCell(_ cell: SettingsRightDetailSwitchTableViewCell, switchValueChanged isOn: Bool) {
        guard let uniqueIdentifier = cell.uniqueIdentifier,
              let row = Row(rawValue: uniqueIdentifier) else {
            return
        }

        switch row {
        case .withCertificate:
            self.formState.withCertificate = isOn
        case .isFree:
            self.formState.isFree = isOn
        default:
            break
        }
    }

    func settingsCell(_ cell: SettingsRightDetailCheckboxTableViewCell, checkboxValueChanged isOn: Bool) {
        let courseLanguages = CourseListFilter.Filter.CourseLanguage.allCases

        guard let uniqueIdentifier = cell.uniqueIdentifier,
              courseLanguages.map(\.uniqueIdentifier).contains(uniqueIdentifier) else {
            return
        }

        if let selectedCourseLanguage = courseLanguages.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
            self.formState.courseLanguage = selectedCourseLanguage
        }
    }

    // MARK: Private Helpers

    private func handleShowResultClicked() {
        self.interactor.doCourseListFilterApply(request: .init(data: self.formState.data))

        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
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
