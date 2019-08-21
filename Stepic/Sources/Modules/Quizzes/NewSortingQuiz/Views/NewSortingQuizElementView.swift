import SnapKit
import UIKit

protocol NewSortingQuizTableViewCellDelegate: class {
    func newSortingQuizTableViewCellDidLoadContent(_ view: NewSortingQuizElementView)

    func newSortingQuizTableViewCellDidRequestMoveTop(_ view: NewSortingQuizElementView)
    func newSortingQuizTableViewCellDidRequestMoveDown(_ view: NewSortingQuizElementView)
}

extension NewSortingQuizElementView {
    struct Appearance {
        let contentInsets = LayoutInsets(top: 12, left: 16, bottom: 12, right: 16)

        let shadowColor = UIColor(hex: 0xEAECF0)
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4

        let navigationButtonSize = CGSize(width: 24, height: 24)
        let navigationButtonImageSize = CGSize(width: 24, height: 24)
        let navigationButtonTintColor = UIColor.mainDark
        let navigationButtonVerticalSpacing: CGFloat = 16
        let navigationButtonHorizontalSpacing: CGFloat = 8
    }
}

final class NewSortingQuizElementView: UIView {
    let appearance: Appearance
    weak var delegate: NewSortingQuizTableViewCellDelegate?

    private lazy var quizElementView = QuizElementView()
    private lazy var contentView: ProcessedContentTextView = {
        let verticalInset = self.appearance.navigationButtonSize.height
        var appearance = ProcessedContentTextView.Appearance(
            insets: LayoutInsets(top: 19, left: 0, bottom: 19, right: 0),
            backgroundColor: .clear
        )
        let view = ProcessedContentTextView(appearance: appearance)
        view.isScrollEnabled = false
        view.delegate = self
        return view
    }()

    private lazy var shadowView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.backgroundColor = .clear
        view.layer.shadowColor = self.appearance.shadowColor.cgColor
        view.layer.shadowOffset = self.appearance.shadowOffset
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = self.appearance.shadowRadius
        return view
    }()

    private lazy var topNavigationButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "menu_arrow_top")
        button.tintColor = self.appearance.navigationButtonTintColor
        button.imageSize = self.appearance.navigationButtonImageSize
        button.addTarget(self, action: #selector(self.topNavigationButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var bottomNavigationButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "menu_arrow_bottom")
        button.tintColor = self.appearance.navigationButtonTintColor
        button.imageSize = self.appearance.navigationButtonImageSize
        button.addTarget(self, action: #selector(self.bottomNavigationButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var navigationControlsContainerView = UIView()

    override var intrinsicContentSize: CGSize {
        let contentHeight = max(
            self.contentView.intrinsicContentSize.height,
            self.navigationControlsContainerViewHeight
        )
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: (self.appearance.contentInsets.top + self.appearance.contentInsets.bottom) * 2 + contentHeight
        )
    }

    private var navigationControlsContainerViewHeight: CGFloat {
        return self.appearance.navigationButtonSize.height * 2 + self.appearance.navigationButtonVerticalSpacing
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.invalidateIntrinsicContentSize()

        DispatchQueue.main.async {
            self.shadowView.layer.shadowPath = UIBezierPath(
                roundedRect: self.shadowView.bounds,
                cornerRadius: self.quizElementView.appearance.cornerRadius
            ).cgPath
        }
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

    // MARK: - Public API

    func configure(viewModel: ViewModel) {
        self.contentView.loadHTMLText(viewModel.text)
        self.updateNavigation(viewModel.direction)
        self.invalidateIntrinsicContentSize()
    }

    func updateNavigation(_ direction: Direction) {
        self.topNavigationButton.isEnabled = direction.contains(.top)
        self.bottomNavigationButton.isEnabled = direction.contains(.bottom)
    }

    // MARK: - Private API

    @objc
    private func topNavigationButtonClicked() {
        self.delegate?.newSortingQuizTableViewCellDidRequestMoveTop(self)
    }

    @objc
    private func bottomNavigationButtonClicked() {
        self.delegate?.newSortingQuizTableViewCellDidRequestMoveDown(self)
    }

    // MARK: - Inner structs

    struct ViewModel {
        let text: String
        let direction: Direction
    }

    struct Direction: OptionSet {
        let rawValue: Int

        static let top = Direction(rawValue: 1)
        static let bottom = Direction(rawValue: 2)
    }
}

extension NewSortingQuizElementView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.navigationControlsContainerView.addSubview(self.topNavigationButton)
        self.navigationControlsContainerView.addSubview(self.bottomNavigationButton)

        self.quizElementView.addSubview(self.contentView)
        self.quizElementView.addSubview(self.navigationControlsContainerView)

        self.addSubview(self.quizElementView)
        self.insertSubview(self.shadowView, belowSubview: self.quizElementView)
    }

    func makeConstraints() {
        self.quizElementView.translatesAutoresizingMaskIntoConstraints = false
        self.quizElementView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.contentInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.contentInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.contentInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.contentInsets.right)
        }

        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.center.equalTo(self.quizElementView)
            make.size.equalTo(self.quizElementView)
        }

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.contentInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.contentInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.contentInsets.left)
            make.trailing
                .equalTo(self.navigationControlsContainerView.snp.leading)
                .offset(-self.appearance.navigationButtonHorizontalSpacing)
        }

        self.navigationControlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationControlsContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.contentInsets.right)
            make.height.equalTo(self.navigationControlsContainerViewHeight)
            make.width.equalTo(self.appearance.navigationButtonSize.width)
            make.centerY.equalToSuperview()
        }

        self.topNavigationButton.translatesAutoresizingMaskIntoConstraints = false
        self.topNavigationButton.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.size.equalTo(self.appearance.navigationButtonSize)
            make.bottom
                .equalTo(self.bottomNavigationButton.snp.top)
                .offset(-self.appearance.navigationButtonVerticalSpacing)
        }

        self.bottomNavigationButton.translatesAutoresizingMaskIntoConstraints = false
        self.bottomNavigationButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.size.equalTo(self.appearance.navigationButtonSize)
        }
    }
}

extension NewSortingQuizElementView: ProcessedContentTextViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        self.invalidateIntrinsicContentSize()
        self.delegate?.newSortingQuizTableViewCellDidLoadContent(self)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) { }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) { }
}
