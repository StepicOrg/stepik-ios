import Foundation

protocol NewMatchingQuizInteractorProtocol {
    func doReplyUpdate(request: NewMatchingQuiz.ReplyConvert.Request)
}

final class NewMatchingQuizInteractor: NewMatchingQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewMatchingQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: MatchingDataset?
    // swiftlint:disable:next discouraged_optional_collection
    private var currentItems: [NewMatchingQuiz.MatchItem]?

    init(presenter: NewMatchingQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: NewMatchingQuiz.ReplyConvert.Request) {
        self.currentItems = request.items
        self.outputCurrentReply()
    }

    private func presentNewData() {
        guard let items = self.currentItems else {
            return
        }

        self.presenter.presentReply(
            response: .init(
                items: items,
                status: self.currentStatus
            )
        )
    }

    private func outputCurrentReply() {
        guard let items = self.currentItems else {
            return
        }

        let reply = MatchingReply(ordering: items.map { $0.option.id })
        self.moduleOutput?.update(reply: reply)
    }
}

extension NewMatchingQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let dataset = self.currentDataset else {
            return
        }

        guard let reply = reply else {
            self.currentItems = self.makeMatchItems(dataset: dataset)
            self.outputCurrentReply()
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? MatchingReply {
            self.currentItems = reply.ordering.enumerated().map { index, order in
                .init(
                    title: .init(id: index, text: dataset.firstValues[index]),
                    option: .init(id: order, text: dataset.secondValues[order])
                )
            }
        } else {
            fatalError("Unsupported reply")
        }
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    func update(dataset: Dataset?) {
        guard let dataset = dataset as? MatchingDataset else {
            return
        }

        self.currentDataset = dataset
        self.currentItems = self.makeMatchItems(dataset: dataset)
    }

    private func makeMatchItems(dataset: MatchingDataset) -> [NewMatchingQuiz.MatchItem] {
        dataset.pairs.enumerated().map { index, pair in
            .init(
                title: .init(id: index, text: pair.first),
                option: .init(id: index, text: pair.second)
            )
        }
    }
}
