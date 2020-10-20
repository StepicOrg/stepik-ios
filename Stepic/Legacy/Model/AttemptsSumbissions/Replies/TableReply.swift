import Foundation
import SwiftyJSON

final class TableReply: Reply {
    var choices: [TableReplyChoice]

    override var dictValue: [String: Any] {
        [
            JSONKey.choices.rawValue: self.choices.map(\.dictValue)
        ]
    }

    override var hash: Int {
        self.choices.hashValue
    }

    override var description: String {
        "TableReply(choices: \(self.choices))"
    }

    init(choices: [TableReplyChoice]) {
        self.choices = choices
        super.init()
    }

    /* Example data:
     {
       "choices": [
         {
           "name_row": "United States",
           "columns": [
             {
               "name": "New York",
               "answer": false
             },
             {
               "name": "Moscow",
               "answer": false
             }
           ]
         }
       ]
     }
     */
    required init(json: JSON) {
        self.choices = json[JSONKey.choices.rawValue].arrayValue.compactMap { TableReplyChoice(json: $0) }
        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let choices = coder.decodeObject(forKey: JSONKey.choices.rawValue) as? [TableReplyChoice] else {
            return nil
        }

        self.choices = choices

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.choices, forKey: JSONKey.choices.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TableReply else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.choices != object.choices { return false }

        return true
    }

    enum JSONKey: String {
        case choices
    }
}

// MARK: - TableReplyChoice -

final class TableReplyChoice: NSObject, NSCoding {
    var rowName: String
    var columns: [Column]

    var dictValue: [String: Any] {
        [
            JSONKey.nameRow.rawValue: self.rowName,
            JSONKey.columns.rawValue: self.columns.map(\.dictValue)
        ]
    }

    override var hash: Int {
        var result = self.rowName.hashValue
        result = result &* 31 &+ self.columns.hashValue
        return result
    }

    override var description: String {
        "TableReplyChoice(rowName: \(self.rowName), columns: \(self.columns))"
    }

    init(rowName: String, columns: [Column]) {
        self.rowName = rowName
        self.columns = columns

        super.init()
    }

    /* Example data:
     {
        "name_row": "United States",
        "columns": [
            {
                "name": "New York",
                "answer": false
            }
        ]
     }
     */
    init(json: JSON) {
        self.rowName = json[JSONKey.nameRow.rawValue].stringValue
        self.columns = json[JSONKey.columns.rawValue].arrayValue.compactMap { Column(json: $0) }

        super.init()
    }

    init?(coder: NSCoder) {
        guard let rowName = coder.decodeObject(forKey: JSONKey.nameRow.rawValue) as? String,
              let columns = coder.decodeObject(forKey: JSONKey.columns.rawValue) as? [Column] else {
            return nil
        }

        self.rowName = rowName
        self.columns = columns

        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.rowName, forKey: JSONKey.nameRow.rawValue)
        coder.encode(self.columns, forKey: JSONKey.columns.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TableReplyChoice else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.rowName != object.rowName { return false }
        if self.columns != object.columns { return false }

        return true
    }

    enum JSONKey: String {
        case nameRow = "name_row"
        case columns
    }

    // MARK: - Column

    @objc(TableReplyChoiceColumn)final class Column: NSObject, NSCoding {
        var name: String
        var answer: Bool

        var dictValue: [String: Any] {
            [
                JSONKey.name.rawValue: self.name,
                JSONKey.answer.rawValue: self.answer
            ]
        }

        override var hash: Int {
            var result = self.name.hashValue
            result = result &* 31 &+ self.answer.hashValue
            return result
        }

        override var description: String {
            "Column(name: \(self.name), answer: \(self.answer))"
        }

        init(name: String, answer: Bool) {
            self.name = name
            self.answer = answer

            super.init()
        }

        /* Example data:
         {
            "name": "New York",
            "answer": false
         }
         */
        init(json: JSON) {
            self.name = json[JSONKey.name.rawValue].stringValue
            self.answer = json[JSONKey.answer.rawValue].boolValue

            super.init()
        }

        init?(coder: NSCoder) {
            guard let name = coder.decodeObject(forKey: JSONKey.name.rawValue) as? String else {
                return nil
            }

            self.name = name
            self.answer = coder.decodeBool(forKey: JSONKey.answer.rawValue)

            super.init()
        }

        func encode(with coder: NSCoder) {
            coder.encode(self.name, forKey: JSONKey.name.rawValue)
            coder.encode(self.answer, forKey: JSONKey.answer.rawValue)
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? Column else {
                return false
            }

            if self === object { return true }
            if type(of: self) != type(of: object) { return false }

            if self.name != object.name { return false }
            if self.answer != object.answer { return false }

            return true
        }

        enum JSONKey: String {
            case name
            case answer
        }
    }
}
