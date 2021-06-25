import SnapKit
import UIKit

extension CourseBenefitDetailItemSeparatorView {
    struct Appearance {
        let separatorHeight: CGFloat = 0.5
        let separatorColor = UIColor.stepikSeparator
        let separatorInsets = LayoutInsets(left: 16, right: 16)
    }
}

final class CourseBenefitDetailItemSeparatorView: UIView {
    let appearance: Appearance

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: self.appearance.separatorHeight)
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

extension CourseBenefitDetailItemSeparatorView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(self.appearance.separatorInsets.edgeInsets)
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
