import SnapKit
import UIKit

protocol NewMatchingQuizViewDelegate: AnyObject {
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
        let spacing: CGFloat = 16
        let insets = LayoutInsets(left: 16, right: 16)

        let defaultSortingOptionInsets = LayoutInsets(top: 0, left: 64, bottom: 12, right: 16)
        let lastSortingOptionInsets = LayoutInsets(top: 0, left: 64, bottom: 0, right: 16)

        let defaultSortingTitleInsets = LayoutInsets(top: 12, left: 16, bottom: 10, right: 64)
        let firstSortingTitleInsets = LayoutInsets(top: 0, left: 16, bottom: 10, right: 64)

        let titleColor = UIColor.stepikAccent
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let loadingIndicatorColor = UIColor.stepikLoadingIndicator
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
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikWhite)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [self.titleLabelContainerView, self.itemsContainerView]
        )
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var titleLabelContainerView = UIView()
    private lazy var itemsContainerView = UIView()

    private lazy var itemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    var isEnabled = true {
        didSet {
            self.itemsStackView.isUserInteractionEnabled = self.isEnabled
            self.itemsStackView.arrangedSubviews.enumerated().forEach { index, view in
                guard let view = view as? NewSortingQuizElementView else {
                    return
                }

                if self.isEnabled {
                    view.updateNavigation(self.getAvailableNavigationDirectionAtIndex(index))
                } else {
                    view.isEnabled = false
                }
            }
        }
    }

    var shouldShowShadows: Bool = true {
        didSet {
            self.itemsStackView.arrangedSubviews
                .forEach { view in
                    if let titleView = view as? NewMatchingQuizTitleView {
                        titleView.isShadowVisible = self.shouldShowShadows
                    } else if let elementView = view as? NewSortingQuizElementView {
                        elementView.isShadowVisible = self.shouldShowShadows
                    }
                }
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
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
            self?.loadGroup = nil
            self?.endLoading()
        }

        self.items = items

        if !self.itemsStackView.arrangedSubviews.isEmpty {
            self.itemsStackView.removeAllArrangedSubviews()
        }

        items.enumerated().forEach { index, item in
            let titleInsets = index == 0
                ? self.appearance.firstSortingTitleInsets
                : self.appearance.defaultSortingTitleInsets
            let titleView = NewMatchingQuizTitleView(frame: .zero, appearance: .init(containerInsets: titleInsets))
            titleView.delegate = self
            titleView.tag = item.title.id
            titleView.title = item.title.text

            self.loadGroup?.enter()
            self.itemsStackView.addArrangedSubview(titleView)

            let sortingOptionInsets = index == items.count - 1
                ? self.appearance.lastSortingOptionInsets
                : self.appearance.defaultSortingOptionInsets
            let sortingOptionView = NewSortingQuizElementView(
                frame: .zero,
                appearance: .init(containerInsets: sortingOptionInsets)
            )
            sortingOptionView.delegate = self
            sortingOptionView.tag = item.option.id
            sortingOptionView.configure(
                viewModel: .init(
                    option: item.option.text,
                    direction: self.getAvailableNavigationDirectionAtIndex(self.itemsStackView.arrangedSubviews.count)
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

        if index != 1 {
            direction.insert(.top)
        }

        if index != (self.items.count * 2) - 1 {
            direction.insert(.bottom)
        }

        return direction
    }
}

extension NewMatchingQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.titleLabelContainerView.addSubview(self.titleLabel)
        self.itemsContainerView.addSubview(self.itemsStackView)

        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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
        guard let item = self.items.first(where: { $0.option.id == view.tag }),
              let subviewSourceIndex = self.itemsStackView.arrangedSubviews.firstIndex(where: { $0 === view }),
              let itemSourceIndex = self.items.firstIndex(where: { $0.option.id == item.option.id }) else {
            return
        }

        let subviewDestinationIndex = direction == .top ? subviewSourceIndex - 2 : subviewSourceIndex + 2
        let itemDestinationIndex = direction == .top ? itemSourceIndex - 1 : itemSourceIndex + 1

        let movingView = self.itemsStackView.arrangedSubviews[subviewDestinationIndex]

        UIView.animate(withDuration: Animation.moveSortingOptionAnimationDuration) {
            self.itemsStackView.removeArrangedSubview(view)
            self.itemsStackView.insertArrangedSubview(view, at: subviewDestinationIndex)
            self.itemsStackView.removeArrangedSubview(movingView)
            self.itemsStackView.insertArrangedSubview(movingView, at: subviewSourceIndex)

            self.updateSortingOptionView(view, at: subviewDestinationIndex)
            if let movingView = movingView as? NewSortingQuizElementView {
                self.updateSortingOptionView(movingView, at: subviewSourceIndex)
            }

            self.itemsStackView.setNeedsLayout()
            self.itemsStackView.layoutIfNeeded()
        }

        let movingPair = NewMatchingQuiz.MatchItem(
            title: self.items[itemDestinationIndex].title,
            option: self.items[itemSourceIndex].option
        )
        let affectedPair = NewMatchingQuiz.MatchItem(
            title: self.items[itemSourceIndex].title,
            option: self.items[itemDestinationIndex].option
        )
        self.items[itemDestinationIndex] = movingPair
        self.items[itemSourceIndex] = affectedPair

        self.delegate?.newMatchingQuizView(
            self,
            didMoveItem: item,
            atIndex: subviewSourceIndex,
            toIndex: subviewDestinationIndex
        )
    }

    private func updateSortingOptionView(_ view: NewSortingQuizElementView, at index: Int) {
        view.updateNavigation(self.getAvailableNavigationDirectionAtIndex(index))
        view.insets = index == self.itemsStackView.arrangedSubviews.count - 1
            ? self.appearance.lastSortingOptionInsets
            : self.appearance.defaultSortingOptionInsets
    }

    private enum Direction {
        case top
        case bottom
    }
}
