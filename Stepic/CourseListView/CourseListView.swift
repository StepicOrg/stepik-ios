//
//  CourseListView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension CourseListView {
    struct Appearance {
        let layoutMinimumLineSpacing: CGFloat = 16.0
        let layoutMinimumInteritemSpacing: CGFloat = 16.0
        let layoutItemHeight: CGFloat = 140.0

        let lightModeBackgroundColor = UIColor.white
        let darkModeBackgroundColor = UIColor(hex: 0x535366)

        let horizontalLayoutNextPageWidth: CGFloat = 16.0
    }
}

class CourseListView: UIView {
    let appearance: Appearance
    let colorMode: CourseListColorMode

    fileprivate var collectionView: UICollectionView!
    fileprivate weak var delegate: CourseListViewDelegate?

    var flowLayout: UICollectionViewFlowLayout {
        fatalError("Use subclass of CourseListView with concrete layout")
    }

    override var intrinsicContentSize: CGSize {
        return self.collectionView.collectionViewLayout.collectionViewContentSize
    }

    init(
        frame: CGRect,
        colorMode: CourseListColorMode = .default,
        viewDelegate: CourseListViewDelegate,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode

        self.delegate = viewDelegate

        super.init(frame: frame)

        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.flowLayout
        )

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateItemSize(self.calculateItemSize())
        self.invalidateIntrinsicContentSize()
    }

    func calculateItemSize() -> CGSize {
        fatalError("Use subclass of CourseListView with concrete layout")
    }

    func updateItemSize(_ itemSize: CGSize) {
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
           layout.itemSize != itemSize {
            layout.itemSize = itemSize
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    func updateCollectionViewData(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        // REVIEW: fix dataSource
        self.collectionView.dataSource = dataSource
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateViewColor() {
        self.backgroundColor = self.getBackgroundColor(for: self.colorMode)
    }

    // MARK: - ColorMode

    private func getBackgroundColor(for colorMode: CourseListColorMode) -> UIColor {
        switch colorMode {
        case .light:
            return self.appearance.lightModeBackgroundColor
        case .dark:
            return self.appearance.darkModeBackgroundColor
        }
    }
}

extension CourseListView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateViewColor()
        self.setupCollectionView()
    }

    func addSubviews() {
        self.addSubview(self.collectionView)
    }

    func makeConstraints() {
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false

        switch self.colorMode {
        case .light:
            self.collectionView.register(
                LightCourseListCollectionViewCell.self,
                forCellWithReuseIdentifier: LightCourseListCollectionViewCell.defaultReuseIdentifier
            )
        case .dark:
            self.collectionView.register(
                DarkCourseListCollectionViewCell.self,
                forCellWithReuseIdentifier: DarkCourseListCollectionViewCell.defaultReuseIdentifier
            )
        default:
            fatalError("Color mode is not supported")
        }

        self.collectionView.register(
            viewClass: CollectionViewFooterReusableView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
        )
        self.collectionView.register(
            viewClass: CollectionViewHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
        )

        self.collectionView.isPagingEnabled = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = .zero
        self.collectionView.backgroundColor = .clear
    }
}

// Cause we can't init cell with custom initializer let's use custom classes
private class LightCourseListCollectionViewCell: CourseListCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame, colorMode: .light)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static var defaultReuseIdentifier: String {
        return String(describing: CourseListCollectionViewCell.self)
    }
}

private class DarkCourseListCollectionViewCell: CourseListCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame, colorMode: .dark)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static var defaultReuseIdentifier: String {
        return String(describing: CourseListCollectionViewCell.self)
    }
}

// Subclasses for two orientations

final class VerticalCourseListView: CourseListView,
                                    UICollectionViewDelegate,
                                    UICollectionViewDataSource {
    private let columnsCount: Int
    // We should use proxy cause we are using willDisplay method in delegate for pagination
    // and some methods to show footer/header in data source
    private var storedCollectionViewDelegate: UICollectionViewDelegate
    private var storedCollectionViewDataSource: UICollectionViewDataSource

    private lazy var verticalCourseFlowLayout: VerticalCourseListFlowLayout = {
        let layout = VerticalCourseListFlowLayout(columnsCount: self.columnsCount)
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.minimumLineSpacing = self.appearance.layoutMinimumLineSpacing
        return layout
    }()

    override var flowLayout: UICollectionViewFlowLayout {
        return self.verticalCourseFlowLayout
    }

    var isPaginationViewHidden: Bool = true {
        didSet {
            self.updatePagination()
        }
    }

    init(
        frame: CGRect,
        columnsCount: Int,
        colorMode: CourseListColorMode,
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        viewDelegate: CourseListViewDelegate,
        appearance: Appearance = CourseListView.Appearance()
    ) {
        self.columnsCount = columnsCount
        self.storedCollectionViewDelegate = delegate
        self.storedCollectionViewDataSource = dataSource
        super.init(
            frame: frame,
            colorMode: colorMode,
            viewDelegate: viewDelegate,
            appearance: appearance
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateCollectionViewData(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        self.storedCollectionViewDelegate = delegate
        self.storedCollectionViewDataSource = dataSource
        super.updateCollectionViewData(delegate: delegate, dataSource: dataSource)
    }

    override func calculateItemSize() -> CGSize {
        let width = self.bounds.width
            - self.appearance.layoutMinimumInteritemSpacing * CGFloat(self.columnsCount + 1)
        return CGSize(
            width: width / CGFloat(self.columnsCount),
            height: self.appearance.layoutItemHeight
        )
    }

    private func updatePagination() {
        self.collectionView.performBatchUpdates({ [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.verticalCourseFlowLayout.isPaginationHidden = strongSelf
                .isPaginationViewHidden
        })
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.storedCollectionViewDelegate.collectionView?(
            collectionView,
            didSelectItemAt: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        self.storedCollectionViewDelegate.collectionView?(
            collectionView,
            willDisplay: cell,
            forItemAt: indexPath
        )

        // Pagination working only when collection has one section
        guard indexPath.section == 0 else {
            return
        }

        // Handle pagination
        let itemsCount = collectionView.numberOfItems(inSection: indexPath.section)
        if indexPath.row + 1 == itemsCount {
            self.delegate?.courseListViewDidPaginationRequesting(self)
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.storedCollectionViewDataSource.collectionView(
            collectionView,
            numberOfItemsInSection: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return self.storedCollectionViewDataSource.collectionView(
            collectionView,
            cellForItemAt: indexPath
        )
    }

    // Crash if present here
//    func collectionView(
//        _ collectionView: UICollectionView,
//        viewForSupplementaryElementOfKind kind: String,
//        at indexPath: IndexPath
//    ) -> UICollectionReusableView {
//        if kind == UICollectionElementKindSectionFooter {
//            let view: CollectionViewFooterReusableView = collectionView
//                .dequeueReusableSupplementaryView(
//                    ofKind: UICollectionElementKindSectionFooter,
//                    for: indexPath
//                )
//            view.backgroundColor = .red
//            return view
//        } else if kind == UICollectionElementKindSectionHeader {
//            let view: CollectionViewHeaderReusableView = collectionView
//                .dequeueReusableSupplementaryView(
//                    ofKind: UICollectionElementKindSectionHeader,
//                    for: indexPath
//                )
//            view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
//            return view
//        }
//
//        fatalError("Kind is not supported")
//    }
}

final class HorizontalCourseListView: CourseListView {
    private let columnsCount: Int
    private let rowsCount: Int

    private lazy var horizontalCourseFlowLayout: HorizontalCourseListFlowLayout = {
        let layout = HorizontalCourseListFlowLayout(
            rowsCount: self.rowsCount,
            columnsCount: self.columnsCount
        )
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.minimumLineSpacing = self.appearance.layoutMinimumLineSpacing
        return layout
    }()

    override var flowLayout: UICollectionViewFlowLayout {
        return self.horizontalCourseFlowLayout
    }

    init(
        frame: CGRect,
        columnsCount: Int,
        rowsCount: Int,
        colorMode: CourseListColorMode,
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        viewDelegate: CourseListViewDelegate,
        appearance: Appearance = CourseListView.Appearance()
    ) {
        self.columnsCount = columnsCount
        self.rowsCount = rowsCount
        super.init(
            frame: frame,
            colorMode: colorMode,
            viewDelegate: viewDelegate,
            appearance: appearance
        )
        self.collectionView.delegate = delegate
        self.collectionView.dataSource = dataSource
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func calculateItemSize() -> CGSize {
        let width = self.bounds.width
            - self.appearance.layoutMinimumInteritemSpacing * CGFloat(self.columnsCount + 1)
            - self.appearance.horizontalLayoutNextPageWidth
        return CGSize(
            width: width / CGFloat(self.columnsCount),
            height: self.appearance.layoutItemHeight
        )
    }
}

// Wrappers for reusable views

class CollectionViewHeaderReusableView: UICollectionReusableView, Reusable {
}

class CollectionViewFooterReusableView: UICollectionReusableView, Reusable {
}
