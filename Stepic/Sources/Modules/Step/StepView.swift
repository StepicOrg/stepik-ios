import SnapKit
import UIKit

protocol StepViewDelegate: AnyObject {
    func stepViewDidRequestVideo(_ view: StepView)
    func stepViewDidRequestPreviousUnit(_ view: StepView)
    func stepViewDidRequestNextUnit(_ view: StepView)
    func stepViewDidRequestNextStep(_ view: StepView)
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
        let stepTextViewInsets = LayoutInsets(top: 16, left: 16, bottom: 4, right: 16)
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

    private lazy var stepTextView: ProcessedContentView = {
        var appearance = ProcessedContentView.Appearance()
        appearance.insets = self.appearance.stepTextViewInsets
        appearance.activityIndicatorViewColor = self.appearance.loadingIndicatorColor

        let processedContentView = ProcessedContentView(appearance: appearance)
        processedContentView.delegate = self

        return processedContentView
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
        view.onNextStepButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestNextStep(strongSelf)
        }
        view.onPreviousUnitButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestPreviousUnit(strongSelf)
        }
        view.onNextUnitButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestNextUnit(strongSelf)
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

    private lazy var stepDisabledView: StepDisabledView = {
        let view = StepDisabledView()
        view.onNextStepButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestNextStep(strongSelf)
        }
        view.onPreviousUnitButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestPreviousUnit(strongSelf)
        }
        view.onNextUnitButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.stepViewDidRequestNextUnit(strongSelf)
        }
        return view
    }()

    private var canNavigateToNextStep: Bool = false {
        didSet {
            if oldValue == true && !self.canNavigateToNextStep {
                self.stepControlsView.hasNextStepButton = false
            }
        }
    }

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
        case .text(let processedContent):
            self.scrollableStackView.insertArrangedView(self.stepTextView, at: 0)
            self.stepTextView.processedContent = processedContent
        }

        self.stepControlsView.hasNextStepButton = quizView == nil && self.canNavigateToNextStep

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

    func clear() {
        self.scrollableStackView.removeArrangedView(self.stepVideoPreviewContainerView)
        self.scrollableStackView.removeArrangedView(self.stepTextView)

        self.quizContainerView.subviews.forEach { $0.removeFromSuperview() }
    }

    func updateNavigationButtons(
        canNavigateToPreviousUnit: Bool,
        canNavigateToNextUnit: Bool,
        canNavigateToNextStep: Bool
    ) {
        switch (canNavigateToPreviousUnit, canNavigateToNextUnit) {
        case (true, true):
            self.stepControlsView.unitNavigationState = .both
            self.stepDisabledView.unitNavigationState = .both
        case (true, _):
            self.stepControlsView.unitNavigationState = .previous
            self.stepDisabledView.unitNavigationState = .previous
        case (_, true):
            self.stepControlsView.unitNavigationState = .next
            self.stepDisabledView.unitNavigationState = .next
        default:
            self.stepControlsView.unitNavigationState = nil
            self.stepDisabledView.unitNavigationState = nil
        }

        self.canNavigateToNextStep = canNavigateToNextStep
        self.stepDisabledView.hasNextStepButton = canNavigateToNextStep
    }

    func updateTextContent(_ processedContent: ProcessedContent) {
        if self.stepTextView.superview != nil {
            self.stepTextView.processedContent = processedContent
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

    func showDisabledView() {
        if self.stepDisabledView.superview == nil {
            self.insertSubview(self.stepDisabledView, at: Int.max)
            self.stepDisabledView.translatesAutoresizingMaskIntoConstraints = false
            self.stepDisabledView.snp.makeConstraints { make in
                make.edges.equalTo(self.safeAreaLayoutGuide)
            }
        }

        self.setStepDisabledViewVisible(true)
    }

    func hideDisabledView() {
        self.setStepDisabledViewVisible(false)
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

    private func setStepDisabledViewVisible(_ isVisible: Bool) {
        self.stepDisabledView.isHidden = !isVisible
        self.stepDisabledView.alpha = isVisible ? 1 : 0
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

extension StepView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.delegate?.stepViewDidLoadContent(self)
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
    }

    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL) {
        self.delegate?.stepView(self, didRequestFullscreenImage: url)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenNativeImage image: UIImage) {
        self.delegate?.stepView(self, didRequestFullscreenImage: image)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL) {
        self.delegate?.stepView(self, didRequestOpenURL: url)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenARKitLink url: URL) {
        self.delegate?.stepView(self, didRequestOpenARQuickLook: url)
    }
}
