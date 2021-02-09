import SnapKit
import UIKit

protocol ContinueCourseViewDelegate: AnyObject {
    func continueCourseDidClickContinue(_ continueCourseView: ContinueCourseView)
    func continueCourseDidClickEmpty(_ continueCourseView: ContinueCourseView)
}

extension ContinueCourseView {
    struct Appearance {
        let cornerRadius: CGFloat = 13
        let primaryColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikSystemPrimaryText)
    }
}

final class ContinueCourseView: UIView {
    weak var delegate: ContinueCourseViewDelegate?

    let appearance: Appearance

    private lazy var backgroundView = ContinueCourseBackgroundView()

    private lazy var emptyView: ContinueCourseEmptyView = {
        let view = ContinueCourseEmptyView(appearance: .init(primaryColor: self.appearance.primaryColor))
        view.addTarget(self, action: #selector(self.emptyViewClicked), for: .touchUpInside)
        view.isHidden = true
        return view
    }()

    private lazy var lastStepView: ContinueLastStepView = {
        let view = ContinueLastStepView(appearance: .init(primaryColor: self.appearance.primaryColor))
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
        self.lastStepView.isHidden = true
        self.skeleton.viewBuilder = { ContinueCourseSkeletonView() }
        self.skeleton.show()
    }

    func hideLoading() {
        self.lastStepView.isHidden = false
        self.skeleton.hide()
    }

    func showEmpty() {
        self.lastStepView.isHidden = true
        self.emptyView.isHidden = false
    }

    func hideEmpty() {
        self.lastStepView.isHidden = false
        self.emptyView.isHidden = true
    }

    func showError() {
        self.lastStepView.isHidden = true
    }

    func hideError() {
        self.lastStepView.isHidden = false
    }

    @objc
    private func lastStepViewClicked() {
        self.delegate?.continueCourseDidClickContinue(self)
    }

    @objc
    private func emptyViewClicked() {
        self.delegate?.continueCourseDidClickEmpty(self)
    }
}

extension ContinueCourseView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.backgroundView)
        self.addSubview(self.emptyView)
        self.addSubview(self.lastStepView)
    }

    func makeConstraints() {
        [
            self.backgroundView,
            self.emptyView,
            self.lastStepView
        ].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
}
