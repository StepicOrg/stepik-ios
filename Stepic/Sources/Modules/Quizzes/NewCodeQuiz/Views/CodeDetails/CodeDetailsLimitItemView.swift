import SnapKit
import UIKit

extension CodeDetailsLimitItemView {
    struct Appearance {
        let insets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
        let verticalSpacing: CGFloat = 16

        let backgroundColor = UIColor(hex: 0xF6F6F6)
        let mainColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 16)
        let detailFont = UIFont.systemFont(ofSize: 14, weight: .light)
    }
}

final class CodeDetailsLimitItemView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.detailFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var subtitle: String? {
        didSet {
            self.subtitleLabel.text = self.subtitle
        }
    }

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

extension CodeDetailsLimitItemView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.verticalSpacing)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
