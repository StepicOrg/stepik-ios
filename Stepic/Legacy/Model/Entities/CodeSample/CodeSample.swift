import CoreData
import SwiftyJSON

final class CodeSample: NSManagedObject, ManagedObject {
    override var description: String {
        "CodeSample(input: \(self.input), output: \(self.output)"
    }

    required convenience init(input: String, output: String) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(input: input, output: output)
    }

    func update(input: String, output: String) {
        self.input = input
        self.output = output
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? CodeSample else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.input != object.input { return false }
        if self.output != object.output { return false }

        return true
    }
}
