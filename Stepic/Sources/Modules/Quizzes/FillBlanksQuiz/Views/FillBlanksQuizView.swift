import SnapKit
import UIKit

protocol FillBlanksQuizViewDelegate: AnyObject {
    func fillBlanksQuizView(
        _ view: FillBlanksQuizView,
        inputDidChange text: String,
        forComponentWithUniqueIdentifier uniqueIdentifier: UniqueIdentifierType
    )
    func fillBlanksQuizViewDidRequestSelectOption(
        _ view: FillBlanksQuizView,
        currentOption: String,
        availableOptions options: [String],
        forComponentWithUniqueIdentifier uniqueIdentifier: UniqueIdentifierType
    )
}

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
    weak var delegate: FillBlanksQuizViewDelegate?

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
        let collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumLineSpacing = self.appearance.collectionViewMinLineSpacing
        collectionViewLayout.minimumInteritemSpacing = self.appearance.collectionViewMinInteritemSpacing
        collectionViewLayout.sectionInset = self.appearance.collectionViewSectionInset

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
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

    func selectOption(_ option: String, forComponentWithUniqueIdentifier uniqueIdentifier: UniqueIdentifierType) {
        guard let index = self.viewModel?.components.firstIndex(
            where: { $0.uniqueIdentifier == uniqueIdentifier }
        ) else {
            return
        }

        self.viewModel?.components[index].blank = option

        let indexPath = IndexPath(item: index, section: 0)
        if let cell = self.collectionView.cellForItem(at: indexPath) as? FillBlanksSelectCollectionViewCell {
            cell.text = option
        }

        self.invalidateLayout()
    }

    // MARK: Private API

    private func invalidateLayout() {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.layoutIfNeeded()
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    private func componentForItemAt(_ indexPath: IndexPath) -> FillBlanksQuiz.Component {
        self.viewModel.require().components[indexPath.row]
    }

    private func rowTypeForItemAt(_ indexPath: IndexPath) -> Row {
        let component = self.viewModel.require().components[indexPath.row]
        if component.isBlankFillable {
            return component.options.isEmpty ? .input : .select
        } else {
            return .text
        }
    }

    private enum Row {
        case text
        case input
        case select
    }
}

// MARK: - FillBlanksQuizView: ProgrammaticallyInitializableViewProtocol -

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
    }
}

// MARK: - FillBlanksQuizView: UICollectionViewDataSource -

extension FillBlanksQuizView: UICollectionViewDataSource {
    private var isInteractionsEnabled: Bool {
        guard let finalState = self.viewModel?.finalState else {
            return true
        }

        if finalState == .correct || finalState == .evaluation {
            return false
        }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel?.components.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let component = self.componentForItemAt(indexPath)

        let cellState: FillBlanksQuizInputContainerView.State = {
            guard let isCorrect = component.isCorrect else {
                return .default
            }

            return isCorrect ? .correct : .wrong
        }()

        switch self.rowTypeForItemAt(indexPath) {
        case .text:
            let cell: FillBlanksTextCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = component.text
            return cell
        case .input:
            let cell: FillBlanksInputCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = component.blank ?? ""
            cell.isEnabled = self.isInteractionsEnabled
            cell.state = cellState
            cell.onInputChanged = { [weak self] text in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.viewModel?.components[indexPath.row].blank = text
                strongSelf.invalidateLayout()

                strongSelf.delegate?.fillBlanksQuizView(
                    strongSelf,
                    inputDidChange: text,
                    forComponentWithUniqueIdentifier: component.uniqueIdentifier
                )
            }
            return cell
        case .select:
            let cell: FillBlanksSelectCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = component.blank ?? ""
            cell.isEnabled = self.isInteractionsEnabled
            cell.state = cellState
            return cell
        }
    }
}

// MARK: - FillBlanksQuizView: UICollectionViewDelegateFlowLayout -

extension FillBlanksQuizView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let maxWidth = collectionView.bounds.width
            - self.appearance.collectionViewSectionInset.left
            - self.appearance.collectionViewSectionInset.right

        let component = self.componentForItemAt(indexPath)

        switch self.rowTypeForItemAt(indexPath) {
        case .text:
            return FillBlanksTextCollectionViewCell.calculatePreferredContentSize(
                text: component.text,
                maxWidth: maxWidth
            )
        case .input:
            return FillBlanksInputCollectionViewCell.calculatePreferredContentSize(
                text: component.blank ?? "",
                maxWidth: maxWidth
            )
        case .select:
            return FillBlanksSelectCollectionViewCell.calculatePreferredContentSize(
                text: component.blank ?? "",
                maxWidth: maxWidth
            )
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if !self.isInteractionsEnabled {
            return false
        }

        switch self.rowTypeForItemAt(indexPath) {
        case .text:
            return false
        case .input, .select:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.rowTypeForItemAt(indexPath) {
        case .text:
            break
        case .input:
            if let cell = collectionView.cellForItem(at: indexPath) as? FillBlanksInputCollectionViewCell {
                _ = cell.becomeFirstResponder()
            }
        case .select:
            let component = self.componentForItemAt(indexPath)
            self.delegate?.fillBlanksQuizViewDidRequestSelectOption(
                self,
                currentOption: component.blank ?? "",
                availableOptions: component.options,
                forComponentWithUniqueIdentifier: component.uniqueIdentifier
            )
        }
    }
}
