import SnapKit
import UIKit

protocol NewMatchingQuizViewDelegate: class {
    func newMatchingQuizView(
        _ view: NewMatchingQuizView,
        didMoveItem item: NewMatchingQuiz.MatchItem,
        atIndex sourceIndex: Int,
        toIndex destinationIndex: Int
    )

    func newMatchingQuizView(_ view: NewMatchingQuizView, didRequestFullscreenImage url: URL)
    func newMatchingQuizView(_ view: NewMatchingQuizView, didRequestOpenURL url: URL)
}

extension NewMatchingQuizView {
    struct Appearance {
        let loadingIndicatorColor = UIColor.mainDark
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.2
        static let appearanceAnimationDelay: TimeInterval = 1.0

        static let moveSortingOptionAnimationDuration: TimeInterval = 0.33
    }
}

final class NewMatchingQuizView: UIView {
    let appearance: Appearance
    weak var delegate: NewMatchingQuizViewDelegate?

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .white)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var itemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    var isEnabled = true {
        didSet {
            self.itemsStackView.isUserInteractionEnabled = self.isEnabled
        }
    }

    private var loadGroup: DispatchGroup?

    private(set) var items: [NewMatchingQuiz.MatchItem] = []

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

    func set(items: [NewMatchingQuiz.MatchItem]) {
        if self.items.map({ $0.title.text }) == items.map({ $0.title.text })
           && self.items.map({ $0.option.text }) == items.map({ $0.option.text }) {
            return
        }

        self.startLoading()

        self.loadGroup = DispatchGroup()
        self.loadGroup?.notify(queue: .main) { [weak self] in
            self?.endLoading()
        }

        self.items = items

        if !self.itemsStackView.arrangedSubviews.isEmpty {
            self.itemsStackView.removeAllArrangedSubviews()
        }

        items.enumerated().forEach { index, item in
            let titleView = NewMatchingQuizTitleView()
            titleView.delegate = self
            titleView.tag = item.title.id
            titleView.title = item.title.text

            self.loadGroup?.enter()
            self.itemsStackView.addArrangedSubview(titleView)

            let sortingOptionView = NewSortingQuizElementView()
            sortingOptionView.delegate = self
            sortingOptionView.tag = item.option.id
            sortingOptionView.configure(
                viewModel: .init(
                    option: item.option.text,
                    direction: self.getAvailableNavigationDirectionAtIndex(index)
                )
            )

            self.loadGroup?.enter()
            self.itemsStackView.addArrangedSubview(sortingOptionView)
        }

        self.itemsStackView.setNeedsLayout()
        self.itemsStackView.layoutIfNeeded()
    }

    // MARK: - Private API

    func startLoading() {
        self.itemsStackView.alpha = 0.0
        self.loadingIndicatorView.startAnimating()
    }

    func endLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.appearanceAnimationDelay) {
            self.loadingIndicatorView.stopAnimating()

            UIView.animate(
                withDuration: Animation.appearanceAnimationDuration,
                animations: {
                    self.itemsStackView.alpha = 1.0
                }
            )
        }
    }

    private func getAvailableNavigationDirectionAtIndex(_ index: Int) -> NewSortingQuizElementView.Direction {
        var direction: NewSortingQuizElementView.Direction = []

        if index != 0 {
            direction.insert(.top)
        }

        if index != self.items.count - 1 {
            direction.insert(.bottom)
        }

        return direction
    }
}

extension NewMatchingQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.itemsStackView)
        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.itemsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension NewMatchingQuizView: NewMatchingQuizTitleViewDelegate {
    func newMatchingQuizTitleViewDidLoadContent(_ view: NewMatchingQuizTitleView) {
        self.onContentLoad()
    }

    func newMatchingQuizTitleView(_ view: NewMatchingQuizTitleView, didRequestOpenURL url: URL) {
        self.delegate?.newMatchingQuizView(self, didRequestOpenURL: url)
    }

    func newMatchingQuizTitleView(_ view: NewMatchingQuizTitleView, didRequestFullscreenImage url: URL) {
        self.delegate?.newMatchingQuizView(self, didRequestFullscreenImage: url)
    }

    private func onContentLoad() {
        self.itemsStackView.setNeedsLayout()
        self.itemsStackView.layoutIfNeeded()

        self.loadGroup?.leave()
    }
}

extension NewMatchingQuizView: NewSortingQuizElementViewDelegate {
    func newSortingQuizElementViewDidLoadContent(_ view: NewSortingQuizElementView) {
        self.onContentLoad()
    }

    func newSortingQuizElementViewDidUpdateContentHeight(_ view: NewSortingQuizElementView) {
        self.itemsStackView.setNeedsLayout()
        self.itemsStackView.layoutIfNeeded()
    }

    func newSortingQuizElementViewDidRequestMoveTop(_ view: NewSortingQuizElementView) {
        self.move(view, direction: .top)
    }

    func newSortingQuizElementViewDidRequestMoveDown(_ view: NewSortingQuizElementView) {
        self.move(view, direction: .bottom)
    }

    func newSortingQuizElementView(_ view: NewSortingQuizElementView, didRequestOpenURL url: URL) {
        self.delegate?.newMatchingQuizView(self, didRequestOpenURL: url)
    }

    func newSortingQuizElementView(_ view: NewSortingQuizElementView, didRequestFullscreenImage url: URL) {
        self.delegate?.newMatchingQuizView(self, didRequestFullscreenImage: url)
    }

    private func move(_ view: NewSortingQuizElementView, direction: Direction) {
//        guard let option = self.items.first(where: { $0.id == view.tag }),
//              let sourceIndex = self.items.firstIndex(where: { $0.id == option.id }) else {
//            return
//        }
//
//        let destinationIndex = direction == .top ? sourceIndex - 1 : sourceIndex + 1
//
//        self.itemsStackView.removeArrangedSubview(view)
//        UIView.animate(
//            withDuration: Animation.moveSortingOptionAnimationDuration,
//            animations: {
//                self.itemsStackView.insertArrangedSubview(view, at: destinationIndex)
//                self.itemsStackView.setNeedsLayout()
//                self.itemsStackView.layoutIfNeeded()
//            },
//            completion: { isFinished in
//                guard isFinished else {
//                    return
//                }
//
//                view.updateNavigation(self.getAvailableNavigationDirectionAtIndex(destinationIndex))
//                if let affectedView = self.itemsStackView.arrangedSubviews[
//                    safe: sourceIndex
//                    ] as? NewSortingQuizElementView {
//                    affectedView.updateNavigation(self.getAvailableNavigationDirectionAtIndex(sourceIndex))
//                }
//            }
//        )
//
//        self.items.remove(at: sourceIndex)
//        self.items.insert(option, at: destinationIndex)
//
//        self.delegate?.newSortingQuizView(self, didMoveOption: option, atIndex: sourceIndex, toIndex: destinationIndex)
    }

    private enum Direction {
        case top
        case bottom
    }
}
