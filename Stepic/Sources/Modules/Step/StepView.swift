import SnapKit
import UIKit

protocol StepViewDelegate: AnyObject {
    func stepViewDidRequestVideo(_ view: StepView)
    func stepViewDidRequestPrevious(_ view: StepView)
    func stepViewDidRequestNext(_ view: StepView)
    func stepViewDidRequestDiscussions(_ view: StepView)
    func stepViewDidRequestSolutions(_ view: StepView)
    func stepViewDidLoadContent(_ view: StepView)

    func stepView(_ view: StepView, didRequestFullscreenImage url: URL)
    func stepView(_ view: StepView, didRequestFullscreenImage image: UIImage)
    func stepView(_ view: StepView, didRequestOpenURL url: URL)
    func stepView(_ view: StepView, didRequestOpenARQuickLook url: URL)
}

extension StepView {
    struct Appearance {
        let loadingIndicatorColor = UIColor.stepikLoadingIndicator
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.25
        static let appearanceAnimationDelay: TimeInterval = 0.3
    }
}

final class StepView: UIView {
    let appearance: Appearance
    weak var delegate: StepViewDelegate?

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikWhiteLarge)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(orientation: .vertical)
        if #available(iOS 13.0, *) {
            view.automaticallyAdjustsScrollIndicatorInsets = false
        }
        return view
    }()

    private lazy var stepTextView: ProcessedContentWebView = {
        let view = ProcessedContentWebView()
        view.delegate = self
        return view
    }()

    private lazy var stepVideoPreviewView: StepVideoPreviewView = {
        let view = StepVideoPreviewView()
        view.onPlayClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestVideo(strongSelf)
        }
        return view
    }()

    // Container to place preview view on center
    private lazy var stepVideoPreviewContainerView = UIView()

    private lazy var stepControlsView: StepControlsView = {
        let view = StepControlsView()
        view.onPreviousButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestPrevious(strongSelf)
        }
        view.onNextButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestNext(strongSelf)
        }
        view.onDiscussionsButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestDiscussions(strongSelf)
        }
        view.onSolutionsButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestSolutions(strongSelf)
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

    func configure(viewModel: StepViewModel, quizView: UIView?) {
        switch viewModel.content {
        case .video(let viewModel):
            self.scrollableStackView.insertArrangedView(self.stepVideoPreviewContainerView, at: 0)
            self.stepVideoPreviewView.thumbnailImageURL = viewModel?.videoThumbnailImageURL
            self.delegate?.stepViewDidLoadContent(self)
        case .text(let htmlString):
            self.scrollableStackView.insertArrangedView(self.stepTextView, at: 0)
            self.stepTextView.loadHTMLText(htmlString)
        }

        self.stepControlsView.passedByCount = viewModel.passedByCount
        self.stepControlsView.correctRatio = viewModel.correctRatio

        self.updateDiscussionButton(title: viewModel.discussionsLabelTitle, isEnabled: viewModel.isDiscussionsEnabled)

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

    func updateText(_ htmlText: String) {
        if self.stepTextView.superview != nil {
            self.stepTextView.clearContent()
            self.stepTextView.loadHTMLText(htmlText)
        }
    }

    func updateDiscussionButton(title: String, isEnabled: Bool) {
        self.stepControlsView.discussionsTitle = title
        self.stepControlsView.isDiscussionsButtonEnabled = isEnabled
    }

    func updateSolutionsButton(title: String?, isEnabled: Bool) {
        self.stepControlsView.solutionsTitle = title
        self.stepControlsView.isSolutionsButtonEnabled = isEnabled
    }

    // MARK: Private API

    private func positionVideoPreview() {
        let fullHeight = self.bounds.height
        let previewHeight = self.stepVideoPreviewView.bounds.height
        let topInset = self.safeAreaInsets.top
        let bottomInset = self.safeAreaInsets.bottom

        let controlsRealHeight = self.stepControlsView.bounds.height
        let controlsHeight = self.stepControlsView.sizeWithAllControls.height
        let controlsDiffHeight = max(0, controlsHeight - controlsRealHeight)

        self.scrollableStackView.isScrollEnabled = previewHeight + controlsHeight + bottomInset + topInset >= fullHeight

        let previewContainerHeight = CGFloat(
            max(0, Int(fullHeight - topInset - previewHeight - controlsHeight - bottomInset))
        )
        self.stepVideoPreviewView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(previewContainerHeight * 0.5)
            make.bottom.equalToSuperview().offset(-previewContainerHeight * 0.5 - controlsDiffHeight)
        }
    }
}

extension StepView: ProgrammaticallyInitializableViewProtocol {
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
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }

        self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension StepView: ProcessedContentWebViewDelegate {
    func processedContentTextView(_ view: ProcessedContentWebView, didOpenLink url: URL) {
        self.delegate?.stepView(self, didRequestOpenURL: url)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenARKitLink url: URL) {
        self.delegate?.stepView(self, didRequestOpenARQuickLook: url)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenImageURL url: URL) {
        self.delegate?.stepView(self, didRequestFullscreenImage: url)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenNativeImage image: UIImage) {
        self.delegate?.stepView(self, didRequestFullscreenImage: image)
    }

    func processedContentTextViewDidLoadContent(_ view: ProcessedContentWebView) {
        self.delegate?.stepViewDidLoadContent(self)
    }
}
