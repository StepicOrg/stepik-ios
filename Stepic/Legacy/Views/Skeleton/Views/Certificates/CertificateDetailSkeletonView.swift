import SnapKit
import UIKit

extension CertificateDetailSkeletonView {
    struct Appearance {
        let headerInfoViewHeight: CGFloat = 18

        let courseTitleViewHeight: CGFloat = 42

        let recipientViewHeight: CGFloat = 42

        let gradeViewHeight: CGFloat = 14

        let previewViewHeight: CGFloat = 266

        let cornerRadius: CGFloat = 4

        let defaultLayoutInsets = LayoutInsets.default
    }
}

final class CertificateDetailSkeletonView: UIView {
    let appearance: Appearance

    private lazy var headerInfoView = UIView()

    private lazy var courseTitleView = UIView()

    private lazy var recipientView = UIView()

    private lazy var gradeView = UIView()

    private lazy var previewView = UIView()

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
}

extension CertificateDetailSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.headerInfoView)
        self.addSubview(self.courseTitleView)
        self.addSubview(self.recipientView)
        self.addSubview(self.gradeView)
        self.addSubview(self.previewView)

        self.subviews.forEach { subview in
            subview.clipsToBounds = true
            subview.layer.cornerRadius = self.appearance.cornerRadius
        }
    }

    func makeConstraints() {
        self.headerInfoView.translatesAutoresizingMaskIntoConstraints = false
        self.headerInfoView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(self.appearance.defaultLayoutInsets.top)
            make.leading.trailing.equalToSuperview().inset(self.appearance.defaultLayoutInsets.edgeInsets)
            make.height.equalTo(self.appearance.headerInfoViewHeight)
        }

        self.courseTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.courseTitleView.snp.makeConstraints { make in
            make.top.equalTo(self.headerInfoView.snp.bottom).offset(self.appearance.defaultLayoutInsets.top)
            make.leading.trailing.equalToSuperview().inset(self.appearance.defaultLayoutInsets.edgeInsets)
            make.height.equalTo(self.appearance.courseTitleViewHeight)
        }

        self.recipientView.translatesAutoresizingMaskIntoConstraints = false
        self.recipientView.snp.makeConstraints { make in
            make.top.equalTo(self.courseTitleView.snp.bottom).offset(self.appearance.defaultLayoutInsets.top)
            make.leading.trailing.equalToSuperview().inset(self.appearance.defaultLayoutInsets.edgeInsets)
            make.height.equalTo(self.appearance.recipientViewHeight)
        }

        self.gradeView.translatesAutoresizingMaskIntoConstraints = false
        self.gradeView.snp.makeConstraints { make in
            make.top.equalTo(self.recipientView.snp.bottom).offset(self.appearance.defaultLayoutInsets.top)
            make.leading.trailing.equalToSuperview().inset(self.appearance.defaultLayoutInsets.edgeInsets)
            make.height.equalTo(self.appearance.gradeViewHeight)
        }

        self.previewView.translatesAutoresizingMaskIntoConstraints = false
        self.previewView.snp.makeConstraints { make in
            make.top.equalTo(self.gradeView.snp.bottom).offset(self.appearance.defaultLayoutInsets.top)
            make.leading.trailing.equalToSuperview().inset(self.appearance.defaultLayoutInsets.edgeInsets)
            make.height.equalTo(self.appearance.previewViewHeight)
        }
    }
}
