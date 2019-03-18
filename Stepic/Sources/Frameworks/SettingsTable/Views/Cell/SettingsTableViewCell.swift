import SnapKit
import UIKit

class SettingsTableViewCell<T: UIView>: UITableViewCell, Reusable {
    private let elementViewLeftInset: CGFloat = 16

    lazy var elementView = T()

    private lazy var topSeparatorView = SeparatorView()
    private lazy var bottomSeparatorView = SeparatorView()

    var topSeparatorType: SeparatorType = .full {
        didSet {
            self.updateSeparators()
        }
    }

    var bottomSeparatorType: SeparatorType = .full {
        didSet {
            self.updateSeparators()
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.contentView.addSubview(self.topSeparatorView)
        self.topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.topSeparatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.contentView.addSubview(self.elementView)
        self.elementView.translatesAutoresizingMaskIntoConstraints = false
        self.elementView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.elementViewLeftInset)
            make.top.bottom.trailing.equalToSuperview()
        }

        self.contentView.addSubview(self.bottomSeparatorView)
        self.bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomSeparatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
        }
    }

    private func updateSeparators() {
        self.topSeparatorView.isHidden = self.topSeparatorType == .none
        self.topSeparatorView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(self.topSeparatorType.leftOffset)
        }

        self.bottomSeparatorView.isHidden = self.bottomSeparatorType == .none
        self.bottomSeparatorView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(self.bottomSeparatorType.leftOffset)
        }
    }

    enum SeparatorType {
        /// Separator without padding
        case full
        /// Separator with left padding
        case left
        /// Without separator
        case none

        var leftOffset: CGFloat {
            switch self {
            case .left:
                return 16
            default:
                return 0
            }
        }
    }
}
