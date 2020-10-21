import Foundation
import SwiftyJSON

final class TableDataset: Dataset {
    var datasetDescription: String
    var rows: [String]
    var columns: [String]
    var isCheckbox: Bool

    override var hash: Int {
        var result = self.datasetDescription.hashValue
        result = result &* 31 &+ self.rows.hashValue
        result = result &* 31 &+ self.columns.hashValue
        result = result &* 31 &+ self.isCheckbox.hashValue
        return result
    }

    override var description: String {
        """
        TableDataset(description: \(self.datasetDescription), \
        rows: \(self.rows), \
        columns: \(self.columns), \
        isCheckbox: \(self.isCheckbox))
        """
    }

    /* Example data:
     {
        "description": "",
        "rows": [
            "Traffic lights",
            "Women's dress",
            "Sun",
            "Grass"
        ],
        "columns": [
            "Red",
            "Blue",
            "Green"
        ],
        "is_checkbox": true
     }
     */
    required init(json: JSON) {
        self.datasetDescription = json[JSONKey.description.rawValue].stringValue
        self.rows = json[JSONKey.rows.rawValue].arrayValue.map(\.stringValue)
        self.columns = json[JSONKey.columns.rawValue].arrayValue.map(\.stringValue)
        self.isCheckbox = json[JSONKey.isCheckbox.rawValue].boolValue

        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let description = coder.decodeObject(forKey: JSONKey.description.rawValue) as? String,
              let rows = coder.decodeObject(forKey: JSONKey.rows.rawValue) as? [String],
              let columns = coder.decodeObject(forKey: JSONKey.columns.rawValue) as? [String] else {
            return nil
        }

        self.datasetDescription = description
        self.rows = rows
        self.columns = columns
        self.isCheckbox = coder.decodeBool(forKey: JSONKey.isCheckbox.rawValue)

        super.init(coder: coder)
    }

    private override init() {
        self.datasetDescription = ""
        self.rows = []
        self.columns = []
        self.isCheckbox = false

        super.init()
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.datasetDescription, forKey: JSONKey.description.rawValue)
        coder.encode(self.rows, forKey: JSONKey.rows.rawValue)
        coder.encode(self.columns, forKey: JSONKey.columns.rawValue)
        coder.encode(self.isCheckbox, forKey: JSONKey.isCheckbox.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TableDataset else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.datasetDescription != object.datasetDescription { return false }
        if self.rows != object.rows { return false }
        if self.columns != object.columns { return false }
        if self.isCheckbox != object.isCheckbox { return false }

        return true
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = TableDataset()
        copy.datasetDescription = self.datasetDescription
        copy.rows = self.rows
        copy.columns = self.columns
        copy.isCheckbox = self.isCheckbox
        return copy
    }

    enum JSONKey: String {
        case description
        case rows
        case columns
        case isCheckbox = "is_checkbox"
    }
}
