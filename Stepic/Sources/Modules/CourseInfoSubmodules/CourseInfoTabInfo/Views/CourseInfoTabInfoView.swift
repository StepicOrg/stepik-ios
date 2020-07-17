import Atributika
import SnapKit
import UIKit

protocol CourseInfoTabInfoViewDelegate: AnyObject {
    func courseInfoTabInfoView(_ view: CourseInfoTabInfoView, didOpenURL url: URL)
    func courseInfoTabInfoView(_ view: CourseInfoTabInfoView, didOpenUserProfileWithID userID: User.IdType)
}

extension CourseInfoTabInfoView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 0
        let stackViewInsets = LayoutInsets(top: 20)

        let authorTitleLabelFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let authorTitleLabelInsets = UIEdgeInsets(top: 0, left: 47, bottom: 20, right: 47)
        let authorTitleLabelNumberOfLines = 0
        let authorIconLeadingSpace: CGFloat = 20

        let loadingIndicatorTopInset: CGFloat = 20
    }
}

final class CourseInfoTabInfoView: UIView {
    weak var delegate: (CourseInfoTabInfoViewDelegate & CourseInfoTabInfoIntroVideoBlockViewDelegate)?

    let appearance: Appearance

    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(frame: .zero, orientation: .vertical)
        stackView.showsVerticalScrollIndicator = true
        stackView.showsHorizontalScrollIndicator = false
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .stepikGray)
        view.hidesWhenStopped = true
        return view
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        delegate: (CourseInfoTabInfoViewDelegate & CourseInfoTabInfoIntroVideoBlockViewDelegate)? = nil
    ) {
        self.appearance = appearance
        self.delegate = delegate
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public API

    func showLoading() {
        self.scrollableStackView.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func hideLoading() {
        self.scrollableStackView.isHidden = false
        self.loadingIndicator.stopAnimating()
    }

    func configure(viewModel: CourseInfoTabInfoViewModel) {
        if !self.scrollableStackView.arrangedSubviews.isEmpty {
            self.scrollableStackView.removeAllArrangedViews()
        }

        self.addAuthorView(authors: viewModel.authors)
        self.addIntroVideoView(
            introVideoURL: viewModel.introVideoURL,
            introVideoThumbnailURL: viewModel.introVideoThumbnailURL
        )

        self.addTextBlockView(block: .about, message: viewModel.aboutText)
        self.addTextBlockView(block: .requirements, message: viewModel.requirementsText)
        self.addTextBlockView(block: .targetAudience, message: viewModel.targetAudienceText)

        self.addInstructorsView(instructors: viewModel.instructors)

        self.addTextBlockView(block: .timeToComplete, message: viewModel.timeToCompleteText)
        self.addTextBlockView(block: .language, message: viewModel.languageText)

        self.addTextBlockView(block: .certificate, message: viewModel.certificateText)

        if let certificateDetailsText = viewModel.certificateDetailsText {
            self.addTextBlockView(block: .certificateDetails, message: certificateDetailsText)
        }

        // Redraw self cause geometry & sizes can be changed
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    // MARK: Private API

    private func addAuthorView(authors: [CourseInfoTabInfoAuthorViewModel]) {
        if authors.isEmpty {
            return
        }

        var formattedAuthorsString = authors.reduce(into: "") { result, author in
            result += "<a href=\"\(author.id)\">\(author.name)</a>, "
        }.trimmingCharacters(in: .whitespaces)
        formattedAuthorsString.removeLast()

        let attributedText = "\(Block.author.title) \(formattedAuthorsString)"
            .style(tags: [HTMLToAttributedStringConverter.defaultLinkStyle])

        let authorView = CourseInfoTabInfoHeaderBlockView(
            appearance: .init(
                imageViewLeadingSpace: self.appearance.authorIconLeadingSpace,
                titleLabelFont: self.appearance.authorTitleLabelFont,
                titleLabelInsets: self.appearance.authorTitleLabelInsets,
                titleLabelNumberOfLines: self.appearance.authorTitleLabelNumberOfLines
            )
        )
        authorView.icon = Block.author.icon
        authorView.attributedText = attributedText
        authorView.onTagClick = { [weak self] href in
            guard let strongSelf = self,
                  let userID = Int(href) else {
                return
            }

            strongSelf.delegate?.courseInfoTabInfoView(strongSelf, didOpenUserProfileWithID: userID)
        }

        self.scrollableStackView.addArrangedView(authorView)
    }

    private func addIntroVideoView(introVideoURL: URL?, introVideoThumbnailURL: URL?) {
        if let introVideoURL = introVideoURL {
            let introVideoBlockView = CourseInfoTabInfoIntroVideoBlockView(delegate: self.delegate)
            introVideoBlockView.thumbnailImageURL = introVideoThumbnailURL
            introVideoBlockView.videoURL = introVideoURL
            self.scrollableStackView.addArrangedView(introVideoBlockView)
        }
    }

    private func addTextBlockView(block: Block, message: String) {
        if message.isEmpty {
            return
        }

        let textBlockView = CourseInfoTabInfoTextBlockView()
        textBlockView.icon = block.icon
        textBlockView.title = block.title
        textBlockView.message = message
        textBlockView.onOpenURL = { [weak self] url in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoTabInfoView(strongSelf, didOpenURL: url)
        }

        self.scrollableStackView.addArrangedView(textBlockView)
    }

    private func addInstructorsView(instructors: [CourseInfoTabInfoInstructorViewModel]) {
        if instructors.isEmpty {
            return
        }

        let instructorsView = CourseInfoTabInfoInstructorsBlockView()
        instructorsView.configure(instructors: instructors)
        instructorsView.onInstructorClick = { [weak self] instructor in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoTabInfoView(strongSelf, didOpenUserProfileWithID: instructor.id)
        }

        self.scrollableStackView.addArrangedView(instructorsView)
    }
}

// MARK: - CourseInfoTabInfoView: ProgrammaticallyInitializableViewProtocol -

extension CourseInfoTabInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.stackViewInsets.top).priority(999)
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.loadingIndicatorTopInset)
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - CourseInfoTabInfoView: CourseInfoPageViewProtocol -

extension CourseInfoTabInfoView: CourseInfoScrollablePageViewProtocol {
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            self.scrollableStackView.scrollDelegate
        }
        set {
            self.scrollableStackView.scrollDelegate = newValue
        }
    }

    var contentInsets: UIEdgeInsets {
        get {
            self.scrollableStackView.contentInsets
        }
        set {
            self.loadingIndicator.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(newValue.top + self.appearance.loadingIndicatorTopInset)
            }

            // Fixes an issue with incorrect content offset on presentation when initial tab is `CourseInfo.Tab.info`.
            if newValue.top > 0 && self.contentOffset.y == 0 {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: -newValue.top)
            }

            self.scrollableStackView.contentInsets = newValue
        }
    }

    var contentOffset: CGPoint {
        get {
            self.scrollableStackView.contentOffset
        }
        set {
            self.scrollableStackView.contentOffset = newValue
        }
    }

    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        get {
            self.scrollableStackView.contentInsetAdjustmentBehavior
        }
        set {
            self.scrollableStackView.contentInsetAdjustmentBehavior = newValue
        }
    }
}

// MARK: - CourseInfoTabInfoView (Block) -

extension CourseInfoTabInfoView {
    enum Block {
        case author
        case introVideo
        case about
        case requirements
        case targetAudience
        case instructors
        case timeToComplete
        case language
        case certificate
        case certificateDetails

        var icon: UIImage? {
            switch self {
            case .author:
                return UIImage(named: "course-info-instructor")
            case .introVideo:
                return nil
            case .about:
                return UIImage(named: "course-info-about")
            case .requirements:
                return UIImage(named: "course-info-requirements")
            case .targetAudience:
                return UIImage(named: "course-info-target-audience")
            case .instructors:
                return UIImage(named: "course-info-instructor")
            case .timeToComplete:
                return UIImage(named: "course-info-time-to-complete")
            case .language:
                return UIImage(named: "course-info-language")
            case .certificate:
                return UIImage(named: "course-info-certificate")
            case .certificateDetails:
                return UIImage(named: "course-info-certificate-details")
            }
        }

        var title: String {
            switch self {
            case .author:
                return NSLocalizedString("CourseInfoTitleAuthor", comment: "")
            case .introVideo:
                return ""
            case .about:
                return NSLocalizedString("CourseInfoTitleAbout", comment: "")
            case .requirements:
                return NSLocalizedString("CourseInfoTitleRequirements", comment: "")
            case .targetAudience:
                return NSLocalizedString("CourseInfoTitleTargetAudience", comment: "")
            case .instructors:
                return NSLocalizedString("CourseInfoTitleInstructors", comment: "")
            case .timeToComplete:
                return NSLocalizedString("CourseInfoTitleTimeToComplete", comment: "")
            case .language:
                return NSLocalizedString("CourseInfoTitleLanguage", comment: "")
            case .certificate:
                return NSLocalizedString("CourseInfoTitleCertificate", comment: "")
            case .certificateDetails:
                return NSLocalizedString("CourseInfoTitleCertificateDetails", comment: "")
            }
        }
    }
}
