import Foundation
import PromiseKit

protocol StepQuizReviewInteractorProtocol {
    func doStepQuizReviewLoad(request: StepQuizReview.QuizReviewLoad.Request)
    func doStepQuizReviewRefresh(request: StepQuizReview.QuizReviewRefresh.Request)
    func doButtonAction(request: StepQuizReview.ButtonAction.Request)
    func doChangeCurrentSubmission(request: StepQuizReview.ChangeCurrentSubmission.Request)
}

final class StepQuizReviewInteractor: StepQuizReviewInteractorProtocol {
    weak var moduleOutput: StepQuizReviewOutputProtocol?

    private let presenter: StepQuizReviewPresenterProtocol
    private let provider: StepQuizReviewProviderProtocol

    private let step: Step
    private let instructionType: InstructionType
    private let isTeacher: Bool

    private var currentReviewSession: ReviewSessionDataPlainObject?
    private var currentInstruction: InstructionDataPlainObject?

    private var currentStudentQuizData: FetchResult<StepQuizReview.QuizData>?
    private var isFetchStudentDataInProgress = false

    private var shouldShowFirstStageMessage = true

    init(
        step: Step,
        instructionType: InstructionType,
        isTeacher: Bool,
        presenter: StepQuizReviewPresenterProtocol,
        provider: StepQuizReviewProviderProtocol
    ) {
        self.step = step
        self.instructionType = instructionType
        self.isTeacher = isTeacher
        self.presenter = presenter
        self.provider = provider
    }

    func doStepQuizReviewLoad(request: StepQuizReview.QuizReviewLoad.Request) {
        if self.isTeacher {
            self.fetchTeacherData()
        } else {
            self.fetchStudentData()
        }
    }

    func doStepQuizReviewRefresh(request: StepQuizReview.QuizReviewRefresh.Request) {
        if request.afterTeacherReviewPresentation {
            self.doStepQuizReviewLoad(request: .init())
        }
    }

    func doButtonAction(request: StepQuizReview.ButtonAction.Request) {
        guard let action = StepQuizReview.ActionType(rawValue: request.actionUniqueIdentifier) else {
            return
        }

        switch action {
        case .teacherReviewSubmissions:
            self.startTeacherReview()
        case .teacherViewSubmissions:
            self.presenter.presentSubmissions(
                response: .init(
                    stepID: self.step.id,
                    isTeacher: self.isTeacher,
                    isSelectionEnabled: false,
                    filterQuery: .init(filters: [.reviewStatus(.awaiting)])
                )
            )
        }
    }

    func doChangeCurrentSubmission(request: StepQuizReview.ChangeCurrentSubmission.Request) {
        guard !self.isTeacher,
              let currentStudentQuizData = self.currentStudentQuizData,
              let attempt = request.submission.attempt else {
            return print("StepQuizReviewInteractor :: \(#function) missing data")
        }

        guard currentStudentQuizData.value.attempt != attempt,
              currentStudentQuizData.value.submission != request.submission else {
            return print("StepQuizReviewInteractor :: \(#function) skipping, the same submission selected")
        }

        self.currentStudentQuizData = .init(
            value: .init(
                attempt: attempt,
                submission: request.submission,
                submissionsCount: currentStudentQuizData.value.submissionsCount
            ),
            source: .remote
        )

        self.presenter.presentChangeCurrentSubmissionResult(
            response: .init(attempt: attempt, submission: request.submission)
        )
    }

    // MARK: Private API

    private func fetchStudentData() {
        self.isFetchStudentDataInProgress = false

        guard let sessionID = self.step.sessionID, sessionID > 0 else {
            return
        }

        self.isFetchStudentDataInProgress = true

        self.provider.fetchReviewSession(
            id: sessionID
        ).then { reviewSession -> Promise<(ReviewSessionDataPlainObject?, InstructionDataPlainObject?)> in
            if let instructionID = self.step.instructionID {
                return self.provider.fetchInstruction(id: instructionID).map { (reviewSession, $0) }
            }
            return .value((reviewSession, nil))
        }.done { reviewSession, instruction in
            self.currentReviewSession = reviewSession
            self.currentInstruction = instruction

            if let currentStudentQuizData = self.currentStudentQuizData {
                print("StepQuizReviewInteractor :: \(#function) currentStudentQuizData = \(currentStudentQuizData)")
                self.presentStepQuizReviewFromCurrentData()
            } else {
                print("StepQuizReviewInteractor :: \(#function) currentStudentQuizData is `nil`")
            }
        }.ensure {
            self.isFetchStudentDataInProgress = false
        }.catch { error in
            print("StepQuizReviewInteractor :: failed \(#function) with error = \(error)")
            self.presenter.presentStepQuizReview(response: .init(result: .failure(error)))
        }
    }

    private func fetchTeacherData() {
        firstly { () -> Promise<ReviewSessionDataPlainObject?> in
            if let sessionID = self.step.sessionID {
                return self.provider.fetchReviewSession(id: sessionID)
            }
            return .value(nil)
        }.then { reviewSession -> Promise<(ReviewSessionDataPlainObject?, InstructionDataPlainObject?)> in
            if let instructionID = self.step.instructionID {
                return self.provider.fetchInstruction(id: instructionID).map { (reviewSession, $0) }
            }
            return .value((reviewSession, nil))
        }.compactMap { reviewSession, instruction -> (ReviewSessionDataPlainObject?, InstructionDataPlainObject)? in
            if let instruction = instruction {
                return (reviewSession, instruction)
            }
            return nil
        }.then { reviewSession, instruction -> Promise<(ReviewSessionDataPlainObject?, InstructionDataPlainObject)> in
            if self.step.sessionID == nil && instruction.instruction.isFrozen {
                return self.provider
                    .createReviewSession(instructionID: instruction.instruction.id)
                    .then { reviewSession -> Promise<ReviewSessionDataPlainObject?> in
                        self.step.sessionID = reviewSession?.id
                        CoreDataHelper.shared.save()
                        return .value(reviewSession)
                    }
                    .map { ($0, instruction) }
            }
            return .value((reviewSession, instruction))
        }.done { reviewSessionOrNil, instruction in
            self.currentReviewSession = reviewSessionOrNil
            self.currentInstruction = instruction
            self.presentStepQuizReviewFromCurrentData()
        }.catch { error in
            print("StepQuizReviewInteractor :: failed \(#function) with error = \(error)")
            self.presenter.presentStepQuizReview(response: .init(result: .failure(error)))
        }
    }

    private func startTeacherReview() {
        guard let sessionID = self.step.sessionID else {
            return print("StepQuizReviewInteractor :: failed \(#function) no session")
        }

        self.presenter.presentBlockingLoadingIndicator(response: .init(shouldDismiss: false))

        self.provider.createReview(sessionID: sessionID).compactMap { $0 }.done { review in
            self.presenter.presentBlockingLoadingIndicator(response: .init(shouldDismiss: true))
            self.presenter.presentTeacherReview(response: .init(review: review, unitID: self.step.lesson?.unit?.id))
        }.catch { error in
            print("StepQuizReviewInteractor :: failed \(#function) with error = \(error)")
            self.presenter.presentBlockingLoadingIndicator(response: .init(shouldDismiss: true, showError: true))
        }
    }

    private func presentStepQuizReviewFromCurrentData() {
        let data = StepQuizReview.QuizReviewLoad.Data(
            step: self.step,
            instructionType: self.instructionType,
            isTeacher: self.isTeacher,
            shouldShowFirstStageMessage: self.shouldShowFirstStageMessage,
            session: self.currentReviewSession,
            instruction: self.currentInstruction,
            quizData: self.currentStudentQuizData?.value
        )
        self.presenter.presentStepQuizReview(response: .init(result: .success(data)))
    }
}

extension StepQuizReviewInteractor: StepQuizReviewInputProtocol {}

// MARK: - StepQuizReviewInteractor: BaseQuizOutputProtocol -

extension StepQuizReviewInteractor: BaseQuizOutputProtocol {
    func handleCorrectSubmission() {
        self.moduleOutput?.handleCorrectSubmission()
    }

    func handleSubmissionEvaluated(submission: Submission) {
        self.moduleOutput?.handleSubmissionEvaluated(submission: submission)

        print("StepQuizReviewInteractor :: \(#function) submission = \(submission)")

        guard !self.isTeacher,
              let currentStudentQuizData = self.currentStudentQuizData else {
            return
        }

        self.currentStudentQuizData = .init(
            value: .init(
                attempt: currentStudentQuizData.value.attempt,
                submission: submission,
                submissionsCount: currentStudentQuizData.value.submissionsCount + 1
            ),
            source: .remote
        )

        self.shouldShowFirstStageMessage = false
        self.presentStepQuizReviewFromCurrentData()
    }

    func handleNextStepNavigation() {
        self.moduleOutput?.handleNextStepNavigation()
    }

    func handleQuizLoaded(attempt: Attempt, submission: Submission, submissionsCount: Int, source: DataSourceType) {
        defer {
            self.moduleOutput?.handleQuizLoaded(
                attempt: attempt,
                submission: submission,
                submissionsCount: submissionsCount,
                source: source
            )
        }

        if self.isTeacher {
            return
        }

        let newQuizData: FetchResult<StepQuizReview.QuizData> = .init(
            value: .init(attempt: attempt, submission: submission, submissionsCount: submissionsCount),
            source: .init(dataSource: source)
        )

        let isQuizDataChanged: Bool = {
            if let currentQuizData = self.currentStudentQuizData {
                return currentQuizData.value != newQuizData.value || currentQuizData.source != newQuizData.source
            }
            return true
        }()

        self.currentStudentQuizData = newQuizData

        DispatchQueue.main.async {
            let shouldReload = !self.isFetchStudentDataInProgress && isQuizDataChanged
            print(
                "StepQuizReviewInteractor :: \(#function) newQuizData = \(newQuizData); shouldReload = \(shouldReload)"
            )

            if shouldReload {
                self.presentStepQuizReviewFromCurrentData()
            }
        }
    }

    func handleReviewCreateSession() {
        print(#function)
    }

    func handleReviewSelectDifferentSubmission() {
        self.presenter.presentSubmissions(
            response: .init(
                stepID: self.step.id,
                isTeacher: self.isTeacher,
                isSelectionEnabled: true,
                filterQuery: .init(filters: [.submissionStatus(.correct)])
            )
        )
    }
}
