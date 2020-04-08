import UIKit

extension DownloadsCellView {
    struct Appearance {
        let coverViewSize = CGSize(width: 80, height: 80)

        let titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let titleTextColor = UIColor.stepikPrimaryText
        let titleMaxLinesCount = 3
        let titleInsets = LayoutInsets(left: 8)

        let subtitleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let subtitleTextColor = UIColor.stepikSecondaryText
        let subtitleMaxLinesCount = 1
    }
}

final class DownloadsCellView: UIView {
    let appearance: Appearance

    private lazy var coverView = CourseWidgetCoverView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.numberOfLines = self.appearance.titleMaxLinesCount
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.subtitleTextColor
        label.font = self.appearance.subtitleFont
        label.numberOfLines = self.appearance.subtitleMaxLinesCount
        return label
    }()

    var coverImageURL: URL? {
        didSet {
            self.coverView.coverImageURL = self.coverImageURL
        }
    }

    var shouldShowAdaptiveMark: Bool = false {
        didSet {
            self.coverView.shouldShowAdaptiveMark = self.shouldShowAdaptiveMark
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var subtitle: String? {
        didSet {
            self.subtitleLabel.text = self.subtitle
        }
    }

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

extension DownloadsCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(self.appearance.coverViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(self.coverView.snp.trailing).offset(self.appearance.titleInsets.left)
        }

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.bottom.equalToSuperview()
        }
    }
}
