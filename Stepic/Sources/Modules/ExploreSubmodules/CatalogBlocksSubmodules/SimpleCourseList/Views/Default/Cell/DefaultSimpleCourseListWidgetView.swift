import SnapKit
import UIKit

extension DefaultSimpleCourseListWidgetView {
    struct Appearance {
        let titleLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let titleLabelInsets = LayoutInsets(top: 16, left: 16, right: 16)

        let subtitleLabelFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let subtitleLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
}

final class DefaultSimpleCourseListWidgetView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.numberOfLines = 3
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.numberOfLines = 1
        return label
    }()

    var titleLabelTextColor: UIColor? {
        didSet {
            self.titleLabel.textColor = self.titleLabelTextColor
        }
    }

    var subtitleLabelTextColor: UIColor? {
        didSet {
            self.subtitleLabel.textColor = self.subtitleLabelTextColor
        }
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

    func configure(viewModel: SimpleCourseListWidgetViewModel) {
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
    }
}

extension DefaultSimpleCourseListWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
        }
        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(self.appearance.subtitleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.subtitleLabelInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.subtitleLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.subtitleLabelInsets.right)
        }
        self.subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
