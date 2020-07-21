import SnapKit
import UIKit

extension NewProfileCertificatesCellSkeletonView {
    struct Appearance {
        let courseCoverViewWidthHeight: CGFloat = 24

        let courseCoverViewCornerRadius: CGFloat = 4
        let labelsCornerRadius: CGFloat = 5
        let courseProgressViewCornerRadius: CGFloat = 4

        let courseCoverTitleHeight: CGFloat = 17
        let courseCoverTitleInsets = LayoutInsets(left: 4, right: 16)

        let courseTitleLabelInsets = LayoutInsets(top: 8, bottom: 16)
        let courseTitleLabelHeight: CGFloat = 40

        let progressViewHeight: CGFloat = 20
        let progressViewInsets = LayoutInsets(top: 8)
    }
}

final class NewProfileCertificatesCellSkeletonView: UIView {
    let appearance: Appearance

    private lazy var courseCoverImageViewSkeleton = UIView()
    private lazy var courseCoverTitleLabelSkeleton = UIView()
    private lazy var courseTitleLabelSkeleton = UIView()
    private lazy var courseProgressViewSkeleton = UIView()

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

extension NewProfileCertificatesCellSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.courseCoverImageViewSkeleton.clipsToBounds = true
        self.courseCoverImageViewSkeleton.layer.cornerRadius = self.appearance.courseCoverViewCornerRadius

        self.courseCoverTitleLabelSkeleton.clipsToBounds = true
        self.courseCoverTitleLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.courseTitleLabelSkeleton.clipsToBounds = true
        self.courseTitleLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.courseProgressViewSkeleton.clipsToBounds = true
        self.courseProgressViewSkeleton.layer.cornerRadius = self.appearance.courseProgressViewCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.courseCoverImageViewSkeleton)
        self.addSubview(self.courseCoverTitleLabelSkeleton)
        self.addSubview(self.courseTitleLabelSkeleton)
        self.addSubview(self.courseProgressViewSkeleton)
    }

    func makeConstraints() {
        self.courseCoverImageViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.courseCoverImageViewSkeleton.snp.makeConstraints { make in
            make.height.width.equalTo(self.appearance.courseCoverViewWidthHeight)
            make.top.leading.equalToSuperview()
        }

        self.courseCoverTitleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.courseCoverTitleLabelSkeleton.snp.makeConstraints { make in
            make.leading
                .equalTo(self.courseCoverImageViewSkeleton.snp.trailing)
                .offset(self.appearance.courseCoverTitleInsets.left)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.courseCoverImageViewSkeleton.snp.centerY)
            make.height.equalTo(self.appearance.courseCoverTitleHeight)
        }

        self.courseTitleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.courseTitleLabelSkeleton.snp.makeConstraints { make in
            make.top
                .equalTo(self.courseCoverImageViewSkeleton.snp.bottom)
                .offset(self.appearance.courseTitleLabelInsets.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.courseTitleLabelHeight)
        }

        self.courseProgressViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.courseProgressViewSkeleton.snp.makeConstraints { make in
            make.top
                .equalTo(self.courseTitleLabelSkeleton.snp.bottom)
                .offset(self.appearance.progressViewInsets.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.progressViewHeight)
        }
    }
}
