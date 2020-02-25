import UIKit

protocol CodeQuizFullscreenRunCodePresenterProtocol {
    func presentContentUpdate(response: CodeQuizFullscreenRunCode.ContentUpdate.Response)
    func presentTestInputSetDefault(response: CodeQuizFullscreenRunCode.TestInputSetDefault.Response)
    func presentRunCodeResult(response: CodeQuizFullscreenRunCode.RunCode.Response)
    func presentTestInputSamples(response: CodeQuizFullscreenRunCode.TestInputSamplesPresentation.Response)
}

final class CodeQuizFullscreenRunCodePresenter: CodeQuizFullscreenRunCodePresenterProtocol {
    weak var viewController: CodeQuizFullscreenRunCodeViewControllerProtocol?

    // MARK: Protocol Conforming

    func presentContentUpdate(response: CodeQuizFullscreenRunCode.ContentUpdate.Response) {
        let viewModel = self.makeViewModel(userCodeRun: response.data.userCodeRun, samples: response.data.samples)
        self.viewController?.displayContentUpdate(viewModel: .init(viewModel: viewModel))
    }

    func presentTestInputSetDefault(response: CodeQuizFullscreenRunCode.TestInputSetDefault.Response) {
        self.viewController?.displayTestInputSetDefault(viewModel: .init(input: response.input))
    }

    func presentRunCodeResult(response: CodeQuizFullscreenRunCode.RunCode.Response) {
        switch response.result {
        case .failure:
            self.viewController?.displayAlert(
                viewModel: .init(
                    title: NSLocalizedString("Error", comment: ""),
                    message: NSLocalizedString("ErrorMessage", comment: "")
                )
            )
        case .success(let data):
            self.viewController?.displayRunCodeResult(
                viewModel: .init(viewModel: self.makeViewModel(userCodeRun: data.userCodeRun, samples: data.samples))
            )
        }
    }

    func presentTestInputSamples(response: CodeQuizFullscreenRunCode.TestInputSamplesPresentation.Response) {
        self.viewController?.displayTestInputSamples(
            viewModel: .init(
                title: NSLocalizedString("CodeQuizFullscreenTabRunSamplesAlertTitle", comment: ""),
                samples: response.samples.map { $0.input }
            )
        )
    }

    // MARK: Private API

    private func makeViewModel(
        userCodeRun: UserCodeRun,
        samples: [CodeSamplePlainObject]
    ) -> CodeQuizFullscreenRunCodeViewModel {
        let testOutput: String? = {
            let stdout = userCodeRun.stdout ?? ""
            let stderr = userCodeRun.stderr ?? ""
            let emptyResultString = NSLocalizedString("CodeQuizFullscreenTabRunTestOuputEmptyResultTitle", comment: "")

            let stdoutNonEmptyString = stdout.isEmpty ? emptyResultString : stdout

            switch userCodeRun.status {
            case .success:
                return stdoutNonEmptyString
            case .failure:
                return stderr.isEmpty ? stdoutNonEmptyString : stderr
            default:
                return nil
            }
        }()

        let isTestOutputMatchesSampleOutput = samples
            .first(where: { $0.input == userCodeRun.stdin })?
            .output.trimmingCharacters(in: .whitespacesAndNewlines)
                == testOutput?.trimmingCharacters(in: .whitespacesAndNewlines)

        let shouldShowTestOutput = userCodeRun.status == .failure || userCodeRun.status == .success

        let isSamplesButtonEnabled = userCodeRun.status != .evaluation && !samples.isEmpty

        let isCodeEmpty = userCodeRun.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isTestInputFilled = userCodeRun.language == .sql ? true : !(userCodeRun.stdin?.isEmpty ?? true)
        let isInputDataFilled = !isCodeEmpty && isTestInputFilled
        let isRunCodeButtonEnabled = userCodeRun.status != .evaluation && isInputDataFilled

        return CodeQuizFullscreenRunCodeViewModel(
            testInput: userCodeRun.stdin,
            testOutput: testOutput,
            userCodeRunStatus: userCodeRun.status,
            isTestOutputMatchesSampleOutput: isTestOutputMatchesSampleOutput,
            shouldShowTestInput: userCodeRun.language != .sql,
            shouldShowTestOutput: shouldShowTestOutput,
            isSamplesButtonEnabled: isSamplesButtonEnabled,
            isRunCodeButtonEnabled: isRunCodeButtonEnabled
        )
    }
}
