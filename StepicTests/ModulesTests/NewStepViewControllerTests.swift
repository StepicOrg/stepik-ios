@testable import Stepic
import Foundation
import Nimble
import Quick
import SwiftyJSON
import XCTest

private final class NewStepViewControllerMock: StepViewControllerProtocol {
    var didSetViewModelCompletion: ((StepViewModel) -> Void)?

    func displayStep(viewModel: StepDataFlow.StepLoad.ViewModel) {
        if case .result(let data) = viewModel.state {
            self.didSetViewModelCompletion?(data)
        }
    }

    func displayStepTextUpdate(viewModel: StepDataFlow.StepTextUpdate.ViewModel) {}

    func displayPlayStep(viewModel: StepDataFlow.PlayStep.ViewModel) {}

    func displayControlsUpdate(viewModel: StepDataFlow.ControlsUpdate.ViewModel) {}

    func displayDiscussionsButtonUpdate(viewModel: StepDataFlow.DiscussionsButtonUpdate.ViewModel) {}

    func displaySolutionsButtonUpdate(viewModel: StepDataFlow.SolutionsButtonUpdate.ViewModel) {}

    func displayDiscussions(viewModel: StepDataFlow.DiscussionsPresentation.ViewModel) {}

    func displaySolutions(viewModel: StepDataFlow.SolutionsPresentation.ViewModel) {}

    func displayDownloadARQuickLook(viewModel: StepDataFlow.DownloadARQuickLookPresentation.ViewModel) {}

    func displayARQuickLook(viewModel: StepDataFlow.ARQuickLookPresentation.ViewModel) {}

    func displayOKAlert(viewModel: StepDataFlow.OKAlertPresentation.ViewModel) {}

    func displayBlockingLoadingIndicator(viewModel: StepDataFlow.BlockingWaitingIndicatorUpdate.ViewModel) {}
}

class NewStepViewControllerSpec: QuickSpec {
    override func spec() {
        var presenter: StepPresenterProtocol!
        var viewController: NewStepViewControllerMock!

        beforeEach {
            viewController = NewStepViewControllerMock()
            let newStepPresenter = StepPresenter()
            newStepPresenter.viewController = viewController
            presenter = newStepPresenter
        }

        it("has text content type") {
            let json = JSON(
                [
                    "id": -1,
                    "lesson": -1,
                    "position": 1,
                    "block": [
                        "name": "text",
                        "text": "---some very important text ---",
                        "video": nil,
                        "options": [],
                        "subtitle_files": []
                    ]
                ]
            )

            waitUntil { done in
                let step = Step(json: json)

                presenter.presentStep(
                    response: .init(
                        result: .success(StepDataFlow.StepLoad.Data(step: step, fontSize: .small, storedImages: []))
                    )
                )

                viewController.didSetViewModelCompletion = { viewModel in
                    expect(viewModel.quizType).to(beNil())

                    switch viewModel.content {
                    case .text(let htmlString):
                        expect(htmlString.contains("---some very important text ---")).to(beTrue())
                    case .video:
                        XCTFail()
                    }

                    done()
                }
            }
        }

        it("has video content type") {
            let json = JSON(
                [
                    "id": -1,
                    "lesson": -1,
                    "position": 1,
                    "block": [
                        "name": "video",
                        "text": "",
                        "video": [
                            "id": 69659,
                            "thumbnail": "https://ucarecdn.com/bf37b423-8612-4879-84b9-31b4d88b6a43/",
                            "urls": [
                                [
                                    "quality": "1080",
                                    "url": "https://stepikvideo.blob.core.windows.net/video/69659/1080/fb43e236ba6a4b7cb3087930f2a4ffc8.mp4"
                                ],
                                [
                                    "quality": "720",
                                    "url": "https://stepikvideo.blob.core.windows.net/video/69659/720/8ef04ef643b43eb6c2fdb1761c2f6f4b.mp4"
                                ],
                                [
                                    "quality": "540",
                                    "url": "https://stepikvideo.blob.core.windows.net/video/69659/540/5771f49ba3a1537fc60ee3f99662a79c.mp4"
                                ],
                                [
                                    "quality": "360",
                                    "url": "https://stepikvideo.blob.core.windows.net/video/69659/360/43c5df514043ae0a8afca3a660990328.mp4"
                                ],
                                [
                                    "quality": "240",
                                    "url": "https://stepikvideo.blob.core.windows.net/video/69659/240/872abba17d4c14d593f85a6e4bc0693b.mp4"
                                ]
                            ],
                            "duration": 14,
                            "status": "ready",
                            "upload_date": "2019-11-26T18:11:19Z",
                            "filename": "Screen Recording 2019-11-26 at 9.10.41 PM.mov"
                        ],
                        "options": [],
                        "subtitle_files": []
                    ]
                ]
            )

            waitUntil { done in
                let step = Step(json: json)

                presenter.presentStep(
                    response: .init(
                        result: .success(StepDataFlow.StepLoad.Data(step: step, fontSize: .small, storedImages: []))
                    )
                )

                viewController.didSetViewModelCompletion = { viewModel in
                    expect(viewModel.quizType).to(beNil())

                    switch viewModel.content {
                    case .text:
                        XCTFail()
                    case .video(let viewModel):
                        expect(viewModel!.video.id) == 69659
                    }

                    done()
                }
            }
        }

        it("has correct quiz type") {
            let blockNameWithQuizTypePairs: [(String, StepDataFlow.QuizType)] = [
                ("choice", .choice),
                ("code", .code),
                ("free-answer", .freeAnswer),
                ("matching", .matching),
                ("math", .math),
                ("number", .number),
                ("sorting", .sorting),
                ("sql", .sql),
                ("string", .string),
                ("animation", .unknown(blockName: "animation")),
                ("chemical", .unknown(blockName: "chemical")),
                ("dataset", .unknown(blockName: "dataset")),
                ("linux-code", .unknown(blockName: "linux-code")),
                ("puzzle", .unknown(blockName: "puzzle")),
                ("pycharm", .unknown(blockName: "pycharm")),
                ("admin", .unknown(blockName: "admin")),
                ("table", .unknown(blockName: "table")),
                ("html", .unknown(blockName: "html")),
                ("fill-blanks", .unknown(blockName: "fill-blanks")),
                ("random-tasks", .unknown(blockName: "random-tasks")),
                ("schulte", .unknown(blockName: "schulte")),
                ("manual-score", .unknown(blockName: "manual-score"))
            ]
            let steps = blockNameWithQuizTypePairs.map { pair -> Step in
                let json = JSON(
                    [
                        "id": -1,
                        "lesson": -1,
                        "position": 1,
                        "block": [
                            "name": "\(pair.0)",
                            "text": "---some very important text ---",
                            "video": nil,
                            "options": [],
                            "subtitle_files": []
                        ]
                    ]
                )
                return Step(json: json)
            }

            let lock = NSLock()

            steps.enumerated().forEach { index, step in
                lock.lock()
                waitUntil { done in
                    presenter.presentStep(
                        response: .init(
                            result: .success(StepDataFlow.StepLoad.Data(step: step, fontSize: .small, storedImages: []))
                        )
                    )

                    viewController.didSetViewModelCompletion = { viewModel in
                        expect(viewModel.quizType).toNot(beNil())
                        expect(viewModel.quizType) == blockNameWithQuizTypePairs[index].1

                        switch viewModel.content {
                        case .text(let htmlString):
                            expect(htmlString.contains("---some very important text ---")).to(beTrue())
                        case .video:
                            XCTFail()
                        }

                        lock.unlock()
                        done()
                    }
                }
            }
        }
    }
}
