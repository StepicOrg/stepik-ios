import Foundation

protocol NewMatchingQuizInteractorProtocol {
}

final class NewMatchingQuizInteractor: NewMatchingQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewMatchingQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: MatchingDataset?
    // swiftlint:disable:next discouraged_optional_collection
    //private var currentOptions: [NewSortingQuiz.Option]?

    init(presenter: NewMatchingQuizPresenterProtocol) {
        self.presenter = presenter
    }

//    func doReplyUpdate(request: NewSortingQuiz.ReplyConvert.Request) {
//        self.currentOptions = request.options
//        self.outputCurrentReply()
//    }
//
//    private func presentNewData() {
//        guard let options = self.currentOptions else {
//            return
//        }
//
//        self.presenter.presentReply(
//            response: .init(
//                options: options,
//                status: self.currentStatus
//            )
//        )
//    }
//
//    private func outputCurrentReply() {
//        guard let options = self.currentOptions else {
//            return
//        }
//
//        self.moduleOutput?.update(reply: SortingReply(ordering: options.map { $0.id }))
//    }
}

extension NewMatchingQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
//        defer {
//            self.presentNewData()
//        }
//
//        guard let dataset = self.currentDataset else {
//            return
//        }
//
//        guard let reply = reply else {
//            self.currentOptions = dataset.options.enumerated().map { .init(id: $0, text: $1) }
//            self.outputCurrentReply()
//            return
//        }
//
//        self.moduleOutput?.update(reply: reply)
//
//        if let reply = reply as? SortingReply {
//            self.currentOptions = reply.ordering.enumerated().map { .init(id: $0, text: dataset.options[$1]) }
//        } else {
//            fatalError("Unsupported reply")
//        }
    }

    func update(status: QuizStatus?) {
//        self.currentStatus = status
//        self.presentNewData()
    }

    func update(dataset: Dataset?) {
//        guard let dataset = dataset as? SortingDataset else {
//            return
//        }
//
//        self.currentDataset = dataset
//        self.currentOptions = dataset.options.enumerated().map { .init(id: $0, text: $1) }
    }
}
