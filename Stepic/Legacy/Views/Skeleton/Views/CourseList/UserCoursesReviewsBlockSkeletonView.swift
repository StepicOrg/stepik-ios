import SnapKit
import UIKit

extension UserCoursesReviewsBlockSkeletonView {
    struct Appearance {
        let cornerRadius: CGFloat = 4
    }
}

final class UserCoursesReviewsBlockSkeletonView: UIView {
    let appearance: Appearance

    private lazy var titleLabelSkeleton = UIView()

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

extension UserCoursesReviewsBlockSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.titleLabelSkeleton.clipsToBounds = true
        self.titleLabelSkeleton.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.titleLabelSkeleton)
    }

    func makeConstraints() {
        self.titleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelSkeleton.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
