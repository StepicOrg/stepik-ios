import SnapKit
import UIKit

extension NewProfileCertificatesCertificateWidgetProgressView {
    struct Appearance {
        let textLabelFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let progressViewHeight: CGFloat = 3.0
        let progressViewBackgroundColor = UIColor.clear
        let progressViewInsets = LayoutInsets(top: 2)

        let regularAccentColor = UIColor.stepikGreen
        let distinctionAccentColor = UIColor.stepikOrange
    }
}

final class NewProfileCertificatesCertificateWidgetProgressView: UIView {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.numberOfLines = 1
        return label
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = self.appearance.progressViewBackgroundColor
        view.progress = 0
        return view
    }()

    var certificateType: CertificateType = .regular {
        didSet {
            self.updateViewColor()
        }
    }

    var progress: Int = 0 {
        didSet {
            self.updateProgress()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.textLabel.intrinsicContentSize.height
                + self.appearance.progressViewInsets.top
                + self.appearance.progressViewHeight
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateViewColor() {
        let accentColor: UIColor = {
            switch self.certificateType {
            case .distinction:
                return self.appearance.distinctionAccentColor
            case .regular:
                return self.appearance.regularAccentColor
            }
        }()

        self.textLabel.textColor = accentColor
        self.progressView.progressTintColor = accentColor
    }

    private func updateProgress() {
        self.textLabel.text = "\(self.progress)%"
        self.progressView.progress = Float(self.progress) / 100
    }
}

extension NewProfileCertificatesCertificateWidgetProgressView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.textLabel)
        self.addSubview(self.progressView)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }

        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.snp.makeConstraints { make in
            make.top.equalTo(self.textLabel.snp.bottom).offset(self.appearance.progressViewInsets.top)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.progressViewHeight)
        }
    }
}
