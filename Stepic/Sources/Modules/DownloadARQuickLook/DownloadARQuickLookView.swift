import SnapKit
import UIKit

protocol DownloadARQuickLookViewDelegate: AnyObject {
    func downloadARQuickLookViewDidCancel(_ view: DownloadARQuickLookView)
}

extension DownloadARQuickLookView {
    struct Appearance {
        let backgroundColor = UIColor.dynamic(light: .stepikBackground, dark: .stepikSecondaryBackground)
        let width: CGFloat = 270

        let titleLabelInsets = LayoutInsets(top: 16, left: 16, right: 16)
        let titleLabelTextColor = UIColor.stepikSystemPrimaryText
        let titleLabelFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let messageLabelInsets = LayoutInsets(top: 2)
        let messageLabelTextColor = UIColor.stepikSystemPrimaryText
        let messageLabelFont = UIFont.systemFont(ofSize: 14, weight: .regular)

        let progressViewInsets = LayoutInsets(top: 16)
        let cancelButtonHeight: CGFloat = 44
        let cancelButtonFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let separatorInsets = LayoutInsets(top: 16)
        let separatorHeight: CGFloat = 0.5
        let separatorColor = UIColor.stepikSeparator
    }
}

final class DownloadARQuickLookView: UIView {
    let appearance: Appearance

    weak var delegate: DownloadARQuickLookViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleLabelTextColor
        label.font = self.appearance.titleLabelFont
        label.textAlignment = .center

        label.text = "Downloading"

        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.messageLabelTextColor
        label.font = self.appearance.messageLabelFont
        label.textAlignment = .center
        return label
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .default
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = self.appearance.cancelButtonFont
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.didClickCancel), for: .touchUpInside)
        return button
    }()

    private lazy var contentView = UIView()

    var progress: Float = 0 {
        didSet {
            self.progressView.setProgress(self.progress, animated: true)
            self.messageLabel.text = FormatterHelper.integerPercent(self.progress)
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

    @objc
    private func didClickCancel() {
        self.delegate?.downloadARQuickLookViewDidCancel(self)
    }
}

extension DownloadARQuickLookView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.progress = 0
    }

    func addSubviews() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.progressView)
        self.contentView.addSubview(self.separatorView)
        self.contentView.addSubview(self.cancelButton)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.greaterThanOrEqualTo(self.appearance.width)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
            make.centerX.equalToSuperview()
        }

        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.messageLabelInsets.top)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
        }

        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.snp.makeConstraints { make in
            make.top
                .equalTo(self.messageLabel.snp.bottom)
                .offset(self.appearance.progressViewInsets.top)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top
                .equalTo(self.progressView.snp.bottom)
                .offset(self.appearance.separatorInsets.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.cancelButtonHeight)
            make.centerX.equalToSuperview()
        }
    }
}
