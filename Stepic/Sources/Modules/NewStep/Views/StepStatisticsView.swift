import SnapKit
import UIKit

extension StepStatisticsView {
    struct Appearance {
        let insets = LayoutInsets(top: 8, left: 16, bottom: 8, right: 16)
        let labelsSpacing: CGFloat = 8

        let separatorColor = UIColor(hex: 0xEAECF0)
        let separatorHeight: CGFloat = 1

        let textColor = UIColor.mainDark
        let textFont = UIFont.systemFont(ofSize: 14)
        let textFontDetail = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
}

final class StepStatisticsView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.passedByLabel, self.correctRatioLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = self.appearance.labelsSpacing
        return stackView
    }()

    private lazy var passedByLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    private lazy var correctRatioLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
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

    var isTopSeparatorVisible: Bool = true {
        didSet {
            self.topSeparatorView.isHidden = !self.isTopSeparatorVisible
        }
    }

    var isBottomSeparatorVisible: Bool = true {
        didSet {
            self.bottomSeparatorView.isHidden = !self.isBottomSeparatorVisible
        }
    }

    var passedByCount: Int? {
        didSet {
            self.updatePassedByText()
        }
    }

    var correctRatio: Float? {
        didSet {
            self.updateCorrectRatioText()
        }
    }

    private func updatePassedByText() {
        if let passedByCount = self.passedByCount {
            let attributedPassedByString = NSMutableAttributedString(
                string: NSLocalizedString("StepStatisticsPassedByTitle", comment: ""),
                attributes: [
                    .font: self.appearance.textFont,
                    .foregroundColor: self.appearance.textColor
                ]
            )
            attributedPassedByString.append(
                NSAttributedString(
                    string: " \(passedByCount)",
                    attributes: [
                        .font: self.appearance.textFontDetail,
                        .foregroundColor: self.appearance.textColor
                    ]
                )
            )

            self.passedByLabel.isHidden = false
            self.passedByLabel.attributedText = attributedPassedByString
        } else {
            self.passedByLabel.isHidden = true
            self.passedByLabel.attributedText = nil
        }
    }

    private func updateCorrectRatioText() {
        if let correctRatio = self.correctRatio {
            let attributedCorrectRatioString = NSMutableAttributedString(
                string: NSLocalizedString("StepStatisticsCorrectRatioTitle", comment: ""),
                attributes: [
                    .font: self.appearance.textFont,
                    .foregroundColor: self.appearance.textColor
                ]
            )
            attributedCorrectRatioString.append(
                NSAttributedString(
                    string: " \(FormatterHelper.integerPercent(correctRatio))",
                    attributes: [
                        .font: self.appearance.textFontDetail,
                        .foregroundColor: self.appearance.textColor
                    ]
                )
            )

            self.correctRatioLabel.isHidden = false
            self.correctRatioLabel.attributedText = attributedCorrectRatioString
        } else {
            self.correctRatioLabel.isHidden = true
            self.correctRatioLabel.attributedText = nil
        }
    }
}

extension StepStatisticsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.topSeparatorView)
        self.addSubview(self.bottomSeparatorView)
    }

    func makeConstraints() {
        self.topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.topSeparatorView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight / UIScreen.main.scale)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.top.equalToSuperview().offset(self.appearance.insets.top).priority(999)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom).priority(999)
            make.centerY.equalToSuperview()
        }

        self.bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomSeparatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight / UIScreen.main.scale)
        }
    }
}
