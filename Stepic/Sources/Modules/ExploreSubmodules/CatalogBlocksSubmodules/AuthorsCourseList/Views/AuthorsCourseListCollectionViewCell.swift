import UIKit

extension AuthorsCourseListCollectionViewCell {
    enum Appearance {
        static let cornerRadius: CGFloat = 13.0
    }
}

final class AuthorsCourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView = AuthorsCourseListWidgetView()

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

    override var isHighlighted: Bool {
        didSet {
            self.widgetView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    func configure(viewModel: AuthorsCourseListWidgetViewModel) {
        self.widgetView.configure(viewModel: viewModel)
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
