import UIKit

extension AuthorsCourseListCollectionViewCell {
    enum Appearance {
        static let backgroundColor = UIColor.stepikTertiaryBackground
        static let cornerRadius: CGFloat = 13.0

        static let shadowColor = UIColor.black
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let shadowRadius: CGFloat = 4.0
        static let shadowOpacity: Float = 0.1
    }
}

final class AuthorsCourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView = AuthorsCourseListWidgetView()

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

    func configure(viewModel: AuthorsCourseListWidgetViewModel) {
        self.widgetView.configure(viewModel: viewModel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.backgroundColor = Appearance.backgroundColor
        self.contentView.layer.cornerRadius = Appearance.cornerRadius
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = Appearance.shadowColor.cgColor
        self.layer.shadowOffset = Appearance.shadowOffset
        self.layer.shadowRadius = Appearance.shadowRadius
        self.layer.shadowOpacity = Appearance.shadowOpacity
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.contentView.layer.cornerRadius
        ).cgPath
    }
}

extension AuthorsCourseListCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.widgetView)
    }

    func makeConstraints() {
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.widgetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
