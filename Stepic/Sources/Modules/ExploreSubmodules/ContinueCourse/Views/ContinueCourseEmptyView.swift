import SnapKit
import UIKit

extension ContinueCourseEmptyView {
    struct Appearance {
        let primaryColor: UIColor
        let defaultInsets = LayoutInsets.default

        let plusIconSize = CGSize(width: 20, height: 20)
        let plusContainerCornerRadius: CGFloat = 8
        let plusContainerSize = CGSize(width: 40, height: 40)
        var plusContainerBackgroundColor: UIColor {
            .dynamic(light: self.primaryColor.withAlphaComponent(0.12), dark: .stepikTertiaryBackground)
        }

        let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let titleInsets = LayoutInsets(left: 8)
    }
}

final class ContinueCourseEmptyView: UIControl {
    let appearance: Appearance

    private lazy var plusIconImageView: UIImageView = {
        let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.primaryColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var plusIconContainerView = UIView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.primaryColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 1
        label.text = NSLocalizedString("ContinueCourseEmptyTitle", comment: "")
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            self.plusIconImageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.titleLabel.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance) {
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

extension ContinueCourseEmptyView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.plusIconContainerView.backgroundColor = self.appearance.plusContainerBackgroundColor
        self.plusIconContainerView.roundAllCorners(radius: self.appearance.plusContainerCornerRadius)
    }

    func addSubviews() {
        self.addSubview(self.plusIconContainerView)
        self.plusIconContainerView.addSubview(self.plusIconImageView)

        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.plusIconContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.plusIconContainerView.snp.makeConstraints { make in
            make.leading
                .equalTo(self.safeAreaLayoutGuide.snp.leading)
                .offset(self.appearance.defaultInsets.left)
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.plusContainerSize)
        }

        self.plusIconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.plusIconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.plusIconSize)
            make.center.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading
                .equalTo(self.plusIconContainerView.snp.trailing)
                .offset(self.appearance.titleInsets.left)
            make.centerY.equalTo(self.plusIconContainerView.snp.centerY)
        }
    }
}
