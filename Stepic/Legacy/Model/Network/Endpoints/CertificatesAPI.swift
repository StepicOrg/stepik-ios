import Foundation
import PromiseKit
import StepikModel

final class CertificatesAPI: APIEndpoint {
    override class var name: String { "certificates" }

    func retrieve(id: Int) -> Promise<StepikModel.Certificate?> {
        self.retrieve
            .requestDecodableObjects(requestEndpoint: "\(Self.name)/\(id)", params: [:], withManager: self.manager)
            .map { $0.decodedObjects.first }
    }

    func retrieve(
        userID: Int,
        courseID: Int? = nil,
        page: Int = 1,
        order: Order? = nil
    ) -> Promise<([StepikModel.Certificate], Meta)> {
        var params: [String: Any] = [
            JSONKey.user.rawValue: userID,
            JSONKey.page.rawValue: page
        ]

        if let courseID = courseID {
            params[JSONKey.course.rawValue] = courseID
        }

        if let order = order {
            params[JSONKey.order.rawValue] = order.rawValue
        }

        return self.retrieve
            .requestDecodableObjects(requestEndpoint: Self.name, params: params, withManager: self.manager)
            .map { ($0.decodedObjects, $0.meta) }
    }

    func update(_ certificate: StepikModel.Certificate) -> Promise<StepikModel.Certificate> {
        self.update
            .requestCodableResponseDecodedObjects(
                requestEndpoint: "\(Self.name)/\(certificate.id)",
                paramName: "certificate",
                updatingObject: certificate,
                withManager: self.manager
            )
            .compactMap { $0.decodedObjects.first }
    }

    enum Order: String {
        case idDesc = "-id"
    }

    private enum JSONKey: String {
        case user
        case page
        case order
        case course
    }
}
