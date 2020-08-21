import SnapKit
import UIKit

extension FillBlanksInputCollectionViewCell {
    struct Appearance {
        let height: CGFloat = 36
        let minWidth: CGFloat = 90
        let cornerRadius: CGFloat = 18
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let font = UIFont.systemFont(ofSize: 16)
    }
}

final class FillBlanksInputCollectionViewCell: UICollectionViewCell, Reusable {
    var appearance = Appearance()

    private lazy var inputContainerView: FillBlanksQuizInputContainerView = {
        let view = FillBlanksQuizInputContainerView(
            appearance: .init(cornerRadius: self.appearance.cornerRadius)
        )
        return view
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = self.appearance.font
        textField.textAlignment = .center
        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    var text: String? {
        didSet {
            self.textField.text = self.text
        }
    }

    var onInputChanged: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

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

    static func calculatePreferredContentSize(string: String, maxWidth: CGFloat) -> CGSize {
        let appearance = Appearance()

        let sizeOfString = appearance.font.sizeOfString(string: string, constrainedToWidth: Double(maxWidth))
        let widthOfStringWithInsets = appearance.insets.left + sizeOfString.width + appearance.insets.right

        let width = max(appearance.minWidth, min(maxWidth, widthOfStringWithInsets))

        return CGSize(width: width, height: appearance.height)
    }
}

extension FillBlanksInputCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.inputContainerView)
        self.inputContainerView.addSubview(self.textField)
    }

    func makeConstraints() {
        self.inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.inputContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.insets)
        }
    }
}
