import SnapKit
import UIKit

extension FillBlanksInputCollectionViewCell {
    struct Appearance {
        let height: CGFloat = 36
        let minWidth: CGFloat = 102
        let cornerRadius: CGFloat = 18
    }
}

final class FillBlanksInputCollectionViewCell: UICollectionViewCell, Reusable {
    var appearance = Appearance()

    private lazy var cellView: FillBlanksInputCellView = {
        let view = FillBlanksInputCellView()
        view.backgroundColor = .stepikVioletFixed
        return view
    }()

    private var cellViewMaxWidthConstraint: Constraint?

    var maxWidth: CGFloat? {
        didSet {
            if let maxWidth = self.maxWidth {
                self.cellViewMaxWidthConstraint?.activate()
                self.cellViewMaxWidthConstraint?.update(offset: maxWidth)
            }
        }
    }

    var onInputChanged: ((String) -> Void)? {
        get {
            self.cellView.onInputChanged
        }
        set {
            self.cellView.onInputChanged = newValue
        }
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateBorder()
    }

    private func updateBorder() {
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true
    }
}

extension FillBlanksInputCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.contentView.isOpaque = true
    }

    func addSubviews() {
        self.contentView.addSubview(self.cellView)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(self.appearance.height)
            make.width.greaterThanOrEqualTo(self.appearance.minWidth)

            self.cellViewMaxWidthConstraint = make.width.lessThanOrEqualTo(Int.max).constraint
            self.cellViewMaxWidthConstraint?.deactivate()
        }
    }
}
