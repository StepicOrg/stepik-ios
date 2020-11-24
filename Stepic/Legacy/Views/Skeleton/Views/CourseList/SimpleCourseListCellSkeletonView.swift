import SnapKit
import UIKit

extension SimpleCourseListCellSkeletonView {
    struct Appearance {
        let labelsCornerRadius: CGFloat = 5
        let titleHeight: CGFloat = 18
        let subtitleHeight: CGFloat = 18
    }
}

final class SimpleCourseListCellSkeletonView: UIView {
    let appearance: Appearance

    private lazy var titleLabelSkeleton = UIView()
    private lazy var subtitleLabelSkeleton = UIView()

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

extension SimpleCourseListCellSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.titleLabelSkeleton.clipsToBounds = true
        self.titleLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.subtitleLabelSkeleton.clipsToBounds = true
        self.subtitleLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.titleLabelSkeleton)
        self.addSubview(self.subtitleLabelSkeleton)
    }

    func makeConstraints() {
        self.titleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelSkeleton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(self.appearance.titleHeight)
            make.width.equalToSuperview().multipliedBy(0.7)
        }

        self.subtitleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabelSkeleton.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.subtitleHeight)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
    }
}
