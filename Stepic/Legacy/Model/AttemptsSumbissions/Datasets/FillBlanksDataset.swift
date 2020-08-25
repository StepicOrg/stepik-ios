import SwiftyJSON
import Foundation

final class FillBlanksDataset: Dataset {
    var components: [FillBlanksComponent]

    override var hash: Int {
        self.components.hashValue
    }

    override var description: String {
        "FillBlanksDataset(components: \(self.components))"
    }

    /* Example data:
     {
        "components": [
          {
            "type": "text",
            "text": "<strong>2 + 2</strong> =",
            "options": []
          },
          {
            "type": "input",
            "text": "",
            "options": []
          },
          {
            "type": "text",
            "text": "3 + 3 =",
            "options": []
          },
          {
            "type": "select",
            "text": "",
            "options": [
              "4",
              "5",
              "6"
            ]
          }
        ]
      }
     */
    required init(json: JSON) {
        self.components = json[JSONKey.components.rawValue].arrayValue.map { FillBlanksComponent(json: $0) }
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let components = coder.decodeObject(forKey: JSONKey.components.rawValue) as? [FillBlanksComponent] else {
            return nil
        }

        self.components = components

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.components, forKey: JSONKey.components.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FillBlanksDataset else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.components != object.components { return false }
        return true
    }

    enum JSONKey: String {
        case components
    }
}

final class FillBlanksComponent: NSObject, NSCoding {
    var componentType: ComponentType
    var text: String
    var options: [String]

    override var hash: Int {
        var result = self.componentType.rawValue.hashValue
        result = result &* 31 &+ self.text.hashValue
        result = result &* 31 &+ self.options.hashValue
        return result
    }

    override var description: String {
        "FillBlanksComponent(type: \(self.componentType), text: \(self.text), options: \(self.options))"
    }

    init(json: JSON) {
        let typeStringValue = json[JSONKey.type.rawValue].stringValue
        self.componentType = ComponentType(rawValue: typeStringValue) ?? .text

        let textStringValue = json[JSONKey.text.rawValue].stringValue
        self.text = Self.sanitizeText(textStringValue)

        self.options = json[JSONKey.options.rawValue].arrayValue.map(\.stringValue)

        super.init()
    }

    init?(coder: NSCoder) {
        guard let typeStringValue = coder.decodeObject(forKey: JSONKey.type.rawValue) as? String,
              let text = coder.decodeObject(forKey: JSONKey.text.rawValue) as? String,
              let options = coder.decodeObject(forKey: JSONKey.options.rawValue) as? [String] else {
            return nil
        }

        self.componentType = ComponentType(rawValue: typeStringValue) ?? .text
        self.text = text
        self.options = options

        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.componentType.rawValue, forKey: JSONKey.type.rawValue)
        coder.encode(self.text, forKey: JSONKey.text.rawValue)
        coder.encode(self.options, forKey: JSONKey.options.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FillBlanksComponent else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.componentType != object.componentType { return false }
        if self.text != object.text { return false }
        if self.options != object.options { return false }
        return true
    }

    private static func sanitizeText(_ text: String) -> String {
        var text = text

        for emptyTag in ["<br>", "<br/>", "<br />"] {
            if text.indexOf(emptyTag) == 0 {
                text.removeSubrange(text.startIndex..<text.index(text.startIndex, offsetBy: emptyTag.count))
                return text
            }
        }

        return text
    }

    enum ComponentType: String {
        case text
        case input
        case select

        var isBlankFillable: Bool {
            self == .input || self == .select
        }
    }

    enum JSONKey: String {
        case text
        case type
        case options
    }
}
