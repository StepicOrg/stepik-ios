import SnapKit
import UIKit

extension CodeDetailsContentView {
    struct Appearance {
        let spacing: CGFloat = 1
    }
}

final class CodeDetailsContentView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    func configure(samples: [NewCodeQuiz.CodeSample], limit: NewCodeQuiz.CodeLimit) {
        if !self.stackView.arrangedSubviews.isEmpty {
            self.stackView.removeAllArrangedSubviews()
        }

        self.makeCodeSampleViews(samples).forEach { self.stackView.addArrangedSubview($0) }
        self.makeCodeLimitViews(limit).forEach { self.stackView.addArrangedSubview($0) }
    }

    // MARK: - Private API

    private func makeCodeSampleViews(_ samples: [NewCodeQuiz.CodeSample]) -> [UIView] {
        func getTitle(at index: Int) -> String {
            return samples.count == 1
                ? NSLocalizedString("CodeQuizDetailSampleTitleOne", comment: "")
                : String(format: NSLocalizedString("CodeQuizDetailSampleTitle", comment: ""), "\(index + 1)")
        }

        return samples.enumerated().map { arg in
            let (index, sample) = arg
            let sampleItemView = CodeDetailsSampleItemView()
            sampleItemView.title = getTitle(at: index)
            sampleItemView.inputText = sample.input
            sampleItemView.outputText = sample.output
            return sampleItemView
        }
    }

    private func makeCodeLimitViews(_ limit: NewCodeQuiz.CodeLimit) -> [UIView] {
        let timeLimitView = CodeDetailsLimitItemView()
        timeLimitView.title = NSLocalizedString("CodeQuizDetailLimitTitleTime", comment: "")
        timeLimitView.subtitle = FormatterHelper.seconds(limit.time)

        let memoryLimitView = CodeDetailsLimitItemView()
        memoryLimitView.title = NSLocalizedString("CodeQuizDetailLimitTitleMemory", comment: "")
        memoryLimitView.subtitle = String(
            format: NSLocalizedString("CodeQuizDetailLimitValueMemory", comment: ""),
            "\(Int(limit.memory))"
        )

        return [timeLimitView, memoryLimitView]
    }
}

extension CodeDetailsContentView: ProgrammaticallyInitializableViewProtocol {
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
