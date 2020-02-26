import SwiftyJSON
import Foundation

class Dataset: NSObject, NSCoding {
    required init(json: JSON) {}

    required init?(coder: NSCoder) {}

    func encode(with coder: NSCoder) {}
}
