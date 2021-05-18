import Foundation
import SwiftyJSON

extension JSON {
    var decimalNumber: NSNumber? {
        get {
            switch self.type {
            case .string:
                let decimal = NSDecimalNumber(string: self.object as? String)
                return decimal == .notANumber ? nil : decimal
            case .number:
                return self.object as? NSNumber
            case .bool:
                if let boolValue = self.object as? Bool {
                    return NSNumber(value: boolValue ? 1 : 0)
                }
                return nil
            default:
                return nil
            }
        }
        set {
            self.object = newValue ?? NSNull()
        }
    }
}
