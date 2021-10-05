import SnapKit
import UIKit

protocol ContinueCourseViewDelegate: AnyObject {
    func continueCourseContinueButtonDidClick(_ continueCourseView: ContinueCourseView)
    func continueCourseSiriButtonDidClick(_ continueCourseView: ContinueCourseView)
}

final class ContinueCourseView: UIView {
    private lazy var lastStepView = ContinueLastStepView()
    weak var delegate: ContinueCourseViewDelegate?

    // View for tooltip
    var tooltipAnchorView: UIView { self.lastStepView.continueButton }

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

    func configure(viewModel: ContinueCourseViewModel) {
        self.lastStepView.courseTitle = viewModel.title

        if let progressDescription = viewModel.progress?.description,
           let progressValue = viewModel.progress?.value {
            self.lastStepView.progressText = progressDescription
            self.lastStepView.progress = progressValue
        }
        self.lastStepView.coverImageURL = viewModel.coverImageURL
    }

    @available(iOS 12.0, *)
    func configureSiriButton(contentConfiguration: SiriButtonContentConfiguration?) {
        self.lastStepView.configureSiriButton(contentConfiguration: contentConfiguration)
    }

    func showLoading() {
        self.skeleton.viewBuilder = {
            ContinueCourseSkeletonView()
        }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
    }
}

extension ContinueCourseView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.lastStepView.onContinueButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.continueCourseContinueButtonDidClick(strongSelf)
        }
        self.lastStepView.onSiriButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.continueCourseSiriButtonDidClick(strongSelf)
        }
    }

    func addSubviews() {
        self.addSubview(self.lastStepView)
    }

    func makeConstraints() {
        self.lastStepView.translatesAutoresizingMaskIntoConstraints = false
        self.lastStepView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
