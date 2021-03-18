import Foundation
import PromiseKit

protocol InstructionsNetworkServiceProtocol: AnyObject {
    func fetch(id: Int) -> Promise<InstructionDataPlainObject?>
}

final class InstructionsNetworkService: InstructionsNetworkServiceProtocol {
    private let instructionsAPI: InstructionsAPI

    init(instructionsAPI: InstructionsAPI) {
        self.instructionsAPI = instructionsAPI
    }

    func fetch(id: Int) -> Promise<InstructionDataPlainObject?> {
        self.instructionsAPI
            .getInstruction(id: id)
            .map(self.mapInstructionsResponseToData)
            .map(\.first)
    }

    private func mapInstructionsResponseToData(_ response: InstructionsResponse) -> [InstructionDataPlainObject] {
        let rubricsMap = response.rubrics.reduce(into: [:]) { $0[$1.id] = $1 }

        return response.instructions.map { instruction in
            InstructionDataPlainObject(
                instruction: instruction,
                rubrics: instruction.rubrics.compactMap { rubricsMap[$0] }
            )
        }
    }
}
