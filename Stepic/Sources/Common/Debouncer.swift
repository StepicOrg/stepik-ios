import Foundation

protocol DebouncerProtocol: AnyObject {
    var action: (() -> Void)? { get set }

    init(delay: Double)
}

final class Debouncer: DebouncerProtocol {
    private static let defaultDelay: Double = 0.35

    private let delay: Double
    private weak var timer: Timer?

    var action: (() -> Void)? {
        didSet {
            self.debounce()
        }
    }

    init(delay: Double = Debouncer.defaultDelay) {
        self.delay = delay
    }

    convenience init(delay: Double = Debouncer.defaultDelay, action: @escaping () -> Void) {
        self.init(delay: delay)
        self.action = action
    }

    private func debounce() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
            timeInterval: self.delay,
            target: self,
            selector: #selector(self.executeAction(_:)),
            userInfo: nil,
            repeats: false
        )
    }

    @objc
    private func executeAction(_ sender: Timer) {
        self.action?()
    }
}
