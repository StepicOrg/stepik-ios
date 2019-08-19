import Foundation

protocol NewSortingQuizInteractorProtocol { }

final class NewSortingQuizInteractor: NewSortingQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewSortingQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: SortingDataset?
    // swiftlint:disable:next discouraged_optional_collection
    private var currentOptions: [String]?

    init(presenter: NewSortingQuizPresenterProtocol) {
        self.presenter = presenter
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
        guard let options = self.currentOptions,
              let dataset = self.currentDataset else {
            return
        }

        var optionByPosition: [String: Int] = [:]
        for (index, option) in dataset.options.enumerated() {
            optionByPosition[option] = index
        }

        let reply = SortingReply(ordering: options.compactMap { optionByPosition[$0] })

        self.moduleOutput?.update(reply: reply)
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
            self.currentOptions = dataset.options
            self.outputCurrentReply()
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? SortingReply {
            var options = [String](repeating: "", count: dataset.options.count)
            for (index, order) in reply.ordering.enumerated() {
                options[index] = dataset.options[order]
            }

            self.currentOptions = options
        }

        fatalError("Unsupported reply")
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
        self.currentOptions = dataset.options
    }
}
