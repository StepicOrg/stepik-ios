import SwiftyJSON
import UIKit

final class MatchingDataset: Dataset {
    override class var supportsSecureCoding: Bool { true }

    typealias Pair = (first: String, second: String)

    var pairs: [Pair]
    var firstValues: [String] { self.pairs.map { $0.first } }
    var secondValues: [String] { self.pairs.map { $0.second } }

    override var hash: Int {
        var result = self.firstValues.hashValue
        result = result &* 31 &+ self.secondValues.hashValue
        return result
    }

    override var description: String {
        "MatchingDataset(pairs: \(self.pairs))"
    }

    /* Example data:
     {
       "pairs": [
         {
           "first": "Sky",
           "second": "Green"
         },
         {
           "first": "Sun",
           "second": "Orange"
         },
         {
           "first": "Grass",
           "second": "Blue"
         }
       ]
     }
     */
    required init(json: JSON) {
        self.pairs = json[JSONKey.pairs.rawValue].arrayValue.map { pairJSON in
            let firstValue = pairJSON[JSONKey.first.rawValue].stringValue
            let secondValue = pairJSON[JSONKey.second.rawValue].stringValue
            return (firstValue, secondValue)
        }

        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let firstValues = coder.decodeObject(forKey: JSONKey.first.rawValue) as? [String],
              let secondValues = coder.decodeObject(forKey: JSONKey.second.rawValue) as? [String] else {
            return nil
        }

        self.pairs = zip(firstValues, secondValues).map { (first: $0, second: $1) }

        super.init(coder: coder)
    }

    override private init() {
        self.pairs = []
        super.init()
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.firstValues, forKey: JSONKey.first.rawValue)
        coder.encode(self.secondValues, forKey: JSONKey.second.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MatchingDataset else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.firstValues != object.firstValues { return false }
        if self.secondValues != object.secondValues { return false }
        return true
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = MatchingDataset()
        copy.pairs = self.pairs
        return copy
    }

    enum JSONKey: String {
        case pairs
        case first
        case second
    }
}
