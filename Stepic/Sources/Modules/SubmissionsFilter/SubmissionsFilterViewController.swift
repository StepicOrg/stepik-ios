import UIKit

protocol SubmissionsFilterViewControllerProtocol: AnyObject {
    func displaySubmissionsFilter(viewModel: SubmissionsFilter.SubmissionsFilterLoad.ViewModel)
}

extension SubmissionsFilterViewController {
    struct Appearance {
        let navigationBarTintColor = UIColor.stepikVioletFixed

        let switchOnTintColor = UIColor.stepikVioletFixed

        let showResultCellBackgroundColor = UIColor.stepikVioletFixed
        let showResultCellTextColor = UIColor.white
    }
}

final class SubmissionsFilterViewController: UIViewController {
    private let interactor: SubmissionsFilterInteractorProtocol
    private let appearance: Appearance

    var submissionsFilterView: SubmissionsFilterView? { self.view as? SubmissionsFilterView }

    private var currentFilterData: SubmissionsFilter.FilterData?

    init(
        interactor: SubmissionsFilterInteractorProtocol,
        appearance: Appearance = .init()
    ) {
        self.interactor = interactor
        self.appearance = appearance

        super.init(nibName: nil, bundle: nil)

        self.title = NSLocalizedString("SubmissionsFilterTitle", comment: "")
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SubmissionsFilterView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

        self.interactor.doSubmissionsFilterLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.setNeedsNavigationBarAppearanceUpdate(sender: self)
        }
    }

    // MARK: Private API

    @objc
    private func closeClicked() {
        self.dismiss(animated: true)
    }

    @objc
    private func resetClicked() {
        self.interactor.doSubmissionsFilterReset(request: .init())
    }

    private enum Section: String, UniqueIdentifiable {
        case submissionStatus
        case order
        case reviewStatus
        case showResult

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }

        var title: String {
            switch self {
            case .submissionStatus:
                return NSLocalizedString("SubmissionsFilterSectionSubmissionStatusTitle", comment: "")
            case .order:
                return NSLocalizedString("SubmissionsFilterSectionOrderTitle", comment: "")
            case .reviewStatus:
                return NSLocalizedString("SubmissionsFilterSectionReviewStatusTitle", comment: "")
            case .showResult:
                return NSLocalizedString("SubmissionsFilterSectionShowResultTitle", comment: "")
            }
        }
    }
}

extension SubmissionsFilterViewController: SubmissionsFilterViewControllerProtocol {
    func displaySubmissionsFilter(viewModel: SubmissionsFilter.SubmissionsFilterLoad.ViewModel) {
        self.currentFilterData = viewModel.data
        self.display(newFilterData: viewModel.data)
    }

    // MARK: Private Helpers

    private func display(newFilterData data: SubmissionsFilter.FilterData) {
        var sections = [SettingsTableSectionViewModel]()

        if let selectedSubmissionStatus = data.submissionStatus {
            let submissionStatusCells = SubmissionsFilter.Filter.SubmissionStatus.allCases.map { status in
                SettingsTableSectionViewModel.Cell(
                    uniqueIdentifier: status.uniqueIdentifier,
                    type: .rightDetail(
                        options: RightDetailCellOptions(
                            title: .init(text: status.title),
                            detailType: .checkBox(
                                .init(
                                    isOn: selectedSubmissionStatus == status,
                                    checkBoxGroup: Section.submissionStatus.uniqueIdentifier,
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
                    header: .init(title: Section.submissionStatus.title),
                    cells: submissionStatusCells,
                    footer: nil
                )
            )
        }

        if let selectedOrder = data.order {
            let orderCells = SubmissionsFilter.Filter.Order.allCases.map { order in
                SettingsTableSectionViewModel.Cell(
                    uniqueIdentifier: order.uniqueIdentifier,
                    type: .rightDetail(
                        options: RightDetailCellOptions(
                            title: .init(text: order.title),
                            detailType: .checkBox(
                                .init(
                                    isOn: selectedOrder == order,
                                    checkBoxGroup: Section.order.uniqueIdentifier,
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
                    header: .init(title: Section.order.title),
                    cells: orderCells,
                    footer: nil
                )
            )
        }

        if let selectedReviewStatus = data.reviewStatus {
            let reviewStatusCells = SubmissionsFilter.Filter.ReviewStatus.allCases.map { status in
                SettingsTableSectionViewModel.Cell(
                    uniqueIdentifier: status.uniqueIdentifier,
                    type: .rightDetail(
                        options: RightDetailCellOptions(
                            title: .init(text: status.title),
                            detailType: .checkBox(
                                .init(
                                    isOn: selectedReviewStatus == status,
                                    checkBoxGroup: Section.reviewStatus.uniqueIdentifier,
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
                    header: .init(title: Section.reviewStatus.title),
                    cells: reviewStatusCells,
                    footer: nil
                )
            )
        }

        let showResultCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Section.showResult.uniqueIdentifier,
            type: .rightDetail(
                options: .init(
                    title: .init(
                        text: Section.showResult.title,
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

        self.submissionsFilterView?.configure(viewModel: SettingsTableViewModel(sections: sections))
    }
}

extension SubmissionsFilterViewController: SubmissionsFilterViewDelegate {
    func settingsTableView(
        _ tableView: SettingsTableView,
        didSelectCell cell: SettingsTableSectionViewModel.Cell,
        at indexPath: IndexPath
    ) {
        guard Section(rawValue: cell.uniqueIdentifier) == .showResult else {
            return
        }

        self.handleShowResultClicked()
    }

    func settingsCell(_ cell: SettingsRightDetailCheckboxTableViewCell, checkboxValueChanged isOn: Bool) {
        if let selectedSubmissionStatus = SubmissionsFilter.Filter.SubmissionStatus.allCases.first(
            where: { $0.uniqueIdentifier == cell.uniqueIdentifier }
        ) {
            self.currentFilterData?.submissionStatus = selectedSubmissionStatus
        } else if let selectedOrder = SubmissionsFilter.Filter.Order.allCases.first(
            where: { $0.uniqueIdentifier == cell.uniqueIdentifier }
        ) {
            self.currentFilterData?.order = selectedOrder
        } else if let selectedReviewStatus = SubmissionsFilter.Filter.ReviewStatus.allCases.first(
            where: { $0.uniqueIdentifier == cell.uniqueIdentifier }
        ) {
            self.currentFilterData?.reviewStatus = selectedReviewStatus
        }
    }

    // MARK: Private Helpers

    private func handleShowResultClicked() {
        guard let filterData = self.currentFilterData else {
            return
        }

        self.interactor.doSubmissionsFilterApply(request: .init(data: filterData))

        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension SubmissionsFilterViewController: StyledNavigationControllerPresentable {
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
