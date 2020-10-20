import SnapKit
import UIKit

extension TableQuizView {
    struct Appearance {
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        let titleTextColor = UIColor.stepikPrimaryText
    }
}

final class TableQuizView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
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

extension TableQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {}

    func makeConstraints() {}
}
