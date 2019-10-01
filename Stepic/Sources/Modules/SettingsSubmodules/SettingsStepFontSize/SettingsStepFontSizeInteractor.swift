import Foundation
import PromiseKit

protocol SettingsStepFontSizeInteractorProtocol {
    func doFontSizesListPresentation(request: SettingsStepFontSize.FontSizesLoad.Request)
    func doFontSizeSelection(request: SettingsStepFontSize.FontSizeSelection.Request)
}

final class SettingsStepFontSizeInteractor: SettingsStepFontSizeInteractorProtocol {
    private let presenter: SettingsStepFontSizePresenterProtocol
    private let provider: SettingsStepFontSizeProviderProtocol

    private var currentAvailableFontSizes: [(UniqueIdentifierType, FontSize)] = []

    init(
        presenter: SettingsStepFontSizePresenterProtocol,
        provider: SettingsStepFontSizeProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doFontSizesListPresentation(request: SettingsStepFontSize.FontSizesLoad.Request) {
        when(
            fulfilled: self.provider.fetchAvailableFontSizes(),
            self.provider.fetchCurrentFontSize()
        ).done { (availableFontSizes, currentFontSize) in
            let fontSizes = availableFontSizes.map { fontSize -> (UniqueIdentifierType, FontSize) in
                (fontSize.title, fontSize)
            }

            self.currentAvailableFontSizes = fontSizes
            self.presenter.presentFontSizes(
                response: SettingsStepFontSize.FontSizesLoad.Response(
                    result: SettingsStepFontSize.FontSizeInfo(
                        availableFontSizes: fontSizes,
                        activeFontSize: currentFontSize
                    )
                )
            )
        }.catch { _ in
            fatalError("Unexpected error while extracting info about languages")
        }
    }

    func doFontSizeSelection(request: SettingsStepFontSize.FontSizeSelection.Request) {
        guard let selectedFontSize = self.currentAvailableFontSizes
            .first(where: { $0.0 == request.viewModelUniqueIdentifier })?.1 else {
            fatalError("Request contains invalid data")
        }

        // FIXME: analytics dependency
        let analyticsSelectedFontSizeString: String = {
            switch selectedFontSize {
            case .small:
                return "small"
            case .medium:
                return "medium"
            case .large:
                return "large"
            }
        }()
        AmplitudeAnalyticsEvents.Settings.fontSizeSelected(size: analyticsSelectedFontSizeString).send()
        AnalyticsReporter.reportEvent(
            AnalyticsEvents.Settings.fontSizeSelected,
            parameters: ["size": analyticsSelectedFontSizeString]
        )

        self.provider.setGlobalFontSize(selectedFontSize)
        self.presenter.presentFontSizeChange(
            response: SettingsStepFontSize.FontSizeSelection.Response(
                result: SettingsStepFontSize.FontSizeInfo(
                    availableFontSizes: self.currentAvailableFontSizes,
                    activeFontSize: selectedFontSize
                )
            )
        )
    }
}
