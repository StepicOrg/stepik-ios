import SnapKit
import UIKit

extension DefaultSimpleCourseListView {
    struct Appearance {
        let layoutSectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let layoutMinimumInteritemSpacing: CGFloat = 16
        let layoutMinimumLineSpacing: CGFloat = 16
        let layoutNextPageWidth: CGFloat = 12.0
        let layoutDefaultItemHeight: CGFloat = 96
        let layoutIncreasedItemHeight: CGFloat = 112
        let layoutSmallScreenItemWidthRatio: CGFloat = 1.5
        let layoutColumnsCountOrientationPortrait = 2
        let layoutColumnsCountOrientationLandscape = 3

        let backgroundColor = UIColor.stepikBackground
    }
}

final class DefaultSimpleCourseListView: UIView, SimpleCourseListViewProtocol {
    private static let layoutRowsCount = 2

    let appearance: Appearance

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)

        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast

        collectionView.register(cellClass: DefaultSimpleCourseListCollectionViewCell.self)

        return collectionView
    }()

    private lazy var flowLayout: CatalogBlockHorizontalCollectionViewFlowLayout = {
        let layout = CatalogBlockHorizontalCollectionViewFlowLayout(
            rowsCount: Self.layoutRowsCount,
            columnsCount: self.columnsCount
        )
        layout.sectionInset = self.appearance.layoutSectionInset
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.minimumLineSpacing = self.appearance.layoutMinimumLineSpacing
        return layout
    }()

    private var columnsCount: Int {
        let currentDeviceInfo = DeviceInfo.current
        let (_, interfaceOrientation) = currentDeviceInfo.orientation

        if interfaceOrientation.isPortrait {
            if currentDeviceInfo.isPad {
                return self.appearance.layoutColumnsCountOrientationPortrait + 1
            } else {
                return currentDeviceInfo.isSmallDiagonal
                    ? self.appearance.layoutColumnsCountOrientationPortrait - 1
                    : self.appearance.layoutColumnsCountOrientationPortrait
            }
        } else {
            if currentDeviceInfo.isPad {
                return self.appearance.layoutColumnsCountOrientationLandscape + 1
            } else {
                return currentDeviceInfo.isSmallDiagonal
                    ? self.appearance.layoutColumnsCountOrientationLandscape - 1
                    : self.appearance.layoutColumnsCountOrientationLandscape
            }
        }
    }

    private var layoutItemHeight: CGFloat {
        DeviceInfo.current.isSmallDiagonal
            ? self.appearance.layoutIncreasedItemHeight
            : self.appearance.layoutDefaultItemHeight
    }

    override var intrinsicContentSize: CGSize {
        self.collectionView.collectionViewLayout.collectionViewContentSize
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateItemSize(self.calculateItemSize())
        self.invalidateIntrinsicContentSize()
    }

    // MARK: - Protocol Conforming

    func updateCollectionViewData(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.collectionView.delegate = delegate
        self.collectionView.dataSource = dataSource
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    func showLoading() {
        self.collectionView.skeleton.viewBuilder = { SimpleCourseListCellSkeletonView() }
        self.collectionView.skeleton.show()
    }

    func hideLoading() {
        self.collectionView.skeleton.hide()
    }

    func invalidateCollectionViewLayout() {
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.invalidateIntrinsicContentSize()
    }

    // MARK: - Private API

    private func updateItemSize(_ itemSize: CGSize) {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              layout.itemSize != itemSize else {
            return
        }

        layout.itemSize = itemSize
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func calculateItemSize() -> CGSize {
        let width = self.bounds.width
            - self.appearance.layoutSectionInset.left
            - self.appearance.layoutMinimumInteritemSpacing * CGFloat(self.columnsCount)
            - self.appearance.layoutNextPageWidth

        let layoutItemWidth = { () -> CGFloat in
            if self.columnsCount == 1 {
                return width / self.appearance.layoutSmallScreenItemWidthRatio
            } else {
                return width / CGFloat(self.columnsCount)
            }
        }()
        .rounded(.down)

        self.flowLayout.columnsCount = self.columnsCount

        return CGSize(
            width: layoutItemWidth,
            height: self.layoutItemHeight
        )
    }
}

extension DefaultSimpleCourseListView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.collectionView)
    }

    func makeConstraints() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
