import SnapKit
import UIKit

extension StepikAcademyCourseListView {
    struct Appearance {
        let layoutSectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let layoutMinimumInteritemSpacing: CGFloat = 12
        let layoutMinimumLineSpacing: CGFloat = 12
        let layoutNextPageWidth: CGFloat = 12

        let layoutDefaultItemHeight: CGFloat = 114
        let layoutSmallDiagonalItemHeight: CGFloat = 136

        let layoutColumnsCountOrientationPortrait = 2
        let layoutColumnsCountOrientationLandscape = 3

        let backgroundColor = UIColor.stepikBackground
    }
}

final class StepikAcademyCourseListView: UIView {
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

        collectionView.register(cellClass: StepikAcademyCourseListCollectionViewCell.self)

        return collectionView
    }()

    private lazy var flowLayout: CatalogBlockHorizontalCollectionViewFlowLayout = {
        var appearance = CatalogBlockHorizontalCollectionViewFlowLayout.Appearance()
        appearance.insets.top = StepikAcademyCourseListCollectionViewCell.Appearance.shadowRadius
        appearance.insets.bottom = StepikAcademyCourseListCollectionViewCell.Appearance.shadowRadius

        let layout = CatalogBlockHorizontalCollectionViewFlowLayout(
            rowsCount: Self.layoutRowsCount,
            columnsCount: self.columnsCount,
            appearance: appearance
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
            return currentDeviceInfo.isPad
                ? (self.appearance.layoutColumnsCountOrientationPortrait + 1)
                : self.appearance.layoutColumnsCountOrientationPortrait
        } else {
            return currentDeviceInfo.isPad
                ? (self.appearance.layoutColumnsCountOrientationLandscape + 1)
                : self.appearance.layoutColumnsCountOrientationLandscape
        }
    }

    private var layoutItemHeight: CGFloat {
        DeviceInfo.current.isSmallDiagonal
            ? self.appearance.layoutSmallDiagonalItemHeight
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

        let itemSize = self.calculateItemSize()
        self.updateItemSize(itemSize)

        self.invalidateIntrinsicContentSize()
    }

    // MARK: Public API

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

    // MARK: Private API

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
        let layoutItemWidth = (width / CGFloat(self.columnsCount)).rounded(.down)

        self.flowLayout.columnsCount = self.columnsCount

        return CGSize(width: layoutItemWidth, height: self.layoutItemHeight)
    }
}

extension StepikAcademyCourseListView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.collectionView)
    }

    func makeConstraints() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
