import SnapKit
import UIKit

extension FillBlanksInputCellView {
    struct Appearance {
        let textFieldInsets = LayoutInsets(left: 16, right: 16)
    }
}

final class FillBlanksInputCellView: UIView {
    let appearance: Appearance

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = .white
        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    var onInputChanged: ((String) -> Void)?

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

    @objc
    private func textFieldDidChange(_ sender: UITextField) {
        self.onInputChanged?(sender.text ?? "")
    }
}

extension FillBlanksInputCellView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.textField)
    }

    func makeConstraints() {
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.textFieldInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.textFieldInsets.right)
        }
    }
}
