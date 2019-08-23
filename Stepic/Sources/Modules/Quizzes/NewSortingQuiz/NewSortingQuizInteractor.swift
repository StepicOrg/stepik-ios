import Foundation

protocol NewSortingQuizInteractorProtocol {
    func doReplyUpdate(request: NewSortingQuiz.ReplyConvert.Request)
}

final class NewSortingQuizInteractor: NewSortingQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewSortingQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: SortingDataset?
    // swiftlint:disable:next discouraged_optional_collection
    private var currentOptions: [NewSortingQuiz.Option]?

    init(presenter: NewSortingQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: NewSortingQuiz.ReplyConvert.Request) {
        self.currentOptions = request.options
        self.outputCurrentReply()
    }

    private func presentNewData() {
        guard let options = self.currentOptions else {
            return
        }

        self.presenter.presentReply(
            response: .init(
                options: options,
                status: self.currentStatus
            )
        )
    }

    private func outputCurrentReply() {
        guard let options = self.currentOptions else {
            return
        }

        self.moduleOutput?.update(reply: SortingReply(ordering: options.map { $0.id }))
    }
}

extension NewSortingQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let dataset = self.currentDataset else {
            return
        }

        guard let reply = reply else {
            self.currentOptions = dataset.options.enumerated().map { .init(id: $0, text: $1) }
            self.outputCurrentReply()
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? SortingReply {
            self.currentOptions = reply.ordering.map { .init(id: $0, text: dataset.options[$0]) }
        } else {
            fatalError("Unsupported reply")
        }
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    func update(dataset: Dataset?) {
        guard let dataset = dataset as? SortingDataset else {
            return
        }

        self.currentDataset = dataset
        self.currentOptions = dataset.options.enumerated().map { .init(id: $0, text: $1) }
    }
}
