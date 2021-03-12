import UIKit

protocol CourseInfoTabSyllabusViewControllerProtocol: AnyObject {
    func displaySyllabus(viewModel: CourseInfoTabSyllabus.SyllabusLoad.ViewModel)
    func displayDownloadButtonStateUpdate(viewModel: CourseInfoTabSyllabus.DownloadButtonStateUpdate.ViewModel)
    func displayDeleteDownloadsConfirmationAlert(viewModel: CourseInfoTabSyllabus.DeleteDownloadsConfirmation.ViewModel)
    func displaySyllabusHeader(viewModel: CourseInfoTabSyllabus.SyllabusHeaderUpdate.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: CourseInfoTabSyllabus.BlockingWaitingIndicatorUpdate.ViewModel)
    func displayFailedDownloadAlert(viewModel: CourseInfoTabSyllabus.FailedDownloadAlertPresentation.ViewModel)
    func displayDownloadOnCellularDataAlert(viewModel: CourseInfoTabSyllabus.DownloadOnCellularDataAlert.ViewModel)
}

protocol CourseInfoTabSyllabusViewControllerDelegate: AnyObject {
    func sectionWillDisplay(_ section: CourseInfoTabSyllabusSectionViewModel)
    func cellDidSelect(_ cell: CourseInfoTabSyllabusUnitViewModel)
    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusUnitViewModel)
    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusSectionViewModel)
}

// MARK: - CourseInfoTabSyllabusViewController: UIViewController -

final class CourseInfoTabSyllabusViewController: UIViewController {
    private let interactor: CourseInfoTabSyllabusInteractorProtocol
    private var state: CourseInfoTabSyllabus.ViewControllerState

    // swiftlint:disable:next weak_delegate
    private let syllabusTableDelegate: CourseInfoTabSyllabusTableViewDataSource

    lazy var courseInfoTabSyllabusView = self.view as? CourseInfoTabSyllabusView

    private lazy var personalDeadlinesTooltip = TooltipFactory.personalDeadlinesButton

    init(
        interactor: CourseInfoTabSyllabusInteractorProtocol,
        initialState: CourseInfoTabSyllabus.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        self.syllabusTableDelegate = CourseInfoTabSyllabusTableViewDataSource()

        super.init(nibName: nil, bundle: nil)
        self.syllabusTableDelegate.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseInfoTabSyllabusView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
    }

    // MARK: Private API

    private func updateState(newState: CourseInfoTabSyllabus.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.courseInfoTabSyllabusView?.hideError()
            self.courseInfoTabSyllabusView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.courseInfoTabSyllabusView?.hideError()
            self.courseInfoTabSyllabusView?.hideLoading()
        }

        switch newState {
        case .loading:
            break
        case .error:
            self.courseInfoTabSyllabusView?.showError()
        case .result(let data):
            self.courseInfoTabSyllabusView?.hideError()

            self.syllabusTableDelegate.update(viewModels: data)
            self.courseInfoTabSyllabusView?.updateTableViewData(delegate: self.syllabusTableDelegate)
        }
    }
}

// MARK: - CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerProtocol -

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerProtocol {
    func displaySyllabus(viewModel: CourseInfoTabSyllabus.SyllabusLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displaySyllabusHeader(viewModel: CourseInfoTabSyllabus.SyllabusHeaderUpdate.ViewModel) {
        guard let courseInfoTabSyllabusView = self.courseInfoTabSyllabusView else {
            return
        }

        if viewModel.data.isDeadlineButtonVisible && viewModel.data.isDeadlineTooltipVisible {
            // Cause anchor parent should have correct layout
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                courseInfoTabSyllabusView.setNeedsLayout()
                courseInfoTabSyllabusView.layoutIfNeeded()
                self?.personalDeadlinesTooltip.show(
                    direction: .up,
                    in: courseInfoTabSyllabusView.deadlinesButtonTooltipContainerView,
                    from: courseInfoTabSyllabusView.deadlinesButtonTooltipAnchorView
                )
            }
        }

        self.courseInfoTabSyllabusView?.configure(headerViewModel: viewModel.data)
    }

    func displayDownloadButtonStateUpdate(viewModel: CourseInfoTabSyllabus.DownloadButtonStateUpdate.ViewModel) {
        switch viewModel.data {
        case .section(let viewModel):
            self.syllabusTableDelegate.mergeViewModel(section: viewModel)
        case .unit(let viewModel):
            self.syllabusTableDelegate.mergeViewModel(unit: viewModel)
        }
    }

    func displayDeleteDownloadsConfirmationAlert(
        viewModel: CourseInfoTabSyllabus.DeleteDownloadsConfirmation.ViewModel
    ) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)

        viewModel.actions.forEach { action in
            let style: UIAlertAction.Style = {
                switch action.style {
                case .cancel:
                    return .cancel
                case .destructive:
                    return .destructive
                }
            }()

            alert.addAction(UIAlertAction(title: action.title, style: style, handler: { _ in action.handler() }))
        }

        self.present(alert, animated: true)
    }

    func displayDownloadOnCellularDataAlert(viewModel: CourseInfoTabSyllabus.DownloadOnCellularDataAlert.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)

        viewModel.actions.forEach { action in
            let style: UIAlertAction.Style = {
                switch action.style {
                case .cancel:
                    return .cancel
                case .default:
                    return .default
                }
            }()

            alert.addAction(UIAlertAction(title: action.title, style: style, handler: { _ in action.handler() }))
        }

        self.present(alert, animated: true)
    }

    func displayBlockingLoadingIndicator(viewModel: CourseInfoTabSyllabus.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    func displayFailedDownloadAlert(viewModel: CourseInfoTabSyllabus.FailedDownloadAlertPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
        self.present(alert, animated: true)
    }
}

// MARK: - CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerDelegate -

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerDelegate {
    func sectionWillDisplay(_ section: CourseInfoTabSyllabusSectionViewModel) {
        self.interactor.doSectionFetch(request: .init(uniqueIdentifier: section.uniqueIdentifier))
    }

    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusUnitViewModel) {
        self.interactor.doDownloadButtonAction(request: .init(type: .unit(uniqueIdentifier: cell.uniqueIdentifier)))
    }

    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusSectionViewModel) {
        self.interactor.doDownloadButtonAction(request: .init(type: .section(uniqueIdentifier: cell.uniqueIdentifier)))
    }

    func cellDidSelect(_ cell: CourseInfoTabSyllabusUnitViewModel) {
        self.interactor.doUnitSelection(request: .init(uniqueIdentifier: cell.uniqueIdentifier))
    }
}

// MARK: - CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewDelegate -

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewDelegate {
    func courseInfoTabSyllabusViewDidClickDeadlines(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView) {
        self.interactor.doPersonalDeadlinesAction(request: .init())
    }

    func courseInfoTabSyllabusViewDidClickDownloadAll(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView) {
        self.interactor.doDownloadButtonAction(request: .init(type: .all))
    }

    func courseInfoTabSyllabusViewDidClickErrorPlaceholderAction(
        _ courseInfoTabSyllabusView: CourseInfoTabSyllabusView
    ) {
        self.updateState(newState: .loading)
        self.interactor.doSectionsFetch(request: .init())
    }
}
