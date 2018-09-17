//
//  CourseListView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class Stub: UICollectionReusableView, Reusable {
}

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

final class CourseListView: UIView {
    let appearance: Appearance
    let colorMode: CourseListColorMode
    let orientation: Orientation

    private var collectionView: UICollectionView!
    // We should use proxy cause we are using willDisplay method for pagination
    private var storedCollectionViewDelegate: UICollectionViewDelegate
    private weak var delegate: CourseListViewDelegate?

    private lazy var horizontalCourseFlowLayout: UICollectionViewFlowLayout = {
        guard case .horizontal(let rows, let columns) = self.orientation else {
            fatalError()
        }

        let layout = HorizontalCourseListFlowLayout(rowsCount: rows, columnsCount: columns)
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.minimumLineSpacing = self.appearance.layoutMinimumLineSpacing
        return layout
    }()

    private lazy var verticalCourseFlowLayout: UICollectionViewFlowLayout = {
        guard case .vertical(let columns) = self.orientation else {
            fatalError()
        }

        let layout = VerticalCourseListFlowLayout(columnsCount: columns)
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.minimumLineSpacing = self.appearance.layoutMinimumLineSpacing
        return layout
    }()

    var isPaginationViewHidden: Bool = true {
        didSet {
            self.updatePagination()
        }
    }

    override var intrinsicContentSize: CGSize {
        return self.collectionView.collectionViewLayout.collectionViewContentSize
    }

    init(
        frame: CGRect,
        colorMode: CourseListColorMode = .default,
        orientation: Orientation,
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        viewDelegate: CourseListViewDelegate,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        self.orientation = orientation

        self.delegate = viewDelegate
        self.storedCollectionViewDelegate = delegate

        super.init(frame: frame)

        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.getLayoutForOrientation(self.orientation)
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = dataSource

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
        switch self.orientation {
        case .vertical(let columns):
            let width = self.bounds.width
                - self.appearance.layoutMinimumInteritemSpacing * CGFloat(columns + 1)
            return CGSize(width: width / CGFloat(columns), height: self.appearance.layoutItemHeight)
        case .horizontal(_, let columns):
            let width = self.bounds.width
                - self.appearance.layoutMinimumInteritemSpacing * CGFloat(columns + 1)
                - self.appearance.horizontalLayoutNextPageWidth
            return CGSize(width: width / CGFloat(columns), height: self.appearance.layoutItemHeight)
        }
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
        self.storedCollectionViewDelegate = delegate
        self.collectionView.dataSource = dataSource
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func getLayoutForOrientation(
        _ orientation: Orientation
    ) -> UICollectionViewFlowLayout {
        switch self.orientation {
        case .horizontal:
            return self.horizontalCourseFlowLayout
        case .vertical:
            return self.verticalCourseFlowLayout
        }
    }

    private func updatePagination() {
        let collectionViewLayout = self.collectionView.collectionViewLayout
        guard let layout = collectionViewLayout as? VerticalCourseListFlowLayout else {
            return
        }

        collectionView.performBatchUpdates({ [weak self] in
            guard let strongSelf = self else {
                return
            }
            layout.isPaginationHidden = strongSelf.isPaginationViewHidden
        })
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

    enum Orientation {
        case horizontal(rowsCount: Int, columnsCount: Int)
        case vertical(columnsCount: Int)
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
        self.collectionView.register(viewClass: Stub.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)

        self.collectionView.isPagingEnabled = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = .zero
        self.collectionView.backgroundColor = .clear
    }
}

extension CourseListView: UICollectionViewDelegate {
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

        // Pagination working only when collection has one section and VerticalCourseListFlowLayout
        guard indexPath.section == 0,
              collectionView.collectionViewLayout is VerticalCourseListFlowLayout else {
            return
        }

        // Handle pagination
        let itemsCount = collectionView.numberOfItems(inSection: indexPath.section)
        if indexPath.row + 1 == itemsCount {
            self.delegate?.courseListViewDidPaginationRequesting(self)
        }
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
