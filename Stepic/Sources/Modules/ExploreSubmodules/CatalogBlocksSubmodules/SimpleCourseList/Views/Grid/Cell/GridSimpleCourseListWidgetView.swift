import SnapKit
import UIKit

extension GridSimpleCourseListWidgetView {
    struct Appearance {
        let titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleLabelTextColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05)
        let titleLabelInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)

        let backgroundColor = UIColor.stepikOverlayViolet
    }
}

final class GridSimpleCourseListWidgetView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
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
}

extension GridSimpleCourseListWidgetView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
            make.centerY.equalToSuperview()
        }
    }
}
