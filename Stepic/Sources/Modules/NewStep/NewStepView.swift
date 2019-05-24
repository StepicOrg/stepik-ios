import SnapKit
import UIKit

protocol NewStepViewDelegate: class {
    func newStepViewDidRequestVideo(_ view: NewStepView)
}

extension NewStepView {
    struct Appearance { }
}

final class NewStepView: UIView {
    let appearance: Appearance
    weak var delegate: NewStepViewDelegate?

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(orientation: .vertical)
        return view
    }()

    private lazy var stepTextView: ProcessedContentTextView = {
        let view = ProcessedContentTextView()
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
        let view = StepControlsView(navigationState: .both)
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

    func configure(viewModel: NewStepViewModel, quizView: UIView?) {
        switch viewModel.content {
        case .video(let viewModel):
            self.scrollableStackView.insertArrangedView(self.stepVideoPreviewContainerView, at: 0)
            self.stepVideoPreviewView.thumbnailImageURL = viewModel?.videoThumbnailImageURL
        case .text(let htmlString):
            self.scrollableStackView.insertArrangedView(self.stepTextView, at: 0)
            self.stepTextView.loadHTMLText(htmlString)
        }

        guard let quizView = quizView else {
            return
        }

        self.quizContainerView.addSubview(quizView)
        quizView.translatesAutoresizingMaskIntoConstraints = false
        quizView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: Private API

    private func positionVideoPreview() {
        let fullHeight = self.bounds.height
        let previewHeight = self.stepVideoPreviewView.bounds.height
        let controlsHeight = self.stepControlsView.bounds.height
        let topInset = self.scrollableStackView.contentInsets.top

        self.scrollableStackView.isScrollEnabled = previewHeight + controlsHeight + topInset >= fullHeight

        let previewContainerHeight = max(0, fullHeight - topInset - previewHeight - controlsHeight)
        self.stepVideoPreviewView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(previewContainerHeight * 0.5)
            make.bottom.equalToSuperview().offset(-previewContainerHeight * 0.5)
        }
    }
}

extension NewStepView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.stepVideoPreviewContainerView.addSubview(self.stepVideoPreviewView)

        self.addSubview(self.scrollableStackView)
        self.scrollableStackView.addArrangedView(self.quizContainerView)
        self.scrollableStackView.addArrangedView(self.stepControlsView)
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
    }
}
