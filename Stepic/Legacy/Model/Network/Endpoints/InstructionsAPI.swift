import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class InstructionsAPI: APIEndpoint {
    override class var name: String { "instructions" }

    func getInstruction(id: Int) -> Promise<InstructionsResponse> {
        self.retrieve
            .request(requestEndpoint: "\(Self.name)/\(id)", withManager: self.manager)
            .map(InstructionsResponse.init)
    }

    func getInstructions(ids: [Int]) -> Promise<InstructionsResponse> {
        self.retrieve
            .request(requestEndpoint: Self.name, ids: ids, withManager: self.manager)
            .map(InstructionsResponse.init)
    }
}
