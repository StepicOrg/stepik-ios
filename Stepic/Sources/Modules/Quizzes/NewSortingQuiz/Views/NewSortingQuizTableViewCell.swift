import SnapKit
import UIKit

protocol NewSortingQuizTableViewCellDelegate: class {
    func newSortingQuizTableViewCellDidLoadContent(_ view: NewSortingQuizTableViewCell)

    func newSortingQuizTableViewCellDidRequestMoveTop(_ view: NewSortingQuizTableViewCell)
    func newSortingQuizTableViewCellDidRequestMoveDown(_ view: NewSortingQuizTableViewCell)
}

final class NewSortingQuizTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let contentInsets = LayoutInsets(top: 12, left: 16, bottom: 12, right: 16)

        static let shadowColor = UIColor(hex: 0xEAECF0)
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let shadowRadius: CGFloat = 4

        static let navigationButtonSize = CGSize(width: 20, height: 20)
        static let navigationButtonTintColor = UIColor.mainDark
    }

    weak var delegate: NewSortingQuizTableViewCellDelegate?

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
        view.layer.shadowColor = Appearance.shadowColor.cgColor
        view.layer.shadowOffset = Appearance.shadowOffset
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = Appearance.shadowRadius
        return view
    }()

    private lazy var topNavigationButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "menu_arrow_top")
        button.tintColor = Appearance.navigationButtonTintColor
        button.imageSize = Appearance.navigationButtonSize
        button.addTarget(self, action: #selector(self.topNavigationButtonClicked), for: .touchUpInside)
        //button.backgroundColor = .green
        return button
    }()

    private lazy var bottomNavigationButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "menu_arrow_bottom")
        button.tintColor = Appearance.navigationButtonTintColor
        button.imageSize = Appearance.navigationButtonSize
        button.addTarget(self, action: #selector(self.bottomNavigationButtonClicked), for: .touchUpInside)
        //button.backgroundColor = .red
        return button
    }()

    private lazy var navigationControlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.topNavigationButton, self.bottomNavigationButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.quizElementView.superview == nil {
            self.setupSubview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.shadowView.layer.shadowPath = UIBezierPath(
                roundedRect: self.shadowView.bounds,
                cornerRadius: self.quizElementView.appearance.cornerRadius
            ).cgPath
        }
    }

    // MARK: - Public API

    func configure(viewModel: ViewModel) {
        self.contentTextView.loadHTMLText(viewModel.text)
        self.updateNavigation(viewModel.direction)
    }

    func updateNavigation(_ direction: Direction) {
        self.topNavigationButton.isEnabled = direction.contains(.top)
        self.bottomNavigationButton.isEnabled = direction.contains(.bottom)
    }

    // MARK: - Private API

    private func setupSubview() {
        self.quizElementView.addSubview(self.contentTextView)
        self.quizElementView.addSubview(self.navigationControlsStackView)

        self.contentView.addSubview(self.quizElementView)
        self.contentView.insertSubview(self.shadowView, belowSubview: self.quizElementView)

        self.clipsToBounds = true
        self.contentView.clipsToBounds = true

        self.quizElementView.translatesAutoresizingMaskIntoConstraints = false
        self.quizElementView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Appearance.contentInsets.top)
            make.bottom.equalToSuperview().offset(-Appearance.contentInsets.bottom)
            make.leading.equalToSuperview().offset(Appearance.contentInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.contentInsets.right)
        }

        self.contentTextView.translatesAutoresizingMaskIntoConstraints = false
        self.contentTextView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(Appearance.contentInsets.top)
//            make.bottom.equalToSuperview().offset(-Appearance.contentInsets.bottom)
            make.leading.equalToSuperview().offset(Appearance.contentInsets.left)
            make.centerY.equalToSuperview()
        }

        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.center.equalTo(self.quizElementView)
            make.size.equalTo(self.quizElementView)
        }

        self.navigationControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationControlsStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.contentTextView.snp.trailing)
            make.top.equalToSuperview().offset(Appearance.contentInsets.top)
            make.trailing.equalToSuperview().offset(-Appearance.contentInsets.right)
            make.bottom.equalToSuperview().offset(-Appearance.contentInsets.bottom)
        }
    }

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

extension NewSortingQuizTableViewCell: ProcessedContentTextViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        self.delegate?.newSortingQuizTableViewCellDidLoadContent(self)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) { }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) { }
}
