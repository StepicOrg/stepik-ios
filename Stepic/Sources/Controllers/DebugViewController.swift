import UIKit

extension DebugViewController {
    enum Appearance {
        static let backgroundColor = UIColor.stepikBackground
    }
}

final class DebugViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    private func setup() {
        self.title = "Debug"
        self.view.backgroundColor = Appearance.backgroundColor
    }
}
