import Foundation

@available(iOS 14.0, *)
@objc(StepikWidgetToken)
final class StepikWidgetToken: NSObject, NSSecureCoding {
    private static let accessTokenCoderKey = "accessToken"

    static var supportsSecureCoding = true

    let accessToken: String?

    init(accessToken: String?) {
        self.accessToken = accessToken
    }

    init?(coder: NSCoder) {
        self.accessToken = coder.decodeObject(of: NSString.self, forKey: Self.accessTokenCoderKey) as String?
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.accessToken, forKey: Self.accessTokenCoderKey)
    }
}
