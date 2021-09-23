import Foundation

protocol BaseQuizInputProtocol: AnyObject {
    func changeCurrent(attempt: Attempt, submission: Submission)
}
