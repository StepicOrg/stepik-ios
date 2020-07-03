import SnapKit
import UIKit

extension NewProfileStreakNotificationsFooterView {
    struct Appearance {
        let textLabelFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let textLabelTextColor = UIColor.stepikSystemSecondaryText
        let textLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
}

final class NewProfileStreakNotificationsFooterView: UIView {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.textLabelTextColor
        label.font = self.appearance.textLabelFont
        label.numberOfLines = 0
        return label
    }()

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.textLabelInsets.top
                + self.textLabel.intrinsicContentSize.height
                + self.appearance.textLabelInsets.bottom
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
}

extension NewProfileStreakNotificationsFooterView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.textLabelInsets)
        }
    }
}
