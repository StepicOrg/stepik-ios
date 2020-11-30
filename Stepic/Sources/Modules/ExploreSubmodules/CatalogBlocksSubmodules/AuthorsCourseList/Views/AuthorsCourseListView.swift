import SnapKit
import UIKit

extension AuthorsCourseListView {
    struct Appearance {
        let layoutSectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 20)
        let layoutMinimumInteritemSpacing: CGFloat = 16
        let layoutMinimumLineSpacing: CGFloat = 16
        let layoutNextPageWidth: CGFloat = 12.0
        let layoutDefaultItemHeight: CGFloat = 96
        let layoutIncreasedItemHeight: CGFloat = 114

        let backgroundColor = UIColor.stepikBackground
    }
}

final class AuthorsCourseListView: UIView {
    private static let layoutRowsCount = 3

    let appearance: Appearance

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)

        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast

        collectionView.register(cellClass: AuthorsCourseListCollectionViewCell.self)

        return collectionView
    }()

    private lazy var flowLayout: AuthorsCourseListHorizontalFlowLayout = {
        let layout = AuthorsCourseListHorizontalFlowLayout(
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
            return currentDeviceInfo.isPad ? 2 : 1
        } else {
            return currentDeviceInfo.isPad ? 3 : 2
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

    // MARK: - Public API

    func updateCollectionViewData(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.collectionView.delegate = delegate
        self.collectionView.dataSource = dataSource
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: Loading state

    func showLoading() {
        self.collectionView.skeleton.viewBuilder = { SimpleCourseListCellSkeletonView() }
        self.collectionView.skeleton.show()
    }

    func hideLoading() {
        self.collectionView.skeleton.hide()
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
        let layoutItemWidth = (width / CGFloat(self.columnsCount)).rounded(.down)

        self.flowLayout.columnsCount = self.columnsCount

        return CGSize(width: layoutItemWidth, height: self.layoutItemHeight)
    }
}

extension AuthorsCourseListView: ProgrammaticallyInitializableViewProtocol {
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
