//
//  CourseListViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListViewControllerDelegate: class {
    func setupContentView()
    func setupRefresh()
    func reloadData()
    func setUserInteraction(enabled: Bool)

    func updatePagination()

    func indexPathsForVisibleCells() -> [IndexPath]
    func indexPathForIndex(index: Int) -> IndexPath
    func addElements(atIndexPaths: [IndexPath])
    func updateCell(atIndexPath: IndexPath)
    func updateCells(deletingIndexPaths: [IndexPath], insertingIndexPaths: [IndexPath])

    func getSourceCellFor3dTouch(location: CGPoint) -> (view: UIView, index: Int)?
}

class CourseListViewController: UIViewController, CourseListView {
    var presenter: CourseListPresenter?
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

        guard let visibleIndexPathsArray = delegate?.indexPathsForVisibleCells() else {
            return
        }

        let updatingIndexes: [Int] = getChangedIndexes(changedCourses: updatedCourses, courses: courses)
        let visibleIndexPaths = Set<IndexPath>(visibleIndexPathsArray)
        let updatingIndexPaths = Set<IndexPath>(updatingIndexes.flatMap({ delegate?.indexPathForIndex(index: $0) }))
        let visibleUpdating = Array(updatingIndexPaths.intersection(visibleIndexPaths))
        for indexPathToUpdate in visibleUpdating {
            delegate?.updateCell(atIndexPath: indexPathToUpdate)
        }
    }

    private func setPlaceholder(visible: Bool) {
        emptyPlaceholder.isHidden = !visible
        delegate?.setUserInteraction(enabled: !visible)
    }

    func setState(state: CourseListState) {
//        let prevState: CourseListState = self.state
        self.state = state
        switch state {
        case .displaying:
            setPlaceholder(visible: false)
            break
        case .displayingWithError:
            setPlaceholder(visible: false)
            // Show some error indicator here
            break
        case .displayingWithRefreshing:
            setPlaceholder(visible: false)
            // Show some activity indicator here
            break
        case .empty:
            // Show empty placeholder
            placeholderText = "Empty"
            setPlaceholder(visible: true)
            break
        case .emptyError:
            placeholderText = "Error"
            setPlaceholder(visible: true)
            // Show error placeholder
            break
        case .emptyRefreshing:
            delegate?.reloadData()
            setPlaceholder(visible: false)
            delegate?.setUserInteraction(enabled: false)
            break
        case .emptyAnonymous:
            placeholderText = "Anonymous"
            setPlaceholder(visible: true)
            break
        }

//        delegate?.updateState(from: prevState)
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

    lazy var placeholderLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = NSTextAlignment.center
        return l
    }()

    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }

    lazy var emptyPlaceholder: UIView = {
        let placeholder = UIView()
        self.view.addSubview(placeholder)
        placeholder.align(toView: self.view)
        placeholder.isHidden = true
        placeholder.addSubview(self.placeholderLabel)
        self.placeholderLabel.align(toView: placeholder)
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
