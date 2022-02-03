import SnapKit
import UIKit

extension CourseInfoTabInfoAuthorsBlockView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 16
        var stackViewInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

final class CourseInfoTabInfoAuthorsBlockView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var onAuthorClick: ((User.IdType) -> Void)?

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: stackViewIntrinsicContentSize.height
        )
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

    func configure(authors: [CourseInfoTabInfoAuthorViewModel]) {
        defer {
            self.invalidateIntrinsicContentSize()
        }

        if !self.stackView.arrangedSubviews.isEmpty {
            self.stackView.removeAllArrangedSubviews()
        }

        if authors.isEmpty {
            return
        }

        for author in authors {
            let authorView = CourseInfoTabInfoAuthorView()
            authorView.avatarImageURL = author.avatarImageURL
            authorView.title = author.name
            authorView.tag = author.id
            authorView.addTarget(self, action: #selector(self.authorViewClicked(sender:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(authorView)
        }
    }

    @objc
    private func authorViewClicked(sender: CourseInfoTabInfoAuthorView) {
        self.onAuthorClick?(sender.tag)
    }
}

extension CourseInfoTabInfoAuthorsBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.stackViewInsets)
        }
    }
}
