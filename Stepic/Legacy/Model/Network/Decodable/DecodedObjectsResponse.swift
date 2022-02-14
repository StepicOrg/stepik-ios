import Foundation

struct DecodedObjectsResponse<T: Decodable>: Decodable {
    let meta: Meta
    let decodedObjects: [T]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.meta = try container.decodeIfPresent(Meta.self, forKey: .meta) ?? .oneAndOnlyPage

        for key in container.allKeys where key.stringValue != CodingKeys.meta.stringValue {
            var decodedObjectsContainer = try container.nestedUnkeyedContainer(forKey: key)

            var failedDecode = false
            var lastDecodingError: Swift.Error?
            var tempDecodedObjects = [T]()

            while !decodedObjectsContainer.isAtEnd && !failedDecode {
                do {
                    let decodedObject = try decodedObjectsContainer.decode(T.self)
                    tempDecodedObjects.append(decodedObject)
                } catch {
                    failedDecode = true
                    lastDecodingError = error
                    break
                }
            }

            if !failedDecode {
                self.decodedObjects = tempDecodedObjects
                return
            } else if !tempDecodedObjects.isEmpty {
                if let lastDecodingError = lastDecodingError {
                    throw lastDecodingError
                }
                throw DecodingError.dataCorruptedError(in: decodedObjectsContainer, debugDescription: "")
            }
        }

        throw DecodingError.typeMismatch(
            T.self,
            .init(
                codingPath: container.allKeys,
                debugDescription: "Didn't find nestedUnkeyedContainer for \(String(describing: T.self))",
                underlyingError: nil
            )
        )
    }

    private struct CodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?

        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            return nil
        }

        static var meta: Self { Self(stringValue: "meta") }
    }
}
