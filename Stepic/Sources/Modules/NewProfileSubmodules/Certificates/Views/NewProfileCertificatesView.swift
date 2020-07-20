import SnapKit
import UIKit

extension NewProfileCertificatesView {
    struct Appearance {
        let layoutMinimumInteritemSpacing: CGFloat = 16
        let layoutItemHeight: CGFloat = 104
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
        layout.minimumInteritemSpacing = self.appearance.layoutMinimumInteritemSpacing
        layout.minimumLineSpacing = 0
        return layout
    }()

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
        self.collectionView.skeleton.viewBuilder = { CourseWidgetSkeletonView() }
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
        let layoutItemWidth = self.calculateLayoutItemWidth(
            minimumColumnWidth: self.appearance.layoutMinimumItemWidth,
            columnHorizontalInsets: self.appearance.layoutMinimumInteritemSpacing,
            containerHorizontalInsets: self.appearance.layoutNextPageWidth
        )
        return CGSize(width: layoutItemWidth, height: self.appearance.layoutItemHeight)
    }

    fileprivate func calculateLayoutItemWidth(
        minimumColumnWidth: CGFloat,
        columnHorizontalInsets: CGFloat,
        containerHorizontalInsets: CGFloat
    ) -> CGFloat {
        func calculateColumnWidth(columnsCount: Int) -> CGFloat {
            let totalWidth = self.bounds.width
                - columnHorizontalInsets * CGFloat(columnsCount)
                - containerHorizontalInsets
            return (totalWidth / CGFloat(columnsCount)).rounded(.down)
        }

        var columnsCount = 0
        var columnWidth = CGFloat.greatestFiniteMagnitude

        while columnWidth >= minimumColumnWidth {
            columnsCount += 1
            columnWidth = calculateColumnWidth(columnsCount: columnsCount)
        }

        if columnWidth < minimumColumnWidth {
            columnsCount = max(1, columnsCount - 1)
            columnWidth = calculateColumnWidth(columnsCount: columnsCount)
        }

        columnWidth = max(minimumColumnWidth, columnWidth)

        return columnWidth
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
