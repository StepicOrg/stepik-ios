import SnapKit
import UIKit

protocol NewSortingQuizViewDelegate: class {
    func newSortingQuizView(
        _ view: NewSortingQuizView,
        didMoveOption option: NewSortingQuiz.Option,
        atIndex sourceIndex: Int,
        toIndex destinationIndex: Int
    )

    func newSortingQuizView(_ view: NewSortingQuizView, didRequestFullscreenImage url: URL)
    func newSortingQuizView(_ view: NewSortingQuizView, didRequestOpenURL url: URL)
}

extension NewSortingQuizView {
    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.33
        static let moveSortingOptionAnimationDuration: TimeInterval = 0.33
    }
}

final class NewSortingQuizView: UIView {
    weak var delegate: NewSortingQuizViewDelegate?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    var isEnabled = true {
        didSet {
            self.stackView.isUserInteractionEnabled = self.isEnabled
        }
    }

    private(set) var options: [NewSortingQuiz.Option] = []

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(options: [NewSortingQuiz.Option]) {
        if self.options.map({ $0.text }) == options.map({ $0.text }) {
            return
        }

        self.options = options

        self.stackView.removeAllArrangedSubviews()
        options.enumerated().forEach { index, option in
            let sortingOptionView = NewSortingQuizElementView()
            sortingOptionView.delegate = self
            sortingOptionView.tag = option.id
            sortingOptionView.configure(
                viewModel: .init(
                    option: option.text,
                    direction: self.getAvailableNavigationDirectionAtIndex(index)
                )
            )

            self.stackView.addArrangedSubview(sortingOptionView)
        }

        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
    }

    private func getAvailableNavigationDirectionAtIndex(_ index: Int) -> NewSortingQuizElementView.Direction {
        var direction: NewSortingQuizElementView.Direction = []

        if index != 0 {
            direction.insert(.top)
        }

        if index != self.options.count - 1 {
            direction.insert(.bottom)
        }

        return direction
    }
}

extension NewSortingQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NewSortingQuizView: NewSortingQuizElementViewDelegate {
    func newSortingQuizElementViewDidLoadContent(_ view: NewSortingQuizElementView) {
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
    }

    func newSortingQuizElementViewDidUpdateContentHeight(_ view: NewSortingQuizElementView) {
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
    }

    func newSortingQuizElementViewDidRequestMoveTop(_ view: NewSortingQuizElementView) {
        self.move(view, direction: .top)
    }

    func newSortingQuizElementViewDidRequestMoveDown(_ view: NewSortingQuizElementView) {
        self.move(view, direction: .bottom)
    }

    func newSortingQuizElementView(_ view: NewSortingQuizElementView, didRequestOpenURL url: URL) {
        self.delegate?.newSortingQuizView(self, didRequestOpenURL: url)
    }

    func newSortingQuizElementView(_ view: NewSortingQuizElementView, didRequestFullscreenImage url: URL) {
        self.delegate?.newSortingQuizView(self, didRequestFullscreenImage: url)
    }

    private func move(_ view: NewSortingQuizElementView, direction: Direction) {
        guard let option = self.options.first(where: { $0.id == view.tag }),
              let sourceIndex = self.options.firstIndex(where: { $0.id == option.id }) else {
            return
        }

        let destinationIndex = direction == .top ? sourceIndex - 1 : sourceIndex + 1

        self.stackView.removeArrangedSubview(view)
        UIView.animate(
            withDuration: Animation.moveSortingOptionAnimationDuration,
            animations: {
                self.stackView.insertArrangedSubview(view, at: destinationIndex)
                self.stackView.setNeedsLayout()
                self.stackView.layoutIfNeeded()
            },
            completion: { isFinished in
                guard isFinished else {
                    return
                }

                view.updateNavigation(self.getAvailableNavigationDirectionAtIndex(destinationIndex))
                if let affectedView = self.stackView.arrangedSubviews[safe: sourceIndex] as? NewSortingQuizElementView {
                    affectedView.updateNavigation(self.getAvailableNavigationDirectionAtIndex(sourceIndex))
                }
            }
        )

        self.options.remove(at: sourceIndex)
        self.options.insert(option, at: destinationIndex)

        self.delegate?.newSortingQuizView(self, didMoveOption: option, atIndex: sourceIndex, toIndex: destinationIndex)
    }

    private enum Direction {
        case top
        case bottom
    }
}
