import SnapKit
import UIKit

extension NewProfileSocialProfilesSkeletonProfileView {
    struct Appearance {
        let imageViewSizeWidthHeight: CGFloat = 32

        let textLabelCornerRadius: CGFloat = 5
        let textLabelHeight: CGFloat = 17
        let textLabelInsets = LayoutInsets(top: 0, left: 16, bottom: 0, right: 8)

        let accessoryViewCornerRadius: CGFloat = 5
        let accessoryViewSizeWidthHeight = 26
        let accessoryViewInsets = LayoutInsets(right: 20)
    }
}

final class NewProfileSocialProfilesSkeletonProfileView: UIView {
    let appearance: Appearance

    private lazy var imageView = UIView()
    private lazy var textLabelView = UIView()
    private lazy var accessoryView = UIView()

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

extension NewProfileSocialProfilesSkeletonProfileView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = self.appearance.imageViewSizeWidthHeight / 2

        self.textLabelView.clipsToBounds = true
        self.textLabelView.layer.cornerRadius = self.appearance.textLabelCornerRadius

        self.accessoryView.clipsToBounds = true
        self.accessoryView.layer.cornerRadius = self.appearance.accessoryViewCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabelView)
        self.addSubview(self.accessoryView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.imageViewSizeWidthHeight)
            make.height.equalTo(self.appearance.imageViewSizeWidthHeight)
        }

        self.textLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.textLabelView.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.textLabelInsets.left)
            make.centerY.equalToSuperview()
            make.trailing
                .equalTo(self.accessoryView.snp.leading)
                .offset(-self.appearance.textLabelInsets.right)
            make.height.equalTo(self.appearance.textLabelHeight)
        }

        self.accessoryView.translatesAutoresizingMaskIntoConstraints = false
        self.accessoryView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.accessoryViewInsets.right)
            make.width.equalTo(self.appearance.accessoryViewSizeWidthHeight)
            make.height.equalTo(self.appearance.accessoryViewSizeWidthHeight)
        }
    }
}
