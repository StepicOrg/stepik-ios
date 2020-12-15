import UIKit

extension GridSimpleCourseListCollectionViewCell {
    enum Appearance {
        static let cornerRadius: CGFloat = 13.0
    }
}

final class GridSimpleCourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private static var prototypeTextLabel: UILabel?

    private lazy var widgetView = GridSimpleCourseListWidgetView()

    override var isHighlighted: Bool {
        didSet {
            self.widgetView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Self.prototypeTextLabel = nil
    }

    func configure(viewModel: SimpleCourseListWidgetViewModel) {
        self.widgetView.title = viewModel.title
    }

    static func calculatePreferredContentSize(text: String, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        if Self.prototypeTextLabel == nil {
            Self.prototypeTextLabel = Self.makePrototypeTextLabel()
        }

        guard let label = Self.prototypeTextLabel else {
            return .zero
        }

        label.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)

        label.text = text
        label.sizeToFit()

        var size = label.bounds.size
        size.width = (size.width).rounded(.up)
        size.height = size.height.rounded(.up)

        return size
    }

    private static func makePrototypeTextLabel(
        appearance: GridSimpleCourseListWidgetView.Appearance = GridSimpleCourseListWidgetView.Appearance()
    ) -> UILabel {
        let label = UILabel()
        label.font = appearance.titleLabelFont
        label.numberOfLines = 1
        return label
    }
}

extension GridSimpleCourseListCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.masksToBounds = true
    }

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
