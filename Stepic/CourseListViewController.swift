//
//  CourseListViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SVProgressHUD

protocol CourseListViewControllerDelegate: class {
    func setupContentView()
    func setupRefresh()
    func reloadData()
    func setUserInteraction(enabled: Bool)

    func updatePagination()

    func indexesForVisibleCells() -> [Int]
    func indexPathForIndex(index: Int) -> IndexPath
    func addElements(atIndexPaths: [IndexPath])
    func updateCells(deletingIndexPaths: [IndexPath], insertingIndexPaths: [IndexPath])
    func widgetForCell(atIndex: Int) -> CourseWidgetView?

    func getSourceCellFor3dTouch(location: CGPoint) -> (view: UIView, index: Int)?
}

class CourseListViewController: UIViewController, CourseListView {
    var presenter: CourseListPresenter? {
        didSet {
            refresh()
        }
    }
    var refreshEnabled: Bool = true
    var paginationStatus: PaginationStatus = .none

    weak var delegate: CourseListViewControllerDelegate?

    var courses: [CourseViewData] = []

    var colorMode: CourseListColorMode! {
        didSet {
            switch colorMode! {
            case .dark:
                self.view.backgroundColor = UIColor.mainDark
            case .light:
                self.view.backgroundColor = UIColor.white
            }
        }
    }

    var shouldShowLoadingWidgets: Bool {
        return state == .emptyRefreshing
    }

    var state: CourseListState = .empty

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate?.setupContentView()
        setup3dTouch()
        if refreshEnabled {
            delegate?.setupRefresh()
        }
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.willAppear()
    }

    private func setup3dTouch() {
        if(traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    func refresh() {
        presenter?.refresh()
    }

    func display(courses: [CourseViewData]) {
        self.courses = courses
        delegate?.reloadData()
    }

    private func getChangedIndexes(changedCourses: [CourseViewData], courses: [CourseViewData]) -> [Int] {
        var changedIndexes: [Int] = []
        for (id, course) in courses.enumerated() {
            if let _ = changedCourses.filter({ $0.id == course.id }).first {
                changedIndexes += [id]
            }
        }
        return changedIndexes
    }

    func add(addedCourses: [CourseViewData], courses: [CourseViewData]) {
        self.courses = courses
        let addedIndexes: [Int] = getChangedIndexes(changedCourses: addedCourses, courses: courses)
        let addedIndexPaths = addedIndexes.flatMap({ delegate?.indexPathForIndex(index: $0) })

        delegate?.addElements(atIndexPaths: addedIndexPaths)
    }

    func update(updatedCourses: [CourseViewData], courses: [CourseViewData]) {
        self.courses = courses

        guard let visibleIndexesArray = delegate?.indexesForVisibleCells() else {
            return
        }

        let updatingIndexesArray: [Int] = getChangedIndexes(changedCourses: updatedCourses, courses: courses)
        let visibleIndexes = Set<Int>(visibleIndexesArray)
        let updatingIndexes = Set<Int>(updatingIndexesArray)
        let visibleUpdating = Array(updatingIndexes.intersection(visibleIndexes))
        for indexToUpdate in visibleUpdating {
            if let widgetView = delegate?.widgetForCell(atIndex: indexToUpdate) {
                widgetView.progress = courses[indexToUpdate].progress
                widgetView.rating = courses[indexToUpdate].rating
                widgetView.actionButtonState = courses[indexToUpdate].isEnrolled ? .continueLearning : .join
                widgetView.secondaryActionButtonState = courses[indexToUpdate].isEnrolled ? .info : .syllabus
            }
        }
    }

    var changedPlaceholderVisibleBlock: ((Bool) -> Void)?

    private func setPlaceholder(visible: Bool) {
        emptyPlaceholder.isHidden = !visible
        delegate?.setUserInteraction(enabled: !visible)
        changedPlaceholderVisibleBlock?(visible)
    }

    func setState(state: CourseListState) {
        self.state = state
        switch state {
        case .displaying:
            setPlaceholder(visible: false)
            break
        case .displayingWithError:
            setPlaceholder(visible: false)
            break
        case .displayingWithRefreshing:
            setPlaceholder(visible: false)
            break
        case .empty:
            delegate?.reloadData()
            emptyPlaceholder.onTap = nil
            if let listType = presenter?.listType {
                switch listType {
                case .enrolled:
                    emptyPlaceholder.text = NSLocalizedString("HomePlaceholderEmptyEnrolled", comment: "")
                case .popular:
                    emptyPlaceholder.text = NSLocalizedString("HomePlaceholderEmptyPopular", comment: "")
                case .search(query: _):
                    emptyPlaceholder.text = NSLocalizedString("SearchPlaceholderEmpty", comment: "")
                default:
                    emptyPlaceholder.text = "Empty"
                    break
                }
            }
            setPlaceholder(visible: true)
            break
        case .emptyError:
            delegate?.reloadData()
            emptyPlaceholder.onTap = {
                [weak self] in
                self?.presenter?.refresh()
            }
            if let listType = presenter?.listType {
                switch listType {
                case .enrolled:
                    emptyPlaceholder.text = NSLocalizedString("HomePlaceHolderErrorEnrolled", comment: "")
                case .popular:
                    emptyPlaceholder.text = NSLocalizedString("HomePlaceholderErrorPopular", comment: "")
                case .search(query: _):
                    emptyPlaceholder.text = NSLocalizedString("SearchPlaceholderError", comment: "")
                default:
                    emptyPlaceholder.text = "Error"
                    break
                }
            }
            setPlaceholder(visible: true)
            break
        case .emptyRefreshing:
            delegate?.reloadData()
            setPlaceholder(visible: false)
            delegate?.setUserInteraction(enabled: false)
            break
        case .emptyAnonymous:
            delegate?.reloadData()
            emptyPlaceholder.text = NSLocalizedString("HomePlaceholderAnonymous", comment: "")
            emptyPlaceholder.onTap = {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                RoutingManager.auth.routeFrom(controller: strongSelf, success: nil, cancel: nil)
            }
            setPlaceholder(visible: true)
            break
        }
    }

    func setPaginationStatus(status: PaginationStatus) {
        paginationStatus = status
        delegate?.updatePagination()
    }

    func present(controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }

    func show(controller: UIViewController) {
        show(controller, sender: self)
    }

    func update(deletingIds: [Int], insertingIds: [Int], courses: [CourseViewData]) {
        guard self.courses.count - deletingIds.count + insertingIds.count == courses.count else {
            self.courses = courses
            delegate?.reloadData()
            return
        }
        self.courses = courses
        let deletingIndexPaths = deletingIds.flatMap({ delegate?.indexPathForIndex(index: $0) })
        let insertingIndexPaths = insertingIds.flatMap({ delegate?.indexPathForIndex(index: $0) })
        delegate?.updateCells(deletingIndexPaths: deletingIndexPaths, insertingIndexPaths: insertingIndexPaths)
    }

    func getNavigationController() -> UINavigationController? {
        return self.navigationController
    }

    func getController() -> UIViewController? {
        return self
    }

    func startProgressHUD() {
        SVProgressHUD.show()
    }

    func finishProgressHUD(success: Bool, message: String) {
        if success {
            SVProgressHUD.showSuccess(withStatus: message)
        } else {
            SVProgressHUD.showError(withStatus: message)
        }
    }

    lazy var emptyPlaceholder: CourseListEmptyPlaceholder = {
        let placeholder = CourseListEmptyPlaceholder(frame: CGRect.zero)
        self.view.addSubview(placeholder)
        placeholder.align(toView: self.view)
        placeholder.isHidden = true
        placeholder.colorStyle = .purple
        placeholder.presentationStyle = .bordered
        return placeholder
    }()
}

extension CourseListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let sourceView = delegate?.getSourceCellFor3dTouch(location: location) else {
            return nil
        }

        previewingContext.sourceRect = sourceView.view.frame

        return presenter?.getViewControllerFor3DTouchPreviewing(forCourseAtIndex: sourceView.index, withSourceView: sourceView.view)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.popped)
    }

}
