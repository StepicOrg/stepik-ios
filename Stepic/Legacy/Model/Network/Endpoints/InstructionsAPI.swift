import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class InstructionsAPI: APIEndpoint {
    override var name: String { "instructions" }

    func getInstruction(id: Int) -> Promise<InstructionsResponse> {
        self.retrieve
            .request(requestEndpoint: "\(self.name)/\(id)", withManager: self.manager)
            .map(InstructionsResponse.init)
    }
}
