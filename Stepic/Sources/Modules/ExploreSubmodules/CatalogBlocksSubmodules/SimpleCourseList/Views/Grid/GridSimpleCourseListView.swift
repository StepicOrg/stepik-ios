import SnapKit
import UIKit

extension GridSimpleCourseListView {
    struct Appearance {
        static let layoutHeaderHeight: CGFloat = 150

        let layoutMinimumLineSpacing: CGFloat = 16
        let layoutMinimumInteritemSpacing: CGFloat = 16
        let layoutEstimatedItemSize = CGSize(width: 107, height: 56)
        let layoutSectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let backgroundColor = UIColor.stepikBackground
    }
}

final class GridSimpleCourseListView: UIView, SimpleCourseListViewProtocol {
    let appearance: Appearance

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)

        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false

        collectionView.register(
            viewClass: GridSimpleCourseListCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )

        return collectionView
    }()

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = self.appearance.layoutMinimumLineSpacing
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.estimatedItemSize = self.appearance.layoutEstimatedItemSize
        layout.sectionInset = self.appearance.layoutSectionInset
        return layout
    }()

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
}

extension GridSimpleCourseListView: ProgrammaticallyInitializableViewProtocol {
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
