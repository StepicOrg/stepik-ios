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
    struct Appearance {
        let spacing: CGFloat = 16
        let insets = LayoutInsets(left: 16, right: 16)

        let separatorColor = UIColor(hex: 0xEAECF0)
        let separatorHeight: CGFloat = 1

        let titleColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let loadingIndicatorColor = UIColor.mainDark
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.2
        static let appearanceAnimationDelay: TimeInterval = 1.0

        static let moveSortingOptionAnimationDuration: TimeInterval = 0.33
    }
}

final class NewSortingQuizView: UIView {
    let appearance: Appearance
    weak var delegate: NewSortingQuizViewDelegate?

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .white)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [self.separatorView, self.titleLabelContainerView, self.optionsContainerView]
        )
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var titleLabelContainerView = UIView()
    private lazy var optionsContainerView = UIView()

    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    var isEnabled = true {
        didSet {
            self.optionsStackView.isUserInteractionEnabled = self.isEnabled
            self.optionsStackView.arrangedSubviews
                .compactMap { $0 as? NewSortingQuizElementView }
                .enumerated()
                .forEach { index, view in
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
            self.optionsStackView.arrangedSubviews
                .compactMap { $0 as? NewSortingQuizElementView }
                .forEach { $0.isShadowVisible = self.shouldShowShadows }
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    private var loadGroup: DispatchGroup?

    private(set) var options: [NewSortingQuiz.Option] = []

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

    func set(options: [NewSortingQuiz.Option]) {
        if self.options.map({ $0.text }) == options.map({ $0.text }) {
            return
        }

        self.startLoading()

        self.loadGroup = DispatchGroup()
        self.loadGroup?.notify(queue: .main) { [weak self] in
            self?.endLoading()
        }

        self.options = options

        if !self.optionsStackView.arrangedSubviews.isEmpty {
            self.optionsStackView.removeAllArrangedSubviews()
        }

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

            self.loadGroup?.enter()
            self.optionsStackView.addArrangedSubview(sortingOptionView)
        }

        self.optionsStackView.setNeedsLayout()
        self.optionsStackView.layoutIfNeeded()
    }

    // MARK: - Private API

    func startLoading() {
        self.optionsStackView.alpha = 0.0
        self.loadingIndicatorView.startAnimating()
    }

    func endLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.appearanceAnimationDelay) {
            self.loadingIndicatorView.stopAnimating()

            UIView.animate(
                withDuration: Animation.appearanceAnimationDuration,
                animations: {
                    self.optionsStackView.alpha = 1.0
                }
            )
        }
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

        self.titleLabelContainerView.addSubview(self.titleLabel)
        self.optionsContainerView.addSubview(self.optionsStackView)

        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }

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

        self.optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension NewSortingQuizView: NewSortingQuizElementViewDelegate {
    func newSortingQuizElementViewDidLoadContent(_ view: NewSortingQuizElementView) {
        self.optionsStackView.setNeedsLayout()
        self.optionsStackView.layoutIfNeeded()

        self.loadGroup?.leave()
    }

    func newSortingQuizElementViewDidUpdateContentHeight(_ view: NewSortingQuizElementView) {
        self.optionsStackView.setNeedsLayout()
        self.optionsStackView.layoutIfNeeded()
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

        self.optionsStackView.removeArrangedSubview(view)
        UIView.animate(
            withDuration: Animation.moveSortingOptionAnimationDuration,
            animations: {
                self.optionsStackView.insertArrangedSubview(view, at: destinationIndex)
                self.optionsStackView.setNeedsLayout()
                self.optionsStackView.layoutIfNeeded()
            },
            completion: { isFinished in
                guard isFinished else {
                    return
                }

                view.updateNavigation(self.getAvailableNavigationDirectionAtIndex(destinationIndex))
                if let affectedView = self.optionsStackView.arrangedSubviews[
                    safe: sourceIndex
                ] as? NewSortingQuizElementView {
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
