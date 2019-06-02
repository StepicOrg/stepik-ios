import SnapKit
import UIKit

protocol NewStepViewDelegate: class {
    func newStepViewDidRequestVideo(_ view: NewStepView)
    func newStepViewDidRequestPrevious(_ view: NewStepView)
    func newStepViewDidRequestNext(_ view: NewStepView)
    func newStepViewDidRequestComments(_ view: NewStepView)
    func newStepViewDidLoadContent(_ view: NewStepView)

    func newStepView(_ view: NewStepView, didRequestFullscreenImage url: URL)
    func newStepView(_ view: NewStepView, didRequestOpenURL url: URL)
}

extension NewStepView {
    struct Appearance {
        let loadingIndicatorColor = UIColor.mainDark
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.25
        static let appearanceAnimationDelay: TimeInterval = 0.3
    }
}

final class NewStepView: UIView {
    let appearance: Appearance
    weak var delegate: NewStepViewDelegate?

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(orientation: .vertical)
        return view
    }()

    private lazy var stepTextView: ProcessedContentTextView = {
        let view = ProcessedContentTextView()
        view.delegate = self
        return view
    }()

    private lazy var stepVideoPreviewView: StepVideoPreviewView = {
        let view = StepVideoPreviewView()
        view.onPlayClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.newStepViewDidRequestVideo(strongSelf)
        }
        return view
    }()

    // Container to place preview view on center
    private lazy var stepVideoPreviewContainerView = UIView()

    private lazy var stepControlsView: StepControlsView = {
        let view = StepControlsView()
        view.onPreviousButtonClick = {
            self.delegate?.newStepViewDidRequestPrevious(self)
        }
        view.onNextButtonClick = {
            self.delegate?.newStepViewDidRequestNext(self)
        }
        view.onCommentsButtonClick = {
            self.delegate?.newStepViewDidRequestComments(self)
        }
        return view
    }()

    private lazy var quizContainerView = UIView()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.stepVideoPreviewContainerView.superview != nil {
            self.positionVideoPreview()
        }
    }

    // MARK: Public API

    func startLoading() {
        self.scrollableStackView.alpha = 0.0
        self.loadingIndicatorView.startAnimating()
    }

    func endLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.appearanceAnimationDelay) {
            self.loadingIndicatorView.stopAnimating()

            UIView.animate(
                withDuration: Animation.appearanceAnimationDuration,
                animations: {
                    self.scrollableStackView.alpha = 1.0
                }
            )
        }
    }

    func configure(viewModel: NewStepViewModel, quizView: UIView?) {
        switch viewModel.content {
        case .video(let viewModel):
            self.scrollableStackView.insertArrangedView(self.stepVideoPreviewContainerView, at: 0)
            self.stepVideoPreviewView.thumbnailImageURL = viewModel?.videoThumbnailImageURL
            self.delegate?.newStepViewDidLoadContent(self)
        case .text(let htmlString):
            self.scrollableStackView.insertArrangedView(self.stepTextView, at: 0)
            self.stepTextView.loadHTMLText(htmlString)
        }

        self.stepControlsView.isCommentsButtonHidden = viewModel.discussionProxyID == nil
        self.stepControlsView.commentsTitle = viewModel.commentsLabelTitle

        guard let quizView = quizView else {
            return
        }

        self.quizContainerView.addSubview(quizView)
        quizView.translatesAutoresizingMaskIntoConstraints = false
        quizView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateNavigationButtons(hasPreviousButton: Bool, hasNextButton: Bool) {
        switch (hasPreviousButton, hasNextButton) {
        case (true, true):
            self.stepControlsView.navigationState = .both
        case (true, _):
            self.stepControlsView.navigationState = .previous
        case (_, true):
            self.stepControlsView.navigationState = .next
        default:
            self.stepControlsView.navigationState = nil
        }
    }

    // MARK: Private API

    private func positionVideoPreview() {
        let fullHeight = self.bounds.height
        let previewHeight = self.stepVideoPreviewView.bounds.height
        let topInset = self.scrollableStackView.contentInsets.top
        let bottomInset = self.scrollableStackView.contentInsets.bottom

        let controlsRealHeight = self.stepControlsView.bounds.height
        let controlsHeight = self.stepControlsView.sizeWithAllControls.height
        let controlsDiffHeight = max(0, controlsHeight - controlsRealHeight)

        self.scrollableStackView.isScrollEnabled = previewHeight + controlsHeight + bottomInset + topInset >= fullHeight

        let previewContainerHeight = max(0, fullHeight - topInset - previewHeight - controlsHeight - bottomInset)
        self.stepVideoPreviewView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(previewContainerHeight * 0.5)
            make.bottom.equalToSuperview().offset(-previewContainerHeight * 0.5 - controlsDiffHeight)
        }
    }
}

extension NewStepView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.stepVideoPreviewContainerView.addSubview(self.stepVideoPreviewView)

        self.addSubview(self.scrollableStackView)
        self.scrollableStackView.addArrangedView(self.quizContainerView)
        self.scrollableStackView.addArrangedView(self.stepControlsView)

        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.stepVideoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        self.stepVideoPreviewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension NewStepView: ProcessedContentTextViewDelegate {
    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) {
        self.delegate?.newStepView(self, didRequestOpenURL: url)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) {
        self.delegate?.newStepView(self, didRequestFullscreenImage: url)
    }

    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        self.delegate?.newStepViewDidLoadContent(self)
    }
}
