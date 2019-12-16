import SnapKit
import UIKit

protocol NewSortingQuizElementViewDelegate: AnyObject {
    func newSortingQuizElementViewDidLoadContent(_ view: NewSortingQuizElementView)
    func newSortingQuizElementViewDidUpdateContentHeight(_ view: NewSortingQuizElementView)

    func newSortingQuizElementViewDidRequestMoveTop(_ view: NewSortingQuizElementView)
    func newSortingQuizElementViewDidRequestMoveDown(_ view: NewSortingQuizElementView)

    func newSortingQuizElementView(_ view: NewSortingQuizElementView, didRequestFullscreenImage url: URL)
    func newSortingQuizElementView(_ view: NewSortingQuizElementView, didRequestOpenURL url: URL)
}

extension NewSortingQuizElementView {
    struct Appearance {
        var containerInsets = LayoutInsets(top: 12, left: 16, bottom: 12, right: 16)
        let contentInsets = LayoutInsets(top: 12, left: 16, bottom: 12, right: 16)

        let shadowColor = UIColor(hex: 0xEAECF0)
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4

        let navigationButtonSize = CGSize(width: 24, height: 24)
        let navigationButtonImageSize = CGSize(width: 20, height: 20)
        let navigationButtonTintColorActive = UIColor.mainDark
        let navigationButtonTintColorInactive = UIColor(hex: 0xCCCCCC)
        let navigationButtonVerticalSpacing: CGFloat = 16
        let navigationButtonHorizontalSpacing: CGFloat = 8
    }

    enum Animation {
        static let updateNavigationAnimationDuration: TimeInterval = 0.2
    }
}

final class NewSortingQuizElementView: UIView {
    let appearance: Appearance
    weak var delegate: NewSortingQuizElementViewDelegate?

    private lazy var quizElementView = QuizElementView()
    private lazy var contentTextView: ProcessedContentTextView = {
        var appearance = ProcessedContentTextView.Appearance(
            insets: LayoutInsets(insets: .zero),
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
        button.image = UIImage(named: "menu_arrow_top")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.navigationButtonTintColorActive
        button.imageSize = self.appearance.navigationButtonImageSize
        button.addTarget(self, action: #selector(self.topNavigationButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var bottomNavigationButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "menu_arrow_bottom")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.navigationButtonTintColorActive
        button.imageSize = self.appearance.navigationButtonImageSize
        button.addTarget(self, action: #selector(self.bottomNavigationButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var navigationControlsContainerView = UIView()

    override var intrinsicContentSize: CGSize {
        let contentHeight = max(
            self.contentTextView.intrinsicContentSize.height,
            self.navigationControlsContainerViewHeight
        )
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: (self.appearance.contentInsets.top + self.appearance.contentInsets.bottom) * 2 + contentHeight
        )
    }

    private var navigationControlsContainerViewHeight: CGFloat {
        self.appearance.navigationButtonSize.height * 2 + self.appearance.navigationButtonVerticalSpacing
    }

    var insets: LayoutInsets? {
        didSet {
            let insets = self.insets ?? LayoutInsets(insets: .zero)

            self.quizElementView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(insets.top)
                make.bottom.equalToSuperview().offset(-insets.bottom)
                make.leading.equalToSuperview().offset(insets.left)
                make.trailing.equalToSuperview().offset(-insets.right)
            }

            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }

    var isEnabled = true {
        didSet {
            self.topNavigationButton.isEnabled = self.isEnabled
            self.bottomNavigationButton.isEnabled = self.isEnabled
        }
    }

    var isShadowVisible: Bool = true {
        didSet {
            self.shadowView.isHidden = !self.isShadowVisible
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

    // MARK: - Public API

    func configure(viewModel: ViewModel) {
        self.contentTextView.loadHTMLText(viewModel.option)
        self.updateNavigation(viewModel.direction)
        self.invalidateIntrinsicContentSize()
    }

    func updateNavigation(_ direction: Direction) {
        UIView.animate(withDuration: Animation.updateNavigationAnimationDuration) {
            self.topNavigationButton.tintColor = direction.contains(.top)
                ? self.appearance.navigationButtonTintColorActive
                : self.appearance.navigationButtonTintColorInactive

            self.bottomNavigationButton.tintColor = direction.contains(.bottom)
                ? self.appearance.navigationButtonTintColorActive
                : self.appearance.navigationButtonTintColorInactive

            self.topNavigationButton.isEnabled = direction.contains(.top)
            self.bottomNavigationButton.isEnabled = direction.contains(.bottom)
        }
    }

    // MARK: - Private API

    @objc
    private func topNavigationButtonClicked() {
        self.delegate?.newSortingQuizElementViewDidRequestMoveTop(self)
    }

    @objc
    private func bottomNavigationButtonClicked() {
        self.delegate?.newSortingQuizElementViewDidRequestMoveDown(self)
    }

    // MARK: - Inner structs

    struct ViewModel {
        let option: String
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

        self.quizElementView.addSubview(self.contentTextView)
        self.quizElementView.addSubview(self.navigationControlsContainerView)

        self.addSubview(self.quizElementView)
        self.insertSubview(self.shadowView, belowSubview: self.quizElementView)
    }

    func makeConstraints() {
        self.quizElementView.translatesAutoresizingMaskIntoConstraints = false
        self.quizElementView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.containerInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.containerInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.containerInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.containerInsets.right)
        }

        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.center.equalTo(self.quizElementView)
            make.size.equalTo(self.quizElementView)
        }

        self.contentTextView.translatesAutoresizingMaskIntoConstraints = false
        self.contentTextView.snp.makeConstraints { make in
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
        self.layoutIfNeeded()
        self.delegate?.newSortingQuizElementViewDidLoadContent(self)
    }

    // TODO: Fix problem with contentTextView height contraint (should not be less that navigation buttons height)
    // and remove manual insets adjustment.
    func processedContentTextView(_ view: ProcessedContentTextView, didReportNewHeight height: Int) {
        if height < Int(self.navigationControlsContainerViewHeight) {
            let verticalInset = (self.navigationControlsContainerViewHeight - CGFloat(height)) / 2.0
            self.contentTextView.insets = LayoutInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) {
        self.delegate?.newSortingQuizElementView(self, didRequestOpenURL: url)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) {
        self.delegate?.newSortingQuizElementView(self, didRequestFullscreenImage: url)
    }
}
