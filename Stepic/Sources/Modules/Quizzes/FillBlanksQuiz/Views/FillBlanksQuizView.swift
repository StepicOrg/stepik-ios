import SnapKit
import UIKit

extension FillBlanksQuizView {
    struct Appearance {
        let spacing: CGFloat = 16
        let insets = LayoutInsets(left: 16, right: 16)

        let titleColor = UIColor.stepikPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
}

final class FillBlanksQuizView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("FillBlanksQuizTitle", comment: "")
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 1
        return label
    }()

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
}

extension FillBlanksQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }
    }
}
