import SnapKit
import UIKit

extension NewProfileSocialProfilesSkeletonView {
    struct Appearance {
        let itemHeight: CGFloat = 44
    }
}

final class NewProfileSocialProfilesSkeletonView: UIView {
    private static let socialProfilesViewsCount = 4

    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: CGFloat(Self.socialProfilesViewsCount) * self.appearance.itemHeight
        )
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

        for _ in 0..<Self.socialProfilesViewsCount {
            let view = NewProfileSocialProfilesSkeletonProfileView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.itemHeight)
            }

            self.stackView.addArrangedSubview(view)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewProfileSocialProfilesSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
