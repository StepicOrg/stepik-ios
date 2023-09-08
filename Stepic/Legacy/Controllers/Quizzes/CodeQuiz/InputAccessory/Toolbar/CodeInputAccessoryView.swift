import SnapKit
import UIKit

extension CodeInputAccessoryView {
    struct Appearance {
        let hideKeyboardImageViewInsets = LayoutInsets(top: 4, left: 4, bottom: 4, right: 8)

        let collectionViewInsets = LayoutInsets(top: 4, left: 8, bottom: 4, right: 0)
        let collectionViewLayoutSectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        let collectionViewLayoutMinimumInteritemSpacing: CGFloat = 4

        let backgroundColor = UIColor.stepikGroupedBackground
    }
}

final class CodeInputAccessoryView: UIView {
    let appearance: Appearance

    private let buttons: [CodeInputAccessoryButtonData]

    private let size: CodeInputAccessorySize

    private let hideKeyboardAction: (() -> Void)?

    private lazy var hideKeyboardImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Hide keyboard filled Gray"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapHideKeyboardImageView(recognizer:))
        )
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = self.appearance.collectionViewLayoutSectionInset
        collectionViewLayout.minimumInteritemSpacing = self.appearance.collectionViewLayoutMinimumInteritemSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellClass: CodeInputAccessoryCollectionViewCell.self)

        return collectionView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        buttons: [CodeInputAccessoryButtonData] = [],
        size: CodeInputAccessorySize = .small,
        hideKeyboardAction: @escaping () -> Void
    ) {
        self.appearance = appearance
        self.buttons = buttons
        self.size = size
        self.hideKeyboardAction = hideKeyboardAction
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func didTapHideKeyboardImageView(recognizer: UIGestureRecognizer) {
        self.hideKeyboardAction?()
    }
}

// MARK: - CodeInputAccessoryView: ProgrammaticallyInitializableViewProtocol -

extension CodeInputAccessoryView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.hideKeyboardImageView)
        self.addSubview(self.collectionView)
    }

    func makeConstraints() {
        self.snp.makeConstraints { $0.height.equalTo(self.size.realSizes.viewHeight) }

        self.hideKeyboardImageView.translatesAutoresizingMaskIntoConstraints = false
        self.hideKeyboardImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(self.appearance.hideKeyboardImageViewInsets.edgeInsets)
            make.width.equalTo(self.hideKeyboardImageView.snp.height)
        }

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(self.appearance.collectionViewInsets.edgeInsets)
            make.leading
                .equalTo(self.hideKeyboardImageView.snp.trailing)
                .offset(self.appearance.collectionViewInsets.left)
        }
    }
}

// MARK: - CodeInputAccessoryView: UICollectionViewDelegateFlowLayout -

extension CodeInputAccessoryView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = CodeInputAccessoryCollectionViewCell.calculateWidth(for: buttons[indexPath.item].title, size: size)
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        buttons[indexPath.item].action()
    }
}

// MARK: - CodeInputAccessoryView: UICollectionViewDataSource -

extension CodeInputAccessoryView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        buttons.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CodeInputAccessoryCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(text: buttons[indexPath.item].title, size: size)
        return cell
    }
}
