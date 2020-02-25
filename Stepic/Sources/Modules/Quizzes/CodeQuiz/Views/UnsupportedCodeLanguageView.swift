import SnapKit
import UIKit

extension UnsupportedCodeLanguageView {
    struct Appearance {
        let height: CGFloat = 236
        let textFont = UIFont.systemFont(ofSize: 16)
        let textColor = UIColor.lightGray
    }
}

final class UnsupportedCodeLanguageView: UIView {
    let appearance: Appearance

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("NotSupportedLanguage", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = self.appearance.textFont
        label.textColor = self.appearance.textColor
        return label
    }()

    private lazy var containerView = UIView()

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
}

extension UnsupportedCodeLanguageView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.messageLabel)
    }

    func makeConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.appearance.height)
        }

        self.messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
