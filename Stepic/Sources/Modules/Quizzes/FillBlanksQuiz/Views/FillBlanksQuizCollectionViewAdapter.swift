import UIKit

protocol FillBlanksQuizCollectionViewAdapterDelegate: AnyObject {
    func fillBlanksQuizCollectionViewAdapter(
        _ adapter: FillBlanksQuizCollectionViewAdapter,
        inputDidChange inputText: String,
        forComponent component: FillBlanksQuiz.Component
    )
    func fillBlanksQuizCollectionViewAdapter(
        _ adapter: FillBlanksQuizCollectionViewAdapter,
        didSelectComponentAt indexPath: IndexPath
    )
}

final class FillBlanksQuizCollectionViewAdapter: NSObject {
    weak var delegate: FillBlanksQuizCollectionViewAdapterDelegate?

    var components: [FillBlanksQuiz.Component]
    var finalState: FillBlanksQuizViewModel.State?

    private var isUserInteractionEnabled: Bool {
        if let finalState = self.finalState {
            if finalState == .correct || finalState == .evaluation {
                return false
            }
        }
        return true
    }

    init(components: [FillBlanksQuiz.Component] = [], finalState: FillBlanksQuizViewModel.State? = nil) {
        self.components = components
        self.finalState = finalState
        super.init()
    }

    private func rowTypeForItemAt(_ indexPath: IndexPath) -> Row {
        let component = self.components[indexPath.row]
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

// MARK: - FillBlanksQuizCollectionViewAdapter: UICollectionViewDataSource -

extension FillBlanksQuizCollectionViewAdapter: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.components.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let component = self.components[indexPath.row]

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
            cell.isEnabled = self.isUserInteractionEnabled
            cell.state = cellState
            cell.onInputChanged = { [weak self] text in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.delegate?.fillBlanksQuizCollectionViewAdapter(
                    strongSelf,
                    inputDidChange: text,
                    forComponent: component
                )
            }
            return cell
        case .select:
            let cell: FillBlanksSelectCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = component.blank ?? ""
            cell.isEnabled = self.isUserInteractionEnabled
            cell.state = cellState
            return cell
        }
    }
}

// MARK: - FillBlanksQuizCollectionViewAdapter: UICollectionViewDelegateFlowLayout -

extension FillBlanksQuizCollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        let maxWidth = collectionView.bounds.width
            - flowLayout.sectionInset.left
            - flowLayout.sectionInset.right

        let component = self.components[indexPath.row]

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
        if !self.isUserInteractionEnabled {
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
        if case .input = self.rowTypeForItemAt(indexPath) {
            if let cell = collectionView.cellForItem(at: indexPath) as? FillBlanksInputCollectionViewCell {
                _ = cell.becomeFirstResponder()
            }
        }

        self.delegate?.fillBlanksQuizCollectionViewAdapter(self, didSelectComponentAt: indexPath)
    }
}
