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

    private var rows = [Row]()
    private var quizState: FillBlanksQuizViewModel.State?

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
        self.quizState = viewModel.finalState
        self.rows = viewModel.components.map { component -> Row in
            if component.isBlankFillable {
                if component.options.isEmpty {
                    return .input(text: component.blank ?? "", uniqueIdentifier: component.uniqueIdentifier)
                } else {
                    return .select(
                        text: component.blank ?? "",
                        options: component.options,
                        uniqueIdentifier: component.uniqueIdentifier
                    )
                }
            } else {
                return .text(text: component.text)
            }
        }

        self.collectionView.dataSource = self
        self.collectionView.reloadData()

        DispatchQueue.main.async {
            self.invalidateIntrinsicContentSize()
        }
    }

    func selectOption(_ option: String, forComponentWithUniqueIdentifier uniqueIdentifier: UniqueIdentifierType) {
        let selectedRowIndex = self.rows.firstIndex { row in
            if case .select(_, _, let rowUniqueIdentifier) = row {
                return rowUniqueIdentifier == uniqueIdentifier
            }
            return false
        }

        guard let index = selectedRowIndex else {
            return
        }

        if case .select(_, let options, _) = self.rows[index] {
            self.rows[index] = .select(text: option, options: options, uniqueIdentifier: uniqueIdentifier)
        }

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

    private enum Row {
        case text(text: String)
        case input(text: String, uniqueIdentifier: UniqueIdentifierType)
        case select(text: String, options: [String], uniqueIdentifier: UniqueIdentifierType)
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
        guard let quizState = self.quizState else {
            return true
        }

        if quizState == .correct || quizState == .evaluation {
            return false
        }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.rows.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch self.rows[indexPath.row] {
        case .text(let text):
            let cell: FillBlanksTextCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = text
            return cell
        case .input(let text, let uniqueIdentifier):
            let cell: FillBlanksInputCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = text
            cell.isEnabled = self.isInteractionsEnabled
            cell.onInputChanged = { [weak self] text in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.rows[indexPath.row] = .input(text: text, uniqueIdentifier: uniqueIdentifier)
                strongSelf.invalidateLayout()

                strongSelf.delegate?.fillBlanksQuizView(
                    strongSelf,
                    inputDidChange: text,
                    forComponentWithUniqueIdentifier: uniqueIdentifier
                )
            }
            return cell
        case .select(let text, _, _):
            let cell: FillBlanksSelectCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = text
            cell.isEnabled = self.isInteractionsEnabled
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

        switch self.rows[indexPath.row] {
        case .text(let text):
            let size = FillBlanksTextCollectionViewCell.calculatePreferredContentSize(text: text, maxWidth: maxWidth)
            return size
        case .input(let text, _):
            let size = FillBlanksInputCollectionViewCell.calculatePreferredContentSize(text: text, maxWidth: maxWidth)
            return size
        case .select(let text, _, _):
            let size = FillBlanksSelectCollectionViewCell.calculatePreferredContentSize(text: text, maxWidth: maxWidth)
            return size
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if !self.isInteractionsEnabled {
            return false
        }

        switch self.rows[indexPath.row] {
        case .text:
            return false
        case .input, .select:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.rows[indexPath.row] {
        case .text:
            break
        case .input:
            if let cell = collectionView.cellForItem(at: indexPath) as? FillBlanksInputCollectionViewCell {
                _ = cell.becomeFirstResponder()
            }
        case .select(let text, let options, let uniqueIdentifier):
            self.delegate?.fillBlanksQuizViewDidRequestSelectOption(
                self,
                currentOption: text,
                availableOptions: options,
                forComponentWithUniqueIdentifier: uniqueIdentifier
            )
        }
    }
}
