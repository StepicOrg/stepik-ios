import Foundation

struct SplitTestPlainObject: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType
    let groups: [String]
    let dataBaseKey: String
}

extension SplitTestPlainObject {
    init<Value: SplitTestProtocol>(_ splitTestType: Value.Type) {
        self.uniqueIdentifier = splitTestType.identifier
        self.groups = splitTestType.GroupType.groups.map(\.rawValue)
        self.dataBaseKey = splitTestType.dataBaseKey
    }
}
