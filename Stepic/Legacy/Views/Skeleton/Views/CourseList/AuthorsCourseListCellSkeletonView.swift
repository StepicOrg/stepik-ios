import SnapKit
import UIKit

extension AuthorsCourseListCellSkeletonView {
    struct Appearance {
        let labelsCornerRadius: CGFloat = 5
        let coverImageCornerRadius: CGFloat = 8

        let coverImageSize = CGSize(width: 64, height: 64)
        let coverImageInsets = LayoutInsets(top: 16, left: 16)

        let titleHeight: CGFloat = 36
        let titleInsets = LayoutInsets(left: 16, right: 16)

        let ratingImageSize = CGSize(width: 16, height: 16)
        let ratingLabelHeight: CGFloat = 14
        let ratingInsets = LayoutInsets(top: 16, bottom: 16)
        let ratingSpacing: CGFloat = 8
    }
}

final class AuthorsCourseListCellSkeletonView: UIView {
    let appearance: Appearance

    private lazy var coverImageSkeleton = UIView()
    private lazy var titleLabelSkeleton = UIView()
    private lazy var ratingImageSkeleton = UIView()
    private lazy var ratingLabelSkeleton = UIView()

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

extension AuthorsCourseListCellSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.coverImageSkeleton.clipsToBounds = true
        self.coverImageSkeleton.layer.cornerRadius = self.appearance.coverImageCornerRadius

        self.titleLabelSkeleton.clipsToBounds = true
        self.titleLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.ratingImageSkeleton.clipsToBounds = true
        self.ratingImageSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.ratingLabelSkeleton.clipsToBounds = true
        self.ratingLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.coverImageSkeleton)
        self.addSubview(self.titleLabelSkeleton)
        self.addSubview(self.ratingImageSkeleton)
        self.addSubview(self.ratingLabelSkeleton)
    }

    func makeConstraints() {
        self.coverImageSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageSkeleton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.coverImageInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.coverImageInsets.left)
            make.width.equalTo(self.appearance.coverImageSize.width)
            make.height.equalTo(self.appearance.coverImageSize.height)
        }

        self.titleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelSkeleton.snp.makeConstraints { make in
            make.top.equalTo(self.coverImageSkeleton.snp.top)
            make.leading.equalTo(self.coverImageSkeleton.snp.trailing).offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
            make.height.equalTo(self.appearance.titleHeight)
        }

        self.ratingImageSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.ratingImageSkeleton.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabelSkeleton.snp.leading)
            make.bottom.equalToSuperview().offset(-self.appearance.ratingInsets.bottom)
            make.width.equalTo(self.appearance.ratingImageSize.width)
            make.height.equalTo(self.appearance.ratingImageSize.height)
        }

        self.ratingLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.ratingLabelSkeleton.snp.makeConstraints { make in
            make.leading.equalTo(self.ratingImageSkeleton.snp.trailing).offset(self.appearance.ratingSpacing)
            make.centerY.equalTo(self.ratingImageSkeleton.snp.centerY)
            make.height.equalTo(self.appearance.ratingLabelHeight)
            make.width.equalTo(self.titleLabelSkeleton.snp.width).multipliedBy(0.5)
        }
    }
}
