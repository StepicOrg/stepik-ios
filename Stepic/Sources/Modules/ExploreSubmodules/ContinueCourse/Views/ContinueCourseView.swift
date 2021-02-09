import SnapKit
import UIKit

protocol ContinueCourseViewDelegate: AnyObject {
    func continueCourseContinueButtonDidClick(_ continueCourseView: ContinueCourseView)
}

extension ContinueCourseView {
    struct Appearance {
        let cornerRadius: CGFloat = 13

        let coverSize = CGSize(width: 40, height: 40)
        let coverCornerRadius: CGFloat = 8
    }
}

final class ContinueCourseView: UIView {
    weak var delegate: ContinueCourseViewDelegate?

    let appearance: Appearance

    private lazy var lastStepView: ContinueLastStepView = {
        let view = ContinueLastStepView()
        view.addTarget(self, action: #selector(self.lastStepViewClicked), for: .touchUpInside)
        return view
    }()

    var tooltipAnchorView: UIView { self.lastStepView.tooltipAnchorView }

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners([.topLeft, .topRight], radius: self.appearance.cornerRadius)
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

    func showLoading() {
        self.lastStepView.setContentHidden(true)
        self.skeleton.viewBuilder = { ContinueCourseSkeletonView() }
        self.skeleton.show()
    }

    func hideLoading() {
        self.lastStepView.setContentHidden(false)
        self.skeleton.hide()
    }

    @objc
    private func lastStepViewClicked() {
        self.delegate?.continueCourseContinueButtonDidClick(self)
    }
}

extension ContinueCourseView: ProgrammaticallyInitializableViewProtocol {
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
