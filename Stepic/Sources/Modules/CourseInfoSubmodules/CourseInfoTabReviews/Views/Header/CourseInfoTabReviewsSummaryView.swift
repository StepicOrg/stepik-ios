import SnapKit
import UIKit

extension CourseInfoTabReviewsSummaryView {
    struct Appearance {}
}

final class CourseInfoTabReviewsSummaryView: UIView {
    let appearance: Appearance

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

    func configure(viewModel: CourseInfoTabReviewsSummaryViewModel) {
        print(viewModel)
    }
}

extension CourseInfoTabReviewsSummaryView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {}

    func makeConstraints() {}
}
