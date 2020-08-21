import SnapKit
import UIKit

extension FillBlanksQuizView {
    struct Appearance {
        let titleColor = UIColor.stepikPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        let titleLabelInsets = LayoutInsets(left: 16, right: 16)

        let collectionViewMinHeight: CGFloat = 44
        let collectionViewMinLineSpacing: CGFloat = 4
        let collectionViewMinInteritemSpacing: CGFloat = 8
        let collectionViewSectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)

        let backgroundColor = UIColor.stepikBackground
    }
}

final class FillBlanksQuizView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("FillBlanksQuizTitle", comment: "")
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 1
        label.backgroundColor = self.appearance.backgroundColor
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.makeCollectionViewLayout()
        )
        collectionView.delegate = self
        collectionView.backgroundColor = self.appearance.backgroundColor
        collectionView.isScrollEnabled = false
        collectionView.register(cellClass: FillBlanksInputCollectionViewCell.self)
        collectionView.register(cellClass: FillBlanksSelectCollectionViewCell.self)
        collectionView.register(cellClass: FillBlanksTextCollectionViewCell.self)
        return collectionView
    }()

    private var viewModel: FillBlanksQuizViewModel?

    override var intrinsicContentSize: CGSize {
        let collectionViewHeight = max(
            self.appearance.collectionViewMinHeight,
            self.collectionView.collectionViewLayout.collectionViewContentSize.height
        )
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.titleLabel.intrinsicContentSize.height + collectionViewHeight
        )
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

    func configure(viewModel: FillBlanksQuizViewModel) {
        self.viewModel = viewModel

        self.collectionView.dataSource = self
        self.collectionView.reloadData()

        DispatchQueue.main.async {
            self.invalidateIntrinsicContentSize()
        }
    }

    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = self.appearance.collectionViewMinLineSpacing
        flowLayout.minimumInteritemSpacing = self.appearance.collectionViewMinInteritemSpacing
        flowLayout.sectionInset = self.appearance.collectionViewSectionInset
        return flowLayout
    }
}

extension FillBlanksQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.collectionView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
        }

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }

        let separatorView = UIView()
        separatorView.backgroundColor = .stepikOpaqueSeparator
        self.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}

extension FillBlanksQuizView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel?.components.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let component = self.viewModel?.components[safe: indexPath.row] else {
            return UICollectionViewCell()
        }

        if component.isBlankFillable {
            if component.options.isEmpty {
                let cell: FillBlanksInputCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.text = component.blank
                cell.onInputChanged = { [weak self] text in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.viewModel?.components[indexPath.row].blank = text

                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            strongSelf.collectionView.collectionViewLayout.invalidateLayout()
                            strongSelf.layoutIfNeeded()
                            strongSelf.invalidateIntrinsicContentSize()
                        }
                    }
                }
                return cell
            } else {
                let cell: FillBlanksSelectCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.text = component.blank
                return cell
            }
        } else {
            let cell: FillBlanksTextCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = component.text
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let component = self.viewModel?.components[safe: indexPath.row] else {
            return .zero
        }

        let maxWidth = collectionView.bounds.width
            - self.appearance.collectionViewSectionInset.left
            - self.appearance.collectionViewSectionInset.right

        if component.isBlankFillable {
            if component.options.isEmpty {
                let size = FillBlanksInputCollectionViewCell.calculatePreferredContentSize(
                    string: component.blank ?? "",
                    maxWidth: maxWidth
                )
                print("FillBlanksInputCollectionViewCell size = \(size)")
                return size
            } else {
                let size = FillBlanksSelectCollectionViewCell.calculatePreferredContentSize(
                    string: component.blank ?? "",
                    maxWidth: maxWidth
                )
                print("FillBlanksSelectCollectionViewCell size = \(size)")
                return size
            }
        } else {
            let size = FillBlanksTextCollectionViewCell.calculatePreferredContentSize(
                text: component.text,
                maxWidth: maxWidth
            )
            print("FillBlanksTextCollectionViewCell size = \(size)")
            return size
        }
    }
}
