import UIKit

extension StepikAcademyCourseListCollectionViewCell {
    enum Appearance {
        static let backgroundColor = UIColor.dynamic(light: .white, dark: .stepikSecondaryBackground)
        static let cornerRadius: CGFloat = 8

        static let shadowColor = UIColor.black
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.08
    }
}

final class StepikAcademyCourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView = StepikAcademyCourseListWidgetView()

    override var isHighlighted: Bool {
        didSet {
            self.widgetView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()

        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.masksToBounds = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: StepikAcademyCourseListWidgetViewModel) {
        self.widgetView.configure(viewModel: viewModel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.backgroundColor = Appearance.backgroundColor
        self.contentView.layer.cornerRadius = Appearance.cornerRadius

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

extension StepikAcademyCourseListCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.widgetView)
    }

    func makeConstraints() {
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.widgetView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
