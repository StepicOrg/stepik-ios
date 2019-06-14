import SnapKit
import UIKit

extension BaseQuizView {
    struct Appearance { }
}

final class BaseQuizView: UIView {
    let appearance: Appearance

    private lazy var feedbackView = QuizFeedbackView(state: .wrong)

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
}

extension BaseQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() {
        self.addSubview(self.feedbackView)
    }

    func makeConstraints() {
        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.feedbackView.update(state: .correct, feedback: "abacaba")
        }
    }
}
