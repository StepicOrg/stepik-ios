import Foundation

protocol TableQuizSelectColumnsOutputProtocol: AnyObject {
    func handleSelectedColumnsUpdated(for row: TableQuiz.Row, selectedColumnsIDs: Set<UniqueIdentifierType>)
}
