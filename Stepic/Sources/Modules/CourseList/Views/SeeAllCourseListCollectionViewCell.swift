import UIKit

extension SeeAllCourseListCollectionViewCell {
    enum Appearance {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 13
        static let borderColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
    }
}

final class SeeAllCourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView = SeeAllCourseWidgetView(appearance: .init(tintColor: Appearance.borderColor))

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            self.widgetView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.borderWidth = Appearance.borderWidth
        self.layer.borderColor = Appearance.borderColor.cgColor
        self.layer.masksToBounds = true
    }
}

extension SeeAllCourseListCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.widgetView)
    }

    func makeConstraints() {
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.widgetView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
