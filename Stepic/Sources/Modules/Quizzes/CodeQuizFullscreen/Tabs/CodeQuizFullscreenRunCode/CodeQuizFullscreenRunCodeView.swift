import SnapKit
import UIKit

protocol CodeQuizFullscreenRunCodeViewDelegate: AnyObject {
    func codeQuizFullscreenRunCodeViewDidClickRunCode(_ view: CodeQuizFullscreenRunCodeView)
    func codeQuizFullscreenRunCodeViewDidClickSamples(_ view: CodeQuizFullscreenRunCodeView, sender: Any)
    func codeQuizFullscreenRunCodeView(_ view: CodeQuizFullscreenRunCodeView, testInputDidChange input: String)
}

extension CodeQuizFullscreenRunCodeView {
    struct Appearance {
        let samplesButtonFont = UIFont.preferredFont(forTextStyle: .subheadline)
        let samplesButtonTintColor = UIColor.mainDark
        let samplesButtonImageSize = CGSize(width: 15, height: 15)
        let samplesButtonImageInsets = UIEdgeInsets(top: 2, left: 4, bottom: 0, right: 0)
        let samplesButtonInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 16)

        let runCodeButtonBackgroundColor = UIColor.stepikGreen
        let runCodeButtonHeight: CGFloat = 44
        let runCodeButtonTextColor = UIColor.white
        let runCodeButtonCornerRadius: CGFloat = 6
        let runCodeButtonFont = UIFont.systemFont(ofSize: 16)

        let bottomControlsStackViewSpacing: CGFloat = 16
        let bottomControlsStackViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let testInputOutputPrimaryTextColor = UIColor.mainDark
        let testInputPlaceholderTextColor = UIColor.mainDark.withAlphaComponent(0.4)

        let testInputOutputTitleFont = UIFont.preferredFont(forTextStyle: .headline)
        let testInputOutputTextViewFont = UIFont.preferredFont(forTextStyle: .body)

        let testInputOutputTitleInsets = UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8)
        let testInputOutputTextViewInsets = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        let testInputTextViewTextInsets = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)

        let testInputOutputScrollableStackViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        let testInputOutputScrollableStackViewSpacing: CGFloat = 16

        let testInputOutputTitleImageSize = CGSize(width: 20, height: 20)
        let testInputOutputTitleImageInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

        let cardBackgroundColor = UIColor.white
        let cardCornerRadius: CGFloat = 6
        let backgroundColor = UIColor(hex: 0xF1F2F6)

        let testInputTitle = NSLocalizedString("CodeQuizFullscreenTabRunInputDataTitle", comment: "")
        let testOutputTitle = NSLocalizedString("CodeQuizFullscreenTabRunOutputDataTitle", comment: "")
    }
}

final class CodeQuizFullscreenRunCodeView: UIView {
    let appearance: Appearance
    weak var delegate: CodeQuizFullscreenRunCodeViewDelegate?

    private lazy var samplesButton: ImageButton = {
        let button = ImageButton()
        button.tintColor = self.appearance.samplesButtonTintColor
        button.title = NSLocalizedString("CodeQuizFullscreenTabRunSamplesButtonTitle", comment: "")
        button.font = self.appearance.samplesButtonFont
        button.image = UIImage(named: "code-quiz-arrow-down")?.withRenderingMode(.alwaysTemplate)
        button.imageSize = self.appearance.samplesButtonImageSize
        button.imageInsets = self.appearance.samplesButtonImageInsets
        button.imagePosition = .right
        button.addTarget(self, action: #selector(self.samplesClicked), for: .touchUpInside)
        return button
    }()

    private lazy var evaluationView: QuizFeedbackView = {
        let view = QuizFeedbackView()
        view.update(
            state: .evaluation,
            title: NSLocalizedString("CodeQuizFullscreenTabRunEvaluationTitle", comment: "")
        )
        return view
    }()

    private lazy var runCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(self.appearance.runCodeButtonTextColor, for: .normal)
        button.setTitle(NSLocalizedString("CodeQuizFullscreenTabRunRunCodeButtonTitle", comment: ""), for: .normal)
        button.titleLabel?.font = self.appearance.runCodeButtonFont
        button.layer.cornerRadius = self.appearance.runCodeButtonCornerRadius
        button.clipsToBounds = true
        button.backgroundColor = self.appearance.runCodeButtonBackgroundColor
        button.addTarget(self, action: #selector(self.runCodeClicked), for: .touchUpInside)
        return button
    }()

    private lazy var bottomControlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.evaluationView, self.runCodeButton])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.bottomControlsStackViewSpacing
        return stackView
    }()

    private lazy var testInputTitleLabel = self.makeTitleLabel(text: self.appearance.testInputTitle)
    private lazy var testOutputTitleLabel = self.makeTitleLabel(text: self.appearance.testOutputTitle)

    private lazy var testInputImageView = self.makeTitleImageView(image: UIImage(named: "keyboard-chevron"))
    private lazy var testOutputImageView = self.makeTitleImageView(image: nil)

    private lazy var testInputTextView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.font = self.appearance.testInputOutputTextViewFont
        textView.textColor = self.appearance.testInputOutputPrimaryTextColor
        textView.placeholderColor = self.appearance.testInputPlaceholderTextColor
        textView.placeholder = NSLocalizedString("CodeQuizFullscreenTabRunInputDataPlaceholder", comment: "")
        textView.textInsets = self.appearance.testInputTextViewTextInsets
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.dataDetectorTypes = []
        textView.delegate = self
        return textView
    }()

    private lazy var testOutputLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.testInputOutputTextViewFont
        label.textColor = self.appearance.testInputOutputPrimaryTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var testInputCardView = self.makeCardView()
    private lazy var testOutputCardView = self.makeCardView()

    private lazy var testInputOutputScrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(orientation: .vertical)
        stackView.spacing = self.appearance.testInputOutputScrollableStackViewSpacing
        stackView.showsVerticalScrollIndicator = false
        return stackView
    }()

    var testInput: String {
        get {
            self.testInputTextView.text
        }
        set {
            if self.testInputTextView.text != newValue {
                self.testInputTextView.text = newValue
            }
        }
    }

    var isRunCodeButtonEnabled = true {
        didSet {
            self.runCodeButton.isEnabled = self.isRunCodeButtonEnabled
            self.runCodeButton.alpha = self.isRunCodeButtonEnabled ? 1.0 : 0.5
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

    // MARK: Public API

    func configure(viewModel: CodeQuizFullscreenRunCodeViewModel) {
        self.testInput = viewModel.testInput ?? ""
        self.testOutputLabel.text = viewModel.testOutput

        self.testOutputCardView.isHidden = !viewModel.shouldShowTestOutput
        self.samplesButton.isEnabled = viewModel.isSamplesButtonEnabled
        self.isRunCodeButtonEnabled = viewModel.isRunCodeButtonEnabled

        self.updateTestOutputImage(userCodeRunStatus: viewModel.userCodeRunStatus)

        self.testInputTextView.isEditable = viewModel.userCodeRunStatus == .evaluation ? false : true
        self.evaluationView.isHidden = viewModel.userCodeRunStatus == .evaluation ? false : true
    }

    // MARK: Private API

    private func makeTitleImageView(image: UIImage?) -> UIImageView {
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .mainDark
        return imageView
    }

    private func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = self.appearance.testInputOutputPrimaryTextColor
        label.font = self.appearance.testInputOutputTitleFont
        label.text = text
        return label
    }

    private func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = self.appearance.cardBackgroundColor
        view.layer.cornerRadius = self.appearance.cardCornerRadius
        view.clipsToBounds = true
        return view
    }

    private func updateTestOutputImage(userCodeRunStatus: UserCodeRun.Status?) {
        let (image, tintColor): (UIImage?, UIColor) = {
            switch userCodeRunStatus {
            case .success:
                return (UIImage(named: "quiz-feedback-correct"), UIColor(hex: 0x66CC66))
            case .failure:
                return (UIImage(named: "quiz-feedback-wrong"), UIColor(hex: 0xFF7965))
            default:
                return (UIImage(named: "course-info-syllabus-download-all"), UIColor.mainDark)
            }
        }()

        self.testOutputImageView.image = image
        self.testOutputImageView.tintColor = tintColor
    }

    @objc
    private func samplesClicked() {
        self.delegate?.codeQuizFullscreenRunCodeViewDidClickSamples(self, sender: self.samplesButton)
    }

    @objc
    private func runCodeClicked() {
        self.delegate?.codeQuizFullscreenRunCodeViewDidClickRunCode(self)
    }
}

extension CodeQuizFullscreenRunCodeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.testOutputCardView.isHidden = true
        self.evaluationView.isHidden = true
    }

    func addSubviews() {
        self.addSubview(self.testInputOutputScrollableStackView)
        self.addSubview(self.bottomControlsStackView)

        self.testInputOutputScrollableStackView.addArrangedView(self.testInputCardView)
        self.testInputOutputScrollableStackView.addArrangedView(self.testOutputCardView)

        self.testInputCardView.addSubview(self.testInputImageView)
        self.testInputCardView.addSubview(self.testInputTitleLabel)
        self.testInputCardView.addSubview(self.testInputTextView)
        self.testInputCardView.addSubview(self.samplesButton)

        self.testOutputCardView.addSubview(self.testOutputImageView)
        self.testOutputCardView.addSubview(self.testOutputTitleLabel)
        self.testOutputCardView.addSubview(self.testOutputLabel)
    }

    func makeConstraints() {
        self.samplesButton.translatesAutoresizingMaskIntoConstraints = false
        self.samplesButton.setContentHuggingPriority(.required, for: .horizontal)
        self.samplesButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(self.appearance.samplesButtonInsets)
            make.centerY.equalTo(self.testInputTitleLabel.snp.centerY)
        }

        self.testInputOutputScrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.testInputOutputScrollableStackView.snp.makeConstraints { make in
            make.top.leading.trailing
                .equalTo(self.safeAreaLayoutGuide)
                .inset(self.appearance.testInputOutputScrollableStackViewInsets)
        }

        self.testInputImageView.translatesAutoresizingMaskIntoConstraints = false
        self.testInputImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.testInputOutputTitleImageInsets.left)
            make.size.equalTo(self.appearance.testInputOutputTitleImageSize)
            make.centerY.equalTo(self.testInputTitleLabel.snp.centerY)
        }

        self.testInputTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.testInputTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.testInputTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(self.appearance.testInputOutputTitleInsets)
            make.leading
                .equalTo(self.testInputImageView.snp.trailing)
                .offset(self.appearance.testInputOutputTitleInsets.left)
            make.trailing
                .equalTo(self.samplesButton.snp.leading)
                .offset(-self.appearance.testInputOutputTitleInsets.right)
        }

        self.testInputTextView.translatesAutoresizingMaskIntoConstraints = false
        self.testInputTextView.snp.makeConstraints { make in
            make.top.equalTo(self.testInputTitleLabel.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }

        self.testOutputImageView.translatesAutoresizingMaskIntoConstraints = false
        self.testOutputImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.testInputOutputTitleImageInsets.left)
            make.size.equalTo(self.appearance.testInputOutputTitleImageSize)
            make.centerY.equalTo(self.testOutputTitleLabel.snp.centerY)
        }

        self.testOutputTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.testOutputTitleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(self.appearance.testInputOutputTitleInsets)
            make.leading
                .equalTo(self.testOutputImageView.snp.trailing)
                .offset(self.appearance.testInputOutputTitleInsets.left)
        }

        self.testOutputLabel.translatesAutoresizingMaskIntoConstraints = false
        self.testOutputLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.testOutputTitleLabel.snp.bottom)
                .offset(self.appearance.testInputOutputTextViewInsets.top)
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.testInputOutputTextViewInsets)
        }

        self.bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomControlsStackView.snp.makeConstraints { make in
            make.top
                .equalTo(self.testInputOutputScrollableStackView.snp.bottom)
                .offset(self.appearance.bottomControlsStackViewInsets.top)
            make.leading.bottom.trailing
                .equalTo(self.safeAreaLayoutGuide)
                .inset(self.appearance.bottomControlsStackViewInsets)
        }

        self.runCodeButton.translatesAutoresizingMaskIntoConstraints = false
        self.runCodeButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.runCodeButtonHeight)
        }
    }
}

// MARK: - CodeQuizFullscreenRunCodeView: UITextViewDelegate -

extension CodeQuizFullscreenRunCodeView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === self.testInputTextView {
            self.delegate?.codeQuizFullscreenRunCodeView(self, testInputDidChange: textView.text)
        }
    }
}
