import SnapKit
import UIKit

extension NewProfileCertificatesView {
    struct Appearance {
        let layoutSectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let layoutMinimumInteritemSpacing: CGFloat = 16
        let layoutMinimumLineSpacing: CGFloat = 0
        let layoutItemHeight: CGFloat = 116
        let layoutMinimumItemWidth: CGFloat = 144
        let layoutNextPageWidth: CGFloat = 12.0

        let backgroundColor = UIColor.stepikSecondaryGroupedBackground
    }
}

final class NewProfileCertificatesView: UIView {
    let appearance: Appearance

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)

    private lazy var flowLayout: NewProfileCertificatesHorizontalFlowLayout = {
        let layout = NewProfileCertificatesHorizontalFlowLayout()
        layout.sectionInset = self.appearance.layoutSectionInset
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.minimumLineSpacing = self.appearance.layoutMinimumLineSpacing
        return layout
    }()

    private var columnsCount: Int {
        let currentDeviceInfo = DeviceInfo.current
        let (_, interfaceOrientation) = currentDeviceInfo.orientation

        if interfaceOrientation.isPortrait {
            return currentDeviceInfo.isPad ? 3 : 2
        } else {
            return currentDeviceInfo.isPad ? 4 : 3
        }
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
        self.collectionView.skeleton.viewBuilder = { NewProfileCertificatesCellSkeletonView() }
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
            - self.appearance.layoutMinimumInteritemSpacing * CGFloat(self.columnsCount)
            - self.appearance.layoutNextPageWidth
        let layoutItemWidth = (width / CGFloat(self.columnsCount)).rounded(.down)
        return CGSize(width: layoutItemWidth, height: self.appearance.layoutItemHeight)
    }
}

extension NewProfileCertificatesView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.setupCollectionView()
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

    private func setupCollectionView() {
        self.collectionView.register(
            NewProfileCertificatesCertificateCollectionViewCell.self,
            forCellWithReuseIdentifier: NewProfileCertificatesCertificateCollectionViewCell.defaultReuseIdentifier
        )

        self.collectionView.isPagingEnabled = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = .zero
        self.collectionView.backgroundColor = .clear
        self.collectionView.decelerationRate = .fast
    }
}
