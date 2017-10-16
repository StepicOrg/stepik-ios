//
//  CourseListHorizontalViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 16.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class CourseListHorizontalViewController: CourseListViewController {
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        presenter?.refresh()
    }

    let horizontalSpacing: CGFloat = 8
    let verticalSpacing: CGFloat = 8
    let nextWidgetVisibleWidth: CGFloat = 16
    var widgetWidth: CGFloat {
        return view.frame.width - (horizontalSpacing * 3 + nextWidgetVisibleWidth)
    }

    var currentColumn: Int = 0
}

extension CourseListHorizontalViewController: CourseListViewControllerDelegate {
    func setupContentView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: widgetWidth, height: 100)
        layout.minimumInteritemSpacing = verticalSpacing
        layout.minimumLineSpacing = horizontalSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: max(16, horizontalSpacing + nextWidgetVisibleWidth))
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.align(toView: self.view)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CourseWidgetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseWidgetCollectionViewCell")
    }

    func setupRefresh() {
        //TODO: Add refresh in collection view when needed
    }

    func reloadData() {
        collectionView.reloadData()
    }

    func updatePagination() {
        //TODO: Add this when pagination is supported by this layout
    }

    func updateRefreshing() {
        if isRefreshing {
            if courses.isEmpty {
                collectionView.reloadData()
                collectionView.isUserInteractionEnabled = false
            }
        } else {
            collectionView.isUserInteractionEnabled = true
            if courses.isEmpty {
                collectionView.reloadData()
            }
        }

    }

    func indexPathsForVisibleCells() -> [IndexPath] {
        return collectionView.indexPathsForVisibleItems
    }

    func indexPathForIndex(index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }

    func addElements(atIndexPaths indexPaths: [IndexPath]) {
        collectionView.insertItems(at: indexPaths)
    }

    func updateCell(atIndexPath indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CourseWidgetCollectionViewCell {
            cell.widgetView.progress = courses[indexPath.item].progress
            cell.widgetView.rating = courses[indexPath.item].rating
        }
    }

    func updateCells(deletingIndexPaths: [IndexPath], insertingIndexPaths: [IndexPath]) {
        collectionView.performBatchUpdates({
            [weak self] in
            self?.collectionView.deleteItems(at: deletingIndexPaths)
            self?.collectionView.insertItems(at: insertingIndexPaths)
        }, completion: nil)
    }

    func getSourceCellFor3dTouch(location: CGPoint) -> (view: UIView, index: Int)? {
        let locationInCollectionView = collectionView.convert(location, from: self.view)

        guard let indexPath = collectionView.indexPathForItem(at: locationInCollectionView) else {
            return nil
        }

        guard indexPath.item < courses.count else {
            return nil
        }

        guard let cell = collectionView.cellForItem(at: indexPath) as? CourseWidgetCollectionViewCell else {
            return nil
        }

        return (view: cell, index: indexPath.item)
    }
}

extension CourseListHorizontalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectCourse(at: indexPath.item)
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    private func getNearestColumnToPoint(point: CGPoint) -> Int {
        return Int(round(point.x / (widgetWidth + horizontalSpacing)))
    }

    private func getHorizontalOffsetForColumn(id: Int) -> CGFloat {
        return CGFloat(id) * (widgetWidth + horizontalSpacing)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee
//        let currentColumn = getNearestColumnToPoint(point: scrollView.contentOffset)
        var targetColumn = getNearestColumnToPoint(point: targetOffset)
        if targetColumn > currentColumn {
            targetColumn = currentColumn + 1
        }
        if targetColumn < currentColumn {
            targetColumn = currentColumn - 1
        }
        currentColumn = targetColumn
        let horizontalOffset = getHorizontalOffsetForColumn(id: targetColumn)
        targetContentOffset.pointee = scrollView.contentOffset
        scrollView.setContentOffset(CGPoint(x: horizontalOffset, y: 0), animated: true)
    }
}

extension CourseListHorizontalViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldShowLoadingWidgets {
            return Int(collectionView.frame.height) / 100
        } else {
            return courses.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < courses.count || shouldShowLoadingWidgets else {
            return UICollectionViewCell()
        }

        if indexPath.item == courses.count - 1 && paginationStatus == .loading {
            presenter?.loadNextPage()
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseWidgetCollectionViewCell", for: indexPath) as? CourseWidgetCollectionViewCell else {
            return UICollectionViewCell()
        }

        if shouldShowLoadingWidgets {
            cell.isLoading = true
        } else {
            cell.setup(courseViewData: courses[indexPath.row])
        }
        return cell
    }
}
