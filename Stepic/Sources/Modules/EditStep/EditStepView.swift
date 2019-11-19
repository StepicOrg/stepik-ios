import SnapKit
import UIKit

// MARK: Appearance -

extension EditStepView {
    struct Appearance {
        let backgroundColor = UIColor.white

        let loadingIndicatorColor = UIColor.mainDark

        let textViewInsets = LayoutInsets(top: 16, bottom: 16)
        let textViewTextInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let textViewFont = UIFont.systemFont(ofSize: 16)
        let textViewTextColor = UIColor.mainDark
        let textViewPlaceholderColor = UIColor.mainDark.withAlphaComponent(0.4)
    }
}

// MARK: - EditStepViewDelegate: class -

protocol EditStepViewDelegate: class {
    func editStepView(_ view: EditStepView, didChangeText text: String)
}

// MARK: - EditStepView: UIView -

final class EditStepView: UIView {
    let appearance: Appearance

    weak var delegate: EditStepViewDelegate?

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var textView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.font = self.appearance.textViewFont
        textView.textColor = self.appearance.textViewTextColor
        textView.placeholderColor = self.appearance.textViewPlaceholderColor
        textView.placeholder = NSLocalizedString("EditStepPlaceholder", comment: "")
        textView.textInsets = self.appearance.textViewTextInsets
        // Enable scrolling
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        // Disable features
        textView.dataDetectorTypes = []
        textView.autocorrectionType = .no

        textView.delegate = self

        return textView
    }()

    var text: String? {
        didSet {
            self.textView.text = self.text
        }
    }

    var isEnabled: Bool = true {
        didSet {
            self.textView.isEditable = self.isEnabled
        }
    }

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

    // MARK: Public API

    func showLoading() {
        self.loadingIndicator.startAnimating()
        self.textView.isHidden = true
    }

    func hideLoading() {
        self.loadingIndicator.stopAnimating()
        self.textView.isHidden = false
    }
}

// MARK: - EditStepView: ProgrammaticallyInitializableViewProtocol -

extension EditStepView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.textView)
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { make in
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
            make.top.equalToSuperview().offset(self.appearance.textViewInsets.top)
            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-self.appearance.textViewInsets.bottom)
        }

        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - EditStepView: UITextViewDelegate -

extension EditStepView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.editStepView(self, didChangeText: textView.text)
    }
}
